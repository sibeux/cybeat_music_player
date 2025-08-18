import 'package:cybeat_music_player/features/detail_music/controllers/detail_music_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';

void detailMusicCreditsDialog({
  required BuildContext context,
}) {
  final DetailMusicController detailMusicController = Get.find();
  Get.dialog(
    name: 'musicCreditsDialog',
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    transitionDuration: const Duration(milliseconds: 100),
    AlertDialog(
      backgroundColor: HexColor('#fefffe'),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.r),
      ),
      actionsPadding: EdgeInsets.only(top: 10.h),
      contentPadding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 20.h,
        bottom: 10.h,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min, // mencegah layar full
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Credits',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black.withValues(alpha: 0.8),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Get.back();
                },
              ),
            ],
          ),
          SizedBox(
            height: 10.h,
          ),
          Divider(
            height: 0.4.h,
            thickness: 0.4.h,
            color: Colors.black.withValues(alpha: 0.4),
          ),
          SizedBox(
            height: 15.h,
          ),
          Obx(() => Text(
                detailMusicController.currentMediaItem!.title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              )),
          SizedBox(
            height: 15.h,
          ),
          Text(
            "Performed by",
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(
            height: 3.h,
          ),
          Obx(() => Text(
                detailMusicController.currentMediaItem!.artist ?? '--',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.black.withValues(alpha: 0.6),
                ),
              )),
          SizedBox(
            height: 15.h,
          ),
          Text(
            "Album",
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(
            height: 3.h,
          ),
          Obx(() => Text(
                detailMusicController.currentMediaItem!.album ?? '--',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.black.withValues(alpha: 0.6),
                ),
              )),
          SizedBox(
            height: 15.h,
          ),
          Text(
            "Original Source",
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(
            height: 3.h,
          ),
          Obx(() => Text(
                detailMusicController
                    .currentMediaItem!.extras?['original_source'],
                maxLines: 1,
                style: TextStyle(
                  overflow: TextOverflow.ellipsis,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.black.withValues(alpha: 0.6),
                ),
              )),
          SizedBox(
            height: 15.h,
          ),
          Text(
            "Cache Source",
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(
            height: 3.h,
          ),
          Text(
            detailMusicController.currentMediaItem!.extras?['is_cached']
                ? detailMusicController.currentMediaItem!.extras!['url']
                : '—',
            maxLines: 1,
            style: TextStyle(
              overflow: TextOverflow.ellipsis,
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: Colors.black.withValues(alpha: 0.6),
            ),
          ),
          SizedBox(
            height: 10.h,
          ),
        ],
      ),
    ),
  );
}
