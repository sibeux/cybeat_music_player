import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:cybeat_music_player/components/capitalize.dart';
import 'package:cybeat_music_player/components/toast.dart';
import 'package:cybeat_music_player/components/url_formatter.dart';
import 'package:cybeat_music_player/controller/music_download_controller.dart';
import 'package:cybeat_music_player/controller/music_play/playing_state_controller.dart';
import 'package:cybeat_music_player/controller/playlist_play_controller.dart';
import 'package:cybeat_music_player/controller/music_play/read_codec_controller.dart';
import 'package:cybeat_music_player/controller/recents_music.dart';
import 'package:cybeat_music_player/models/playlist.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

var logger = Logger();

class AudioState extends ChangeNotifier {
  late AudioPlayer player;
  late ConcatenatingAudioSource playlist;
  static int _nextMediaId = 1;
  // qeueu untuk testing screen
  List<MediaItem> queue = [];

  AudioState() {
    player = AudioPlayer();

    /**
     * stream ini tidak digunakan, karena saat
     * pertama kali buka album, stream ini akan
     * di-dispose dan tidak bisa di-listen lagi.
     * Maka, stream ini dipindahkan ke clear()
     */

    // player.playbackEventStream.listen(
    //   (event) {},
    //   onError: (Object e, StackTrace stackTrace) {
    //     logger.e('A stream error occurred: $e');
    //   },
    // );
  }

  Future<void> clear() async {
    final playingStateController = Get.put(PlayingStateController());
    await player.stop();
    await player.dispose();
    player = AudioPlayer();
    var uid = '';

    player.playbackEventStream.listen(
      (event) {
        if (playingStateController.isPlaying.value) {
          final MediaItem item = queue[player.currentIndex!];

          if (item.extras?['music_id'] != uid) {
            uid = item.extras!['music_id'];
            setRecentsMusic(item.extras!['music_id']);

            // Untuk read codec file.
            final readCodecController = Get.find<ReadCodecController>();
            readCodecController.onReadCodec(item.extras!['url']);
          }
        }
      },
      onError: (Object e, StackTrace stackTrace) {
        logger.e('A stream error occurred: $e');
      },
    );
    // notifyListeners();
  }

  Future<void> recreate() async {
    await player.pause();
    await player.dispose();
    player = AudioPlayer();
  }

