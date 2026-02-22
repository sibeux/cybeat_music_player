import 'package:cybeat_music_player/features/home/controllers/home_controller.dart';
import 'package:cybeat_music_player/core/controllers/music_player_controller.dart';
import 'package:cybeat_music_player/core/models/album.dart';
import 'package:cybeat_music_player/core/controllers/audio_state_controller.dart';
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

  final Album playlist;
  final AudioStateController audioStateController;

  @override
  Widget build(BuildContext context) {
    final musicPlayerController = Get.find<MusicPlayerController>();
    final homeController = Get.find<HomeController>();

    return GestureDetector(
      onTap: () {
        final String albumId =
            musicPlayerController.currentActivePlaylist.value?.uid ?? "";
        final String albumType =
            musicPlayerController.currentActivePlaylist.value?.type ?? "";
            // 1 - album
            // 1 - playlist
        if ((albumId != playlist.uid) || (albumType != playlist.type)) {
          homeController.getDominantColorAlbum(playlist: playlist);
          audioStateController.clear();
          musicPlayerController.killMusic();
          musicPlayerController.clearCurrentMediaItem();
          audioStateController.init(playlist);
          musicPlayerController.setActivePlaylist(playlist);
        }
        Get.toNamed(
          '/album_music',
          id: 1,
        );
      },
      child: Container(
        alignment: Alignment.centerLeft,
        child: Obx(
          () => homeController.albumCountGrid.value == 1
              ? OneGridLayout(
                  playlist: playlist,
                  musicPlayerController: musicPlayerController,
                )
              : ThreeGridLayout(
                  album: playlist,
                  musicPlayerController: musicPlayerController,
                ),
        ),
      ),
    );
  }
}
