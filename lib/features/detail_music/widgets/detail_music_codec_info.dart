import 'package:cybeat_music_player/features/detail_music/controllers/detail_music_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class DetailMusicCodecInfo extends StatelessWidget {
  const DetailMusicCodecInfo({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final detailMusicController = Get.find<DetailMusicController>();
    return Obx(
      () => Text(
        '${detailMusicController.sampleRate} kHz | ${detailMusicController.bitsPerRawSample} bits | ${detailMusicController.bitRate} kbps',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
