import 'package:cybeat_music_player/controller/home_album_grid_controller.dart';
import 'package:cybeat_music_player/controller/music_play/music_state_controller.dart';
import 'package:cybeat_music_player/controller/music_play/playing_state_controller.dart';
import 'package:cybeat_music_player/controller/playlist_play_controller.dart';
import 'package:cybeat_music_player/core/models/playlist.dart';
import 'package:cybeat_music_player/core/controllers/audio_state_provider.dart';
import 'package:cybeat_music_player/core/controllers/music_state_provider.dart';
import 'package:cybeat_music_player/screens/azlistview/music_screen.dart';
import 'package:cybeat_music_player/widgets/home_widget/grid/one_grid_layout.dart';
import 'package:cybeat_music_player/widgets/home_widget/grid/three_grid_layout.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class GridPlaylistAlbum extends StatelessWidget {
  const GridPlaylistAlbum({
    super.key,
    required this.playlist,
    required this.audioState,
  });

  final Playlist playlist;
  final AudioState audioState;

  @override
  Widget build(BuildContext context) {
    final playlistPlayController = Get.find<PlaylistPlayController>();
    final playingStateController = Get.put(PlayingStateController());
    final musicStateController = Get.find<MusicStateController>();
    final homeAlbumGridController = Get.find<HomeAlbumGridController>();

    return GestureDetector(
      onTap: () {
        if (playlistPlayController.playlistTitleValue != playlist.title ||
            playlistPlayController.playlistTitleValue == "") {
          audioState.clear();
          playingStateController.pause();
          musicStateController.onClose();
          context.read<MusicState>().clear();
          audioState.init(playlist);
          playlistPlayController.onPlaylist(playlist);
        }

        Get.to(
          () => AzListMusicScreen(
            audioState: audioState,
          ),
          transition: Transition.leftToRightWithFade,
          duration: const Duration(milliseconds: 300),
          popGesture: false,
          fullscreenDialog: true,
          id: 1,
        );
      },
      child: Container(
        alignment: Alignment.centerLeft,
        child: Obx(() => 
        homeAlbumGridController.countGrid.value == 1 ?
            OneGridLayout(
              playlist: playlist,
              playlistPlayController: playlistPlayController,
            ) :
            ThreeGridLayout(
              playlist: playlist,
              playlistPlayController: playlistPlayController,
            ),
        ),
      ),
    );
  }
}
