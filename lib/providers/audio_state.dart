import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:cybeat_music_player/components/capitalize.dart';
import 'package:flutter/widgets.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;

var logger = Logger();

class AudioState extends ChangeNotifier {
  late AudioPlayer player;
  late ConcatenatingAudioSource playlist;
  static int _nextMediaId = 1;
  // qeueu untuk testing screen
  List<MediaItem> queue = [];

  AudioState() {
    player = AudioPlayer();
    _init();
  }

  Future<void> _init() async {
    player.playbackEventStream.listen(
      (event) {},
      onError: (Object e, StackTrace stackTrace) {
        logger.e('A stream error occurred: $e');
      },
    );

    const url =
        'https://sibeux.my.id/cloud-music-player/database/mobile-music-player/api/db.php';
    const api =
        'https://sibeux.my.id/cloud-music-player/database/mobile-music-player/api/gdrive_api.php';

    try {
      final response = await http.get(Uri.parse(url));
      final apiResponse = await http.get(Uri.parse(api));

      final List<dynamic> listData = json.decode(response.body);
      final List<dynamic> apiData = json.decode(apiResponse.body);

      playlist = ConcatenatingAudioSource(
        children: listData.map(
          (item) {
            return AudioSource.uri(
              // Uri.parse(item['link_gdrive']),
              Uri.parse(
                  filteredUrl(item['link_gdrive'], apiData[0]['gdrive_api'])),
              tag: MediaItem(
                id: '${_nextMediaId++}',
                title: capitalizeEachWord(item['title']),
                artist: capitalizeEachWord(item['artist']),
                album: capitalizeEachWord(item['album']),
                // artUri: Uri.parse(item['cover']),
                artUri: Uri.parse(
                    filteredUrl(item['cover'], apiData[0]['gdrive_api'])),
                extras: {
                  'favorite': item['favorite'],
                  'music_id': item['id_music'],
                },
              ),
            );
          },
        ).toList(),
      );

      queue = playlist.sequence.map((e) => e.tag as MediaItem).toList();

      await player.setAudioSource(playlist);
    } catch (e) {
      logger.e('Error loading audio source: $e');
    }
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