  Future<void> init(Playlist list) async {
    String type = list.type.toLowerCase();
    _nextMediaId = 1;

    String url =
        "https://sibeux.my.id/cloud-music-player/database/mobile-music-player/api/playlist?uid=${list.uid}&type=$type";
    const api =
        'https://sibeux.my.id/cloud-music-player/database/mobile-music-player/api/gdrive_api.php';

    try {
      if (type == 'offline') {
        final musicDownloadController = Get.find<MusicDownloadController>();
        await musicDownloadController.getDownloadedSongs();
        if (musicDownloadController.musicOfflineList.isNotEmpty) {
          playlist = ConcatenatingAudioSource(
            children: musicDownloadController.musicOfflineList.map(
              (item) {
                return AudioSource.uri(
                  Uri.file(item['filePath']),
                  tag: MediaItem(
                    id: '${_nextMediaId++}',
                    title: capitalizeEachWord(item['title']),
                    artist: capitalizeEachWord(item['artist']),
                    album: capitalizeEachWord(item['album']),
                    artUri: Uri.parse(item['cover']),
                    extras: {
                      'favorite': item['favorite'],
                      'music_id': item['id_music'],
                      'url': item['filePath'],
                      'is_downloaded': item['is_downloaded'],
                    },
                  ),
                );
              },
            ).toList(),
          );
        } else {
          playlist = ConcatenatingAudioSource(
            children: [],
          );
        }
      } else {
        final response = await http.get(Uri.parse(url));
        final apiResponse = await http.get(Uri.parse(api));

        final List<dynamic> listData = json.decode(response.body);
        final List<dynamic> apiData = json.decode(apiResponse.body);

        if (listData.isNotEmpty && type != 'offline') {
          final prefs = await SharedPreferences.getInstance();
          final uidDownloadedSongs =
              prefs.getStringList('uidDownloadedSongs') ?? [];

          playlist = ConcatenatingAudioSource(
            children: listData.map(
              (item) {
                return AudioSource.uri(
                  // Uri.parse(item['link_gdrive']),
                  Uri.parse(
                    regexGdriveLink(
                      url: item['link_gdrive'],
                      listApiKey: apiData,
                    ),
                  ),
                  tag: MediaItem(
                    id: '${_nextMediaId++}',
                    title: capitalizeEachWord(item['title']),
                    artist: capitalizeEachWord(item['artist']),
                    album: capitalizeEachWord(item['album']),
                    // artUri: Uri.parse(item['cover']),
                    artUri: Uri.parse(
                      regexGdriveLink(
                        url: item['cover'],
                        listApiKey: apiData,
                      ),
                    ),
                    extras: {
                      'favorite': item['favorite'],
                      'music_id': item['id_music'],
                      'id_playlist_music': item['id_playlist_music'] ?? '',
                      'url': regexGdriveLink(
                        url: item['link_gdrive'],
                        listApiKey: apiData,
                      ),
                      'is_downloaded':
                          uidDownloadedSongs.contains(item['id_music'])
                              ? true
                              : false,
                    },
                  ),
                );
              },
            ).toList(),
          );
        } else {
          playlist = ConcatenatingAudioSource(
            children: [],
          );
        }
      }
      queue = playlist.sequence.map((e) => e.tag as MediaItem).toList();

      await player.setAudioSource(playlist);
    } catch (e) {
      logger.e('Error loading audio source: $e');
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
        debugPrint('Error: Response body is empty');
        return;
      }

      final responseBody = jsonDecode(response.body);

      if (responseBody['status'] == 'success') {
        debugPrint('Music has been deleted from the playlist: $responseBody');
        final playingStateController = Get.find<PlayingStateController>();
        final playlistPlayController = Get.find<PlaylistPlayController>();

        // * By default, daftar dari playlist tidak perlu update list lagi.
        // * Karena saat musik dihapus, dia akan otomatis rebuild dan kembali fetch ke API.
        // * Baiknya sebenarnya bisa pakai controller dan disimpan di dalam variable,
        // * sehingga tidak perlu fetch lagi ke API.

        // Hentikan musik dan bersihkan queue.
        // Harus ada ini agar azlistview di-rebuild.
        // Bagian ini berfungsi untuk fetch ulang data list musik dari API.
        clear();
        playingStateController.pause();
        init(playlistPlayController.currentPlaylistPlay[0]);
        playlistPlayController
            .onPlaylist(playlistPlayController.currentPlaylistPlay[0]);

        // Tampilkan toast.
        showRemoveAlbumToast('Music has been deleted from the playlist');
        Get.back();
      } else {
        debugPrint('Error deleteMusicFromPlaylist: $responseBody');
      }
    } catch (e) {
      debugPrint('Error delete music from playlist: $e');
    } finally {
      // Baru setelah di-fetch, azlist di-rebuild pakai ini.
      final musicDownloadController = Get.find<MusicDownloadController>();
      musicDownloadController.rebuildDelete.value =
          !musicDownloadController.rebuildDelete.value;
    }
  }

  Future<void> setSourceAudio(ConcatenatingAudioSource playlist) async {
    player.playbackEventStream.listen(
      (event) {},
      onError: (Object e, StackTrace stackTrace) {
        logger.e('A stream error occurred: $e');
      },
    );

    this.playlist = playlist;

    queue = playlist.sequence.map((e) => e.tag as MediaItem).toList();

    await player.setAudioSource(playlist);
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }
}
