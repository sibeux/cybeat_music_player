import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:cybeat_music_player/common/utils/capitalize.dart';
import 'package:cybeat_music_player/common/utils/colorize_terminal.dart';
import 'package:cybeat_music_player/common/utils/toast.dart';
import 'package:cybeat_music_player/common/utils/url_formatter.dart';
import 'package:cybeat_music_player/core/controllers/music_download_controller.dart';
import 'package:cybeat_music_player/core/controllers/music_player_controller.dart';
import 'package:cybeat_music_player/core/models/music.dart';
import 'package:cybeat_music_player/core/models/album.dart';
import 'package:cybeat_music_player/core/repositories/audio_repository.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AudioStateController extends GetxController {
  /// Kalau mau pakai AudioPlayer (misalnya dari just_audio) bareng GetX, biasanya kita bikin dia reactive supaya gampang di-observe.
  /// Sekarang soal late → perlu hati-hati:
  /// late dipakai kalau mau deklarasi variabel tanpa langsung inisialisasi, tapi janji bakal diisi sebelum dipakai.
  /// obs atau Rx di GetX butuh nilai awal (meskipun null). Jadi kalau mau reaktif, biasanya nggak perlu late, cukup kasih default.
  final AudioRepository audioRepository = AudioRepository();
  final activePlayer = Rx<AudioPlayer?>(null);
  final playlist = RxList<Music>([]);
  static int _nextMediaId = 1;
  // qeueu untuk testing screen
  List<MediaItem> queue = [];

  var sampleRate = '--'.obs;
  var bitsPerRawSample = '--'.obs;
  var bitRate = '--'.obs;
  var codecName = ''.obs;
  var musicQuality = ''.obs;

  var bgColor = '#000000'.obs;
  var textColor = '#ffffff'.obs;

  var initAlbumLoading = false.obs;
  var isAlbumEmpty = false.obs;

  RxList<Music> get getPlaylist => playlist;

  // Jadikan 'uid' sebagai variabel di luar listener agar nilainya tidak di-reset.
  // Sebaiknya ini menjadi variabel instance di dalam class Anda.
  String? lastProcessedMusicId;

  final musicPlayerController = Get.find<MusicPlayerController>();

  @override
  void onInit() {
    activePlayer.value = AudioPlayer();
    super.onInit();
  }

  @override
  void onClose() {
    activePlayer.value?.dispose();
    super.onClose();
  }

  Future<void> clear() async {
    activePlayer.value?.stop();
    activePlayer.value?.dispose();
    activePlayer.value = AudioPlayer();
    // Reset ID saat player di-clear.
    lastProcessedMusicId = null;

    // PlaybackEventStream, dia berfungsi untuk listen-
    // player sedang dalam kondisi apa? Makanya listen ini bekerja berulang-ulang.
    activePlayer.value?.sequenceStateStream.listen(
      (event) async {
        // Kita hanya peduli saat ada item yang sedang diproses dan player siap memainkannya.
        final currentIndex = musicPlayerController.getCurrentMediaItem?.id;
        if (currentIndex != null) {
          final String currentMusicId =
              musicPlayerController.getCurrentMediaItem!.id;

          // [CYBEAT-FLOW-001-A] Guard: cek apakah musik ini sudah pernah diproses.
          // sequenceStateStream bisa emit berkali-kali (buffering, seeking, dll) untuk lagu
          // yang sama. Tanpa guard ini, API akan dipanggil berulang-ulang.
          // lastProcessedMusicId di-set SEBELUM proses dimulai untuk mencegah race condition.
          // Lihat: docs/CYBEAT-FLOW-001_recent_codec_dominant_color.md
          if (currentMusicId != lastProcessedMusicId &&
              !musicPlayerController
                  .getCurrentMediaItem!.extras!['is_offline']) {
            // Set ID terakhir DULUAN untuk mencegah pemanggilan berulang.
            lastProcessedMusicId = currentMusicId;

            // [CYBEAT-FLOW-001-B] Cek metadata codec dari data lokal (extras MediaItem).
            // Tidak hit API. Hasilnya dikirim ke backend sebagai flag 'codec_exist'.
            final isCodecExist = await checkCodecAudio(
              mediaItem: musicPlayerController.getCurrentMediaItem!,
            );

            // [CYBEAT-FLOW-001-C] Cek dominant color dari data lokal (extras MediaItem).
            // Tidak hit API. Hasilnya dikirim ke backend sebagai flag 'dominant_color_exist'.
            final isDominantColorExist = await checkDominantColor(
              mediaItem: musicPlayerController.getCurrentMediaItem!,
            );

            final bool isFromGdrive = musicPlayerController
                .getCurrentMediaItem!.extras!['original_source']
                .contains("drive.google.com");

            // [CYBEAT-FLOW-001-D] Fire & forget — sengaja tanpa await.
            // Agar stream listener tidak terblokir menunggu HTTP request selesai.
            // Error ditangani di dalam setRecentsCodecDominantColor itu sendiri.
            setRecentsCodecDominantColor(
              musicId: int.tryParse(currentMusicId),
              isCodecExist: isCodecExist,
              isDominantColorExist: isDominantColorExist,
              musicUrl:
                  musicPlayerController.getCurrentMediaItem!.extras!['url'],
              imageUrl:
                  musicPlayerController.getCurrentMediaItem!.artUri.toString(),
              isFromGdrive: isFromGdrive,
              albumId: int.tryParse(
                      musicPlayerController.currentActivePlaylist.value?.uid ??
                          "0") ??
                  0,
              albumType:
                  musicPlayerController.currentActivePlaylist.value?.type ?? "",
            );
          }
        }
      },
      onError: (Object e, StackTrace stackTrace) {
        logError('A stream error occurred: $e');
      },
    );
  }

  Future<void> init(Album list) async {
    initAlbumLoading.value = true;
    isAlbumEmpty.value = false;
    String type = list.type.toLowerCase();
    _nextMediaId = 1;

    FirebaseCrashlytics.instance
        .log("Fetch music started for uid=${list.uid}&type=$type");
    try {
      late RxList<dynamic> listData;
      late List<dynamic> uidDownloadedSongs;
      if (type == 'offline') {
        final musicDownloadController = Get.find<MusicDownloadController>();
        await musicDownloadController.getDownloadedSongs();
        if (musicDownloadController.musicOfflineList.isEmpty) {
          listData = RxList<dynamic>([]);
          isAlbumEmpty.value = true;
          playlist.value = <Music>[];
          await activePlayer.value?.setAudioSources([]);
          return;
        }
        listData = musicDownloadController.musicOfflineList;
      } else {
        final responseBody = await audioRepository.getSongs(
          albumType: type,
          albumId: list.uid,
        );
        if (responseBody.isNotEmpty && type != 'offline') {
          final prefs = await SharedPreferences.getInstance();
          uidDownloadedSongs = prefs.getStringList('uidDownloadedSongs') ?? [];
          List<dynamic> data = responseBody['data'] as List<dynamic>;
          if (data.isEmpty) {
            isAlbumEmpty.value = true;
            playlist.value = <Music>[];
            await activePlayer.value?.setAudioSources([]);
            return;
          }
          listData = [].obs; // inisialisasi dulu
          listData.assignAll(data); // assign dari List biasa
        } else {
          listData = RxList<dynamic>([]);
        }
      }
      if (listData.isEmpty) {
        isAlbumEmpty.value = true;
        playlist.value = <Music>[];
        await activePlayer.value?.setAudioSources([]);
        return;
      }
      playlist.value = listData.map(
        (item) {
          final String uploader = item['uploader'] == null
              ? "Cybeat"
              : item['uploader'].toString().trim() == ''
                  ? "Cybeat"
                  : item['uploader'];
          final String musicUrl = regexGdriveHostUrl(
              url: type == 'offline' ? item['filePath'] : "",
              musicId: item['id_music'].toString(),
              isAudioCached: item['cache_music_id'] != null ? true : false,
              isOffline: type == 'offline' ? true : false,
              isAudio: true);
          return Music(
            musicId: int.tryParse(item['id_music'].toString()) ?? 0,
            album: capitalizeEachWord(item['album'] ?? "Unknown Album"),
            artist: capitalizeEachWord(item['artist']),
            cover: regexGdriveHostUrl(
              url: item['cover'],
              musicId: "0",
              isAudio: false,
            ),
            linkDrive: musicUrl,
            title: capitalizeEachWord(item['title']),
            extras: {
              'index': '${_nextMediaId++}',
              'music_id': item['id_music'].toString(),
              'file_drive_id': '',
              'disc_number': item['disc_number'],
              'url': musicUrl,
              'favorite': item['favorite'],
              'id_playlist_music': item['id_playlist_music'] ?? '',
              'original_source': type != 'offline'
                  // ? "Cloud Storage"
                  ? item['cover']
                  : item['filePath'],
              'is_cached': item['cache_music_id'] != null ||
                      item['link_gdrive'].toString().contains('cdncloudflare/')
                  ? true
                  : false,
              'is_lossless': item['music_quality'] == 'lossless' ? true : false,
              'metadata': {
                // metadata_id_music dibiarkan null gpp kalo kosong.
                // Buat cek di onReadCodec.
                'metadata_id_music': item['metadata_id_music'] ?? '',
                'codec_name': item['codec_name'] ?? '--',
                'sample_rate': item['sample_rate'] ?? '--',
                'bit_rate': item['bit_rate'] ?? '--',
                'bits_per_raw_sample': item['bits_per_raw_sample'] ?? '--',
              },
              'dominant_color': {
                'bg_color': item['bg_color'] ?? '',
                'text_color': item['text_color'] ?? '',
              },
              'is_downloaded': type != 'offline'
                  // List uidDownloadedSongs itu save value String.
                  // Karena item['id_music'] itu int, jadi harus di-convert dulu ke String sebelum cek contains.
                  ? uidDownloadedSongs.contains(item['id_music'].toString())
                      ? true
                      : false
                  : false,
              'uploader': uploader,
              'is_suspicious': item['is_suspicious'] == 'true' ? true : false,
              'is_offline': type == 'offline' ? true : false,
            },
          );
        },
      ).toList();
      queue = playlist
          .map(
            (e) => MediaItem(
              id: e.musicId.toString(),
              title: e.title,
              album: e.album,
              artUri: Uri.parse(e.cover),
              artist: e.artist,
              extras: e.extras,
            ),
          )
          .toList();
    } catch (e, st) {
      logError('Error loading audio source: $e, st:$st');
      FirebaseCrashlytics.instance.recordError(e, st, reason: e, fatal: false);
      isAlbumEmpty.value = true;
      playlist.value = <Music>[];
      await activePlayer.value?.setAudioSources([]);
    } finally {
      initAlbumLoading.value = false;
    }
  }

  Future<void> deleteMusicFromPlaylist({
    required String idPlaylistMusic,
  }) async {
    String url = getEndpoint('MUSIC_PLAYLIST_API_URL');
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json"
        }, // Harus pakai JSON karena di file PHP,
        // kita menggunakan json_decode().
        body: jsonEncode({
          'method': 'delete_music_on_playlist',
          'id_playlist_music': idPlaylistMusic,
        }),
      );

      if (response.body.isEmpty) {
        final reason =
            'Error in deleteMusicFromPlaylist: Response body is empty: ${response.statusCode}';
        logError(reason);
        return;
      }

      final responseBody = jsonDecode(response.body);

      if (responseBody['status'] == 'success') {
        final reason =
            'Music has been deleted from the playlist: $responseBody';
        logSuccess(reason);
        FirebaseCrashlytics.instance.log(reason);
        final musicPlayerController = Get.find<MusicPlayerController>();

        // * By default, daftar dari playlist tidak perlu update list lagi.
        // * Karena saat musik dihapus, dia akan otomatis rebuild dan kembali fetch ke API.
        // * Baiknya sebenarnya bisa pakai controller dan disimpan di dalam variable,
        // * sehingga tidak perlu fetch lagi ke API.

        // Hentikan musik dan bersihkan queue.
        // Harus ada ini agar azlistview di-rebuild.
        // Bagian ini berfungsi untuk fetch ulang data list musik dari API.
        clear();
        musicPlayerController.killMusic();
        init(musicPlayerController.currentActivePlaylist.value!);
        musicPlayerController.setActivePlaylist(
            musicPlayerController.currentActivePlaylist.value!);
        showRemoveAlbumToast('Music has been deleted from the playlist');
        Get.back();
      } else {
        final e = 'Error in deleteMusicFromPlaylist: $responseBody';
        logError(e);
      }
    } catch (err, st) {
      final e = 'Error delete music from playlist: $err';
      logError(e);
      FirebaseCrashlytics.instance
          .recordError(err, st, reason: e, fatal: false);
    } finally {
      // Baru setelah di-fetch, azlist di-rebuild pakai ini.
      final musicDownloadController = Get.find<MusicDownloadController>();
      musicDownloadController.rebuildDelete.value =
          !musicDownloadController.rebuildDelete.value;
    }
  }

  // [CYBEAT-FLOW-001-D] Fungsi ini dipanggil fire & forget (tanpa await) dari stream listener.
  // Memanggil repository untuk kirim data ke backend, lalu update state UI dari response.
  // Lihat: docs/CYBEAT-FLOW-001_recent_codec_dominant_color.md
  void setRecentsCodecDominantColor({
    required int? musicId,
    required String musicUrl,
    required String imageUrl,
    required bool isCodecExist,
    required bool isDominantColorExist,
    required bool isFromGdrive,
    required int albumId,
    required String albumType,
  }) async {
    try {
      final body = await audioRepository.setRecentCodecDominantColor(
          musicId: musicId,
          albumId: albumId,
          albumType: albumType,
          musicUrl: musicUrl,
          imageUrl: imageUrl,
          isCodecExist: isCodecExist,
          isDominantColorExist: isDominantColorExist,
          isFromGdrive: isFromGdrive);

      // [CYBEAT-FLOW-001-F] Update reactive state dari response backend.
      // body['codec'] null berarti server tidak perlu proses (isCodecExist sudah true).
      // body['dominant_color'] null berarti server tidak perlu proses dominant color.
      // PENTING: cek masing-masing secara terpisah karena salah satu bisa null
      // sementara yang lain tidak — OR condition sebelumnya akan tetap masuk blok
      // dan cast yang null akan crash: 'Null is not a subtype of Map<String, dynamic>'.
      if (body['status'] == "success") {
        logSuccess('Success: $body');

        // Cek codec secara individual sebelum cast.
        final Map<String, dynamic>? codec =
            body['codec'] as Map<String, dynamic>?;
        if (codec != null && codec.isNotEmpty) {
          bitsPerRawSample.value = codec["bits_per_raw_sample"];
          sampleRate.value = codec["sample_rate"];
          bitRate.value = codec["bit_rate"];
        }

        // Cek dominant_color secara individual sebelum cast.
        final Map<String, dynamic>? dominantColor =
            body['dominant_color'] as Map<String, dynamic>?;
        if (dominantColor != null && dominantColor.isNotEmpty) {
          bgColor.value = dominantColor["bg_color"];
          textColor.value = dominantColor["text_color"];
        }

        if (codec == null && dominantColor == null) {
          logInfo(
              'Codec & dominant_color sudah diset sebelumnya. Response: $body');
        }
      }
    } catch (e, st) {
      logError('Error setRecentsCodecDominantColor: $e, st: $st');
    }
  }

  Future<bool> checkCodecAudio({
    required MediaItem mediaItem,
  }) async {
    bitsPerRawSample.value = '--';
    sampleRate.value = '--';
    bitRate.value = '--';
    try {
      final Map<String, dynamic> metadata = mediaItem.extras?['metadata'];
      // Cek dulu apakah udah ada metadata atau belum?
      // Cek juga apakah metadatanya memang sudah sesuai format?
      final bool isMetadataExist = metadata['bits_per_raw_sample'] != '--' ||
          metadata['sample_rate'] != '--' ||
          metadata['codec_name'] != '--' ||
          metadata['bit_rate'] != '--';
      if (metadata['metadata_id_music'] != null && (isMetadataExist)) {
        bitsPerRawSample.value = metadata['bits_per_raw_sample'];
        sampleRate.value = metadata['sample_rate'];
        bitRate.value = metadata['bit_rate'];
        codecName.value = metadata['codec_name'];
        musicQuality.value =
            mediaItem.extras?['is_lossless'] ? 'lossless' : 'lossy';
        // Kalo ada isinya, gak usah dicek.
        return true;
      } else {
        return false;
      }
    } catch (e) {
      logError('Error onReadCodec: $e');
      return false;
    }
  }

  Future<bool> checkDominantColor({
    required MediaItem mediaItem,
  }) async {
    bgColor.value = '#000000';
    textColor.value = '#ffffff';
    try {
      final Map<String, dynamic> dominantColor =
          mediaItem.extras?['dominant_color'];
      final bool isDominantColorExist =
          dominantColor['bg_color'] != '' && dominantColor['text_color'] != '';
      if (isDominantColorExist) {
        bgColor.value = dominantColor['bg_color'];
        textColor.value = dominantColor['text_color'];
        return true;
      } else {
        return false;
      }
    } catch (e, st) {
      logError('Error checkDominantColor: $e, st: $st');
      return false;
    }
  }
}
