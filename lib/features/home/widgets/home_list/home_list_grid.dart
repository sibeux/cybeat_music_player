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
    required this.album,
    required this.audioStateController,
  });

  final Album album;
  final AudioStateController audioStateController;

  @override
  Widget build(BuildContext context) {
    final musicPlayerController = Get.find<MusicPlayerController>();
    final homeController = Get.find<HomeController>();

    return GestureDetector(
      onTap: () {
        homeController.openAlbum(
            album: album, musicPlayerController: musicPlayerController);
      },
      child: Container(
        alignment: Alignment.centerLeft,
        child: Obx(
          () => homeController.albumCountGrid.value == 1
              ? OneGridLayout(
                  playlist: album,
                  musicPlayerController: musicPlayerController,
                )
              : ThreeGridLayout(
                  album: album,
                  musicPlayerController: musicPlayerController,
                ),
        ),
      ),
    );
  }
}
