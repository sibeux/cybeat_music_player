import 'package:audio_service/audio_service.dart';
import 'package:cybeat_music_player/controller/recents_music.dart';
import 'package:flutter/widgets.dart';

class MusicState extends ChangeNotifier {
  MediaItem? _currentMediaItem;

  MediaItem? get currentMediaItem => _currentMediaItem;

  void setCurrentMediaItem(MediaItem mediaItem) {
    if (currentMediaItem?.extras?['music_id'] != mediaItem.extras!['music_id']) {
      setRecentsMusic(mediaItem.extras!['music_id']);
    }

    _currentMediaItem = mediaItem;
  }

  void clear() {
    _currentMediaItem = null;
  }
}
