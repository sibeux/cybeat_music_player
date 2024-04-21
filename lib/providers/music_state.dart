import 'package:audio_service/audio_service.dart';
import 'package:flutter/widgets.dart';

class MusicState extends ChangeNotifier{
  MediaItem? _currentMediaItem;

  MediaItem? get currentMediaItem => _currentMediaItem;

  void setCurrentMediaItem(MediaItem mediaItem){
    _currentMediaItem = mediaItem;
    notifyListeners();
  }
}