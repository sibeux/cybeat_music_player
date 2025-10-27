import 'package:cybeat_music_player/features/detail_music/controllers/detail_music_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

class DetailMusicFavoriteButton extends StatelessWidget {
  const DetailMusicFavoriteButton({
    super.key,
    required this.player,
  });

  final AudioPlayer player;

  @override
  Widget build(BuildContext context) {
    final DetailMusicController detailMusicController =
        Get.find<DetailMusicController>();
    return Transform.scale(
      scale: 1.5,
      child: GestureDetector(
        onTap: () {
          detailMusicController.setfavorite();
        },
        child: Obx(() {
          // Rebuild widget saat button ditekan.
          detailMusicController.uiTrigger.value; // biar ke-track
          return detailMusicController.currentMediaItem!.extras?['favorite'] ==
                  '1'
              ? Icon(
                  Icons.star_rounded,
                  color: Colors.amber,
                  size: 30.sp,
                )
              : Icon(
                  Icons.star_outline_rounded,
                  color: Colors.white,
                  size: 30.sp,
                );
        }),
      ),
    );
  }
}
