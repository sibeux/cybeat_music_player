import 'package:cybeat_music_player/controller/playlist_play_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

class AppbarTitle extends StatelessWidget {
  const AppbarTitle({
    super.key,
    required this.player,
  });

  final AudioPlayer? player;

  @override
  Widget build(BuildContext context) {
    final playlistPlayController = Get.put(PlaylistPlayController());

    return Column(
      children: [
        Obx(
          () => Text(
            'PLAYING FROM ${playlistPlayController.playlistType.value}',
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
            playlistPlayController.playlistTitle.value,
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
