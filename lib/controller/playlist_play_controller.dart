import 'dart:async';
import 'package:cybeat_music_player/models/playlist.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class PlaylistPlayController extends GetxController {
  var playlistTitle = ''.obs;
  var playlistType = ''.obs;
  var playlistUid = ''.obs;
  var playlistEditable = ''.obs;
  var needRebuild = false.obs;

  void onPlaylist(Playlist playlist) {
    playlistTitle.value = playlist.title;
    playlistType.value = playlist.type.toUpperCase();
    playlistUid.value = playlist.uid;
    playlistEditable.value = playlist.editable;
  }

  Future<void> onPlaylistMusicPlay() async {
    String url =
        'https://sibeux.my.id/cloud-music-player/database/mobile-music-player/api/playlist.php?play_playlist=${playlistUid.value}';
        
    needRebuild.value = true;

    try {
      await http.post(
        Uri.parse(url),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error onPlaylistMusicPlay: $e');
      }
    }
  }

  String get playlistTitleValue {
    return playlistTitle.value;
  }

  String get playlistUidValue {
    return playlistUid.value;
  }
}
