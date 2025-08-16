import 'dart:async';
import 'package:cybeat_music_player/common/utils/colorize_terminal.dart';
import 'package:cybeat_music_player/controller/music_play/progress_music_controller.dart';
import 'package:cybeat_music_player/core/models/playlist.dart';
import 'package:cybeat_music_player/core/controllers/audio_state_provider.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class PlaylistPlayController extends GetxController {
  var playlistTitle = ''.obs;
  var playlistType = ''.obs;
  var playlistUid = ''.obs;
  var playlistEditable = ''.obs;

  var needRebuild = false.obs;
  var isAzlistviewScreenActive = false.obs;

  var currentPlaylistPlay = RxList<Playlist>([]);

  void onPlaylist(Playlist playlist) {
    playlistTitle.value = playlist.title;
    playlistType.value = playlist.type.toUpperCase();
    playlistUid.value = playlist.uid;
    playlistEditable.value = playlist.editable;

    // Setiap album/playlist yang di-play akan disimpan di currentPlaylistPlay.
    // Isinya hanya 1, yaitu album/playlist yang sedang di-play.
    if (currentPlaylistPlay.isNotEmpty) {
      currentPlaylistPlay[0] = playlist;
    } else {
      currentPlaylistPlay.add(playlist);
    }
  }

  Future<void> onPlaylistMusicPlay({
    required AudioState audioState,
  }) async {
    String url =
        'https://sibeux.my.id/cloud-music-player/database/mobile-music-player/api/playlist.php?play_playlist=${playlistUid.value}';

    needRebuild.value = true;

    try {
      await http.post(
        Uri.parse(url),
      );

      Get.put(ProgressMusicController(player: audioState.player));
    } catch (e) {
        logError('Error onPlaylistMusicPlay: $e');
    }
  }

  String get playlistTitleValue {
    return playlistTitle.value;
  }

  String get playlistUidValue {
    return playlistUid.value;
  }
}
