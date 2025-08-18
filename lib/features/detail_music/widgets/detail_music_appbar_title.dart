
import 'package:cybeat_music_player/core/controllers/music_player_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DetailMusicAppbarTitle extends StatelessWidget {
  const DetailMusicAppbarTitle({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final musicPlayerController = Get.find<MusicPlayerController>();

    return Column(
      children: [
        Obx(
          () => Text(
            'PLAYING FROM ${musicPlayerController.currentActivePlaylist.value?.type}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        Obx(
          () => Text(
            // "日本の歌",
            musicPlayerController.currentActivePlaylist.value?.title ?? '',
            style: const TextStyle(
              color: Colors.white,
              overflow: TextOverflow.ellipsis,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        )
      ],
    );
  }
}
