import 'package:cybeat_music_player/models/playlist.dart';
import 'package:flutter/widgets.dart';

class PlaylistState extends ChangeNotifier {
  Playlist? _currentPlaylist;

  Playlist? get currentPlaylist => _currentPlaylist;

  void setCurrentPlaylist(Playlist playlist) {
    _currentPlaylist = playlist;
  }
}
