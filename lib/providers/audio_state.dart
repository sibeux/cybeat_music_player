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

    try {
      final response = await http.get(Uri.parse(url));

      final List<dynamic> listData = json.decode(response.body);

      playlist = ConcatenatingAudioSource(
        children: listData
            .map((item) => AudioSource.uri(
                  Uri.parse(item['link_gdrive']),
                  tag: MediaItem(
                    id: '${_nextMediaId++}',
                    title: capitalizeEachWord(item['title']),
                    artist: capitalizeEachWord(item['artist']),
                    album: capitalizeEachWord(item['album']),
                    artUri: Uri.parse(item['cover']),
                    extras: {
                      'favorite': item['favorite'],
                      'music_id': item['id_music'],
                    },
                  ),
                ))
            .toList(),
      );

      await player.setAudioSource(playlist);
    } catch (e) {
      logger.e('Error loading audio source: $e');
    }
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }
}
