import 'package:cached_network_image/cached_network_image.dart';
import 'package:cybeat_music_player/controller/music_state_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

class CoverDetailMusic extends StatelessWidget {
  const CoverDetailMusic({
    super.key,
    required this.player,
  });

  final AudioPlayer player;

  @override
  Widget build(BuildContext context) {
    final musicController = Get.put(MusicStateController(player: player));

    return Obx(
      () => Expanded(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: CachedNetworkImage(
              imageUrl: musicController.cover.value,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.low,
              maxHeightDiskCache: 500,
              maxWidthDiskCache: 500,
              progressIndicatorBuilder: (context, url, progress) {
                return Image.asset(
                  'assets/images/placeholder_cover_music.png',
                  fit: BoxFit.cover,
                );
              },
              errorWidget: (context, exception, stackTrace) {
                return Image.asset(
                  'assets/images/placeholder_cover_music.png',
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
