import 'package:cybeat_music_player/features/home/controllers/home_controller.dart';
import 'package:cybeat_music_player/controller/music_play/music_state_controller.dart';
import 'package:cybeat_music_player/core/controllers/music_player_controller.dart';
import 'package:cybeat_music_player/core/models/playlist.dart';
import 'package:cybeat_music_player/core/controllers/audio_state_controller.dart';
import 'package:cybeat_music_player/screens/azlistview/music_screen.dart';
import 'package:cybeat_music_player/features/home/widgets/home_grid/home_one_grid_layout.dart';
import 'package:cybeat_music_player/features/home/widgets/home_grid/home_three_grid_layout.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeListGrid extends StatelessWidget {
  const HomeListGrid({
    super.key,
    required this.playlist,
    required this.audioStateController,
  });

  final Playlist playlist;
  final AudioStateController audioStateController;

  @override
  Widget build(BuildContext context) {
    final musicPlayerController = Get.find<MusicPlayerController>();
    final musicStateController = Get.find<MusicStateController>();
    final homeAlbumGridController = Get.find<HomeController>();

    return GestureDetector(
      onTap: () {
        if (musicPlayerController.currentActivePlaylist.value?.title !=
                playlist.title ||
            musicPlayerController.currentActivePlaylist.value?.title == "") {
          audioStateController.clear();
          musicPlayerController.pauseMusic();
          musicStateController.onClose();
          musicPlayerController.clearCurrentMediaItem();
          audioStateController.init(playlist);
          musicPlayerController.setActivePlaylist(playlist);
        }

        Get.to(
          () => AzListMusicScreen(
            audioState: audioStateController,
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
        child: Obx(
          () => homeAlbumGridController.countGrid.value == 1
              ? OneGridLayout(
                  playlist: playlist,
                  musicPlayerController: musicPlayerController,
                )
              : ThreeGridLayout(
                  playlist: playlist,
                  musicPlayerController: musicPlayerController,
                ),
        ),
      ),
    );
  }
}
