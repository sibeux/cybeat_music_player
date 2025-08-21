import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:cybeat_music_player/common/utils/capitalize.dart';
import 'package:cybeat_music_player/common/utils/colorize_terminal.dart';
import 'package:cybeat_music_player/common/utils/toast.dart';
import 'package:cybeat_music_player/common/utils/url_formatter.dart';
import 'package:cybeat_music_player/core/controllers/music_download_controller.dart';
import 'package:cybeat_music_player/core/controllers/music_player_controller.dart';
import 'package:cybeat_music_player/core/models/playlist.dart';
import 'package:cybeat_music_player/core/services/album_service.dart';
import 'package:ffmpeg_kit_flutter_new/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter_new/stream_information.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AudioStateController extends GetxController {
  /// Kalau kamu mau pakai AudioPlayer (misalnya dari just_audio) bareng GetX, biasanya kita bikin dia reactive supaya gampang di-observe.
  /// Sekarang soal late → kamu perlu hati-hati:
  /// late dipakai kalau kamu mau deklarasi variabel tanpa langsung inisialisasi, tapi janji bakal diisi sebelum dipakai.
  /// obs atau Rx di GetX butuh nilai awal (meskipun null). Jadi kalau mau reaktif, biasanya nggak perlu late, cukup kasih default.
  final activePlayer = Rx<AudioPlayer?>(null);
  final playlist = Rx<ConcatenatingAudioSource?>(null);
  static int _nextMediaId = 1;
  // qeueu untuk testing screen
  List<MediaItem> queue = [];

  var sampleRate = '--'.obs;
  var bitsPerRawSample = '--'.obs;
  var bitRate = '--'.obs;
  var codecName = ''.obs;
  var musicQuality = ''.obs;

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
        final currentIndex = activePlayer.value?.currentIndex;
        if (currentIndex != null) {
          final MediaItem item = queue[currentIndex];
          final String currentMusicId = item.extras!['music_id'];
          // KONDISI UTAMA:
          // ** 1. Player dalam state 'ready' event.processingState == ProcessingState.ready
          // ** (artinya lagu baru sudah di-load).
          // 2. ID musik saat ini BERBEDA dengan ID yang terakhir kita proses.
          if (currentMusicId != lastProcessedMusicId) {
            // Set ID terakhir DULUAN untuk mencegah pemanggilan berulang.
            lastProcessedMusicId = currentMusicId;
            // Baru panggil fungsi-fungsi Anda.
            await onReadCodec(
              url: item.extras!['url'],
              mediaItem: item,
            );
            setRecentsMusic(currentMusicId);
          }
        }
      },
      onError: (Object e, StackTrace stackTrace) {
        logError('A stream error occurred: $e');
      },
    );
  }

  Future<void> init(Playlist list) async {
    final AlbumService albumService = Get.find();
    String type = list.type.toLowerCase();
    _nextMediaId = 1;
    const String endpoint =
        "https://sibeux.my.id/cloud-music-player/database/mobile-music-player/api/playlist";
    String url = "$endpoint?uid=${list.uid}&type=$type";
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
          return;
        }
        listData = musicDownloadController.musicOfflineList;
      } else {
        final response = await http.get(Uri.parse(url));
        final responseBody = json.decode(response.body);
        if (responseBody.isNotEmpty && type != 'offline') {
          final prefs = await SharedPreferences.getInstance();
          uidDownloadedSongs = prefs.getStringList('uidDownloadedSongs') ?? [];
          listData = [].obs; // inisialisasi dulu
          listData.assignAll(responseBody); // assign dari List biasa
        } else {
          listData = RxList<dynamic>([]);
        }
      }
      if (listData.isEmpty) {
        playlist.value = ConcatenatingAudioSource(
          children: [],
        );
        return;
      }
      playlist.value = ConcatenatingAudioSource(
        children: listData.map(
          (item) {
            final String uploader = item['uploader'] ?? 'cybeat';
            final String musicUrl = regexGdriveHostUrl(
              url: type != 'offline' ? item['link_gdrive'] : item['filePath'],
              listApiKey: albumService.gdriveApiKeyList,
              musicId: item['id_music'],
              isAudioCached: item['cache_music_id'] != null ? true : false,
              isSuspicious: item['is_suspicious'] == 'true' ? true : false,
              uploader: uploader,
            );
            return AudioSource.uri(
              Uri.parse(musicUrl),
              tag: MediaItem(
                id: '${_nextMediaId++}',
                title: capitalizeEachWord(item['title']),
                artist: capitalizeEachWord(item['artist']),
                album: capitalizeEachWord(item['album']),
                artUri: Uri.parse(
                  regexGdriveHostUrl(
                    url: item['cover'],
                    listApiKey: albumService.gdriveApiKeyList,
                    isAudio: false,
                  ),
                ),
                extras: {
                  'music_id': item['id_music'],
                  'url': musicUrl,
                  'favorite': item['favorite'],
                  'id_playlist_music': item['id_playlist_music'] ?? '',
                  'original_source': type != 'offline'
                      ? item['link_gdrive']
                      : item['filePath'],
                  'is_cached': item['cache_music_id'] != null ? true : false,
                  'is_lossless':
                      item['music_quality'] == 'lossless' ? true : false,
                  'metadata': {
                    // metadata_id_music dibiarkan null gpp kalo kosong.
                    // Buat cek di onReadCodec.
                    'metadata_id_music': item['metadata_id_music'] ?? '',
                    'codec_name': item['codec_name'] ?? '--',
                    'sample_rate': item['sample_rate'] ?? '--',
                    'bit_rate': item['bit_rate'] ?? '--',
                    'bits_per_raw_sample': item['bits_per_raw_sample'] ?? '--',
                  },
                  'is_downloaded': type != 'offline'
                      ? uidDownloadedSongs.contains(item['id_music'])
                          ? true
                          : false
                      : false,
                  'uploader': uploader,
                  'is_suspicious':
                      item['is_suspicious'] == 'true' ? true : false,
                },
              ),
            );
          },
        ).toList(),
      );
      queue = playlist.value!.sequence.map((e) => e.tag as MediaItem).toList();
      await activePlayer.value?.setAudioSource(playlist.value!);
    } catch (e, st) {
      // logger.e('Error loading audio source: $e');
      logError('Error loading audio source: $e, st:$st');
      FirebaseCrashlytics.instance.recordError(e, st, reason: e, fatal: false);
    }
  }

  Future<void> deleteMusicFromPlaylist({
    required String idPlaylistMusic,
  }) async {
    const url =
        'https://sibeux.my.id/cloud-music-player/database/mobile-music-player/api/music_playlist';
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
        // LAPORKAN sebagai error non-fatal agar mudah dilacak
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
        musicPlayerController.pauseMusic();
        init(musicPlayerController.currentActivePlaylist.value!);
        musicPlayerController.setActivePlaylist(
            musicPlayerController.currentActivePlaylist.value!);

        // Tampilkan toast.
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

  void setRecentsMusic(String? id) async {
    String url =
        'https://sibeux.my.id/cloud-music-player/database/mobile-music-player/api/recents_music';
    try {
      await http.post(
        Uri.parse(url),
        body: {
          'music_id': id,
          'codec_name': codecName.value,
          'quality': musicQuality.value,
          'bits_per_raw_sample': bitsPerRawSample.value,
          'sample_rate': sampleRate.value,
          'bit_rate': bitRate.value,
        },
      );
      logSuccess('setRecentsMusic success');
    } catch (e) {
      logError('Error set recents music: $e');
    }
  }

  Future<void> onReadCodec(
      {required String url, required MediaItem mediaItem}) async {
    const lossyFormats = ['mp3', 'aac', 'ogg', 'opus', 'wma'];
    // Ini berfungsi sebagai placeholder laoding saat fetch.
    bitsPerRawSample.value = '--';
    sampleRate.value = '--';
    bitRate.value = '--';
    try {
      final Map<String, dynamic> metadata = mediaItem.extras?['metadata'];
      // Cek dulu apakah udah ada metadata atau belum?
      // Cek juga apakah metadatanya memang sudah sesuai format?
      final bool isMetadataCorrect = metadata['bits_per_raw_sample'] != '--' ||
          metadata['sample_rate'] != '--' ||
          metadata['bit_rate'] != '--';
      if (metadata['metadata_id_music'] != null && (isMetadataCorrect)) {
        bitsPerRawSample.value = metadata['bits_per_raw_sample'];
        sampleRate.value = metadata['sample_rate'];
        bitRate.value = metadata['bit_rate'];
        codecName.value = metadata['codec_name'];
        musicQuality.value =
            mediaItem.extras?['is_lossless'] ? 'lossless' : 'lossy';
        // Kalo ada isinya, gak usah dicek.
        return;
      }
      // 1. Jalankan FFprobe langsung dengan URL
      final session = await FFprobeKit.getMediaInformation(url);
      final information = session.getMediaInformation();
      if (information != null) {
        // 2. Proses ekstraksi data sama persis seperti file lokal
        final audioStream = information.getStreams().firstWhere(
              (s) => s.getType() == 'audio',
              orElse: () => StreamInformation(information.getAllProperties()),
            );
        bitsPerRawSample.value =
            audioStream.getProperty('bits_per_raw_sample') ?? '--';
        final String fileSampleRate =
            audioStream.getProperty('sample_rate') ?? '--';
        final String fileBitRate = audioStream.getProperty('bit_rate') ?? '--';
        sampleRate.value = fileSampleRate != '--'
            ? (int.parse(fileSampleRate) / 1000).toString()
            : '--';
        bitRate.value = fileBitRate != '--'
            ? (int.parse(fileBitRate) / 1000).toStringAsFixed(0)
            : '--';
        codecName.value = audioStream.getProperty('codec_name') ?? '';
        musicQuality.value =
            lossyFormats.contains(codecName.value.toLowerCase())
                ? "lossy"
                : "lossless";
      }
    } catch (e) {
      logError('Error onReadCodec: $e');
    }
  }
}
