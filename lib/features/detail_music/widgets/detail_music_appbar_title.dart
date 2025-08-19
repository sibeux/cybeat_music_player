import 'package:cybeat_music_player/core/controllers/music_player_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class DetailMusicAppbarTitle extends StatelessWidget {
  const DetailMusicAppbarTitle({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final musicPlayerController = Get.find<MusicPlayerController>();
    // Agar reactive, jangan dikasih .value saat assign ke variable.
    final playlist = musicPlayerController.currentActivePlaylist;
    return Column(
      children: [
        Obx(
          () => Text(
            'PLAYING FROM ${playlist.value?.type.toUpperCase()}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(
          height: 5.h,
        ),
        Obx(
          () => Text(
            // "日本の歌",
            playlist.value?.title ?? '',
            style: TextStyle(
              color: Colors.white,
              overflow: TextOverflow.ellipsis,
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        )
      ],
    );
  }
}
