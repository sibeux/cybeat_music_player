import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cybeat_music_player/controller/music_state_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CoverBlur extends StatelessWidget {
  const CoverBlur({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final musicController = Get.find<MusicStateController>();

    return Obx(
      () => ImageFiltered(
        imageFilter: ImageFilter.blur(
          sigmaY: 35,
          sigmaX: 35,
        ),
        child: CachedNetworkImage(
          imageUrl: musicController.cover.value,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.low,
          color: Colors.black.withOpacity(0.5),
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
