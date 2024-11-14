import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:cybeat_music_player/components/capitalize.dart';
import 'package:cybeat_music_player/controller/music_download_controller.dart';
import 'package:cybeat_music_player/controller/music_state_controller.dart';
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
                    filteredUrl(item['link_gdrive'], apiData[0]['gdrive_api']),
                  ),
                  tag: MediaItem(
                    id: '${_nextMediaId++}',
                    title: capitalizeEachWord(item['title']),
                    artist: capitalizeEachWord(item['artist']),
                    album: capitalizeEachWord(item['album']),
                    // artUri: Uri.parse(item['cover']),
                    artUri: Uri.parse(
                      filteredUrl(item['cover'], apiData[0]['gdrive_api']),
                    ),
                    extras: {
                      'favorite': item['favorite'],
                      'music_id': item['id_music'],
                      'url': filteredUrl(
                        item['link_gdrive'],
                        apiData[0]['gdrive_api'],
                      ),
                      'is_downloaded': uidDownloadedSongs.contains(item['id_music'])
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

  String filteredUrl(String url, String key) {
    if (url.contains('drive.google.com')) {
      RegExp regExp = RegExp(r'/d/([a-zA-Z0-9_-]+)');
      Match? match = regExp.firstMatch(url);
      return 'https://www.googleapis.com/drive/v3/files/${match!.group(1)}?alt=media&key=$key';
    } else {
      return url;
    }
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }
}
