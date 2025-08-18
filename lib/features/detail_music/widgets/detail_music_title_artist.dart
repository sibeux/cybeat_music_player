import 'package:auto_size_text/auto_size_text.dart';
import 'package:cybeat_music_player/features/detail_music/controllers/detail_music_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:marquee/marquee.dart';

class DetailMusicTitleArtist extends StatelessWidget {
  const DetailMusicTitleArtist({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final detailMusicController = Get.find<DetailMusicController>();

    return Obx(
      () => Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 30.h,
              child: AutoSizeText(
                detailMusicController.currentMediaItem!.title,
                minFontSize: 18,
                maxFontSize: 18,
                maxLines: 1,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.values[5],
                ),
                overflowReplacement: Marquee(
                  text: detailMusicController.currentMediaItem!.title,
                  style: TextStyle(
                    fontSize: 18.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.values[5],
                  ),
                  scrollAxis: Axis.horizontal,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // spacing end of text
                  blankSpace: 30,
                  // second needed before slide again
                  pauseAfterRound: const Duration(seconds: 0),
                  // text gonna slide first time after this second
                  startAfter: const Duration(seconds: 2),
                  decelerationCurve: Curves.easeOut,
                  // speed of slide text
                  velocity: 35,
                  accelerationCurve: Curves.linear,
                ),
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            SizedBox(
              height: 30,
              child: AutoSizeText(
                detailMusicController.currentMediaItem!.artist ?? '',
                minFontSize: 14,
                maxFontSize: 14,
                maxLines: 1,
                style: const TextStyle(
                  // fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.normal,
                ),
                overflowReplacement: Marquee(
                  text: detailMusicController.currentMediaItem!.artist ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.normal,
                  ),
                  scrollAxis: Axis.horizontal,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // spacing end of text
                  blankSpace: 30,
                  // second needed before slide again
                  pauseAfterRound: const Duration(seconds: 0),
                  // text gonna slide first time after this second
                  startAfter: const Duration(seconds: 2),
                  decelerationCurve: Curves.easeOut,
                  // speed of slide text
                  velocity: 35,
                  accelerationCurve: Curves.linear,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
