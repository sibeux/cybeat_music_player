import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cybeat_music_player/features/detail_music/controllers/detail_music_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DetailMusicBackgroundBlur extends StatelessWidget {
  const DetailMusicBackgroundBlur({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final detailMusicController = Get.find<DetailMusicController>();

    return Obx(
      () => ImageFiltered(
        imageFilter: ImageFilter.blur(
          sigmaY: 35,
          sigmaX: 35,
        ),
        child: CachedNetworkImage(
          imageUrl: detailMusicController.currentMediaItem!.artUri.toString(),
          fit: BoxFit.cover,
          filterQuality: FilterQuality.low,
          color: Colors.black.withValues(alpha: 0.5),
          memCacheHeight: 20,
          memCacheWidth: 20,
          colorBlendMode: BlendMode.darken,
          progressIndicatorBuilder: (context, url, progress) => Container(
            color: Colors.black,
          ),
          errorWidget: (context, exception, stackTrace) {
            return Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    // Color.fromARGB(255, 126, 248, 60),
                    // Color.fromARGB(255, 253, 123, 123),
                    Colors.black,
                    Colors.black,
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
