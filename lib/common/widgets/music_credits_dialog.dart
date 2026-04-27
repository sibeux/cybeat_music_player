import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';

void showMusicCreditsDialog({
  required BuildContext context,
  required MediaItem currentMediaItem,
}) {
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
          Text(
                currentMediaItem.title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
          SizedBox(
            height: 15.h,
          ),
          // Text(
          //   "Performed by",
          //   style: TextStyle(
          //     fontSize: 14.sp,
          //     fontWeight: FontWeight.bold,
          //     color: Colors.black,
          //   ),
          // ),
          // SizedBox(
          //   height: 3.h,
          // ),
          // Obx(() => Text(
          //       currentMediaItem!.artist ?? '--',
          //       maxLines: 3,
          //       style: TextStyle(
          //         overflow: TextOverflow.ellipsis,
          //         fontSize: 14.sp,
          //         fontWeight: FontWeight.w400,
          //         color: Colors.black.withValues(alpha: 0.6),
          //       ),
          //     )),
          // SizedBox(
          //   height: 15.h,
          // ),
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
          Text(
                currentMediaItem.album ?? '--',
                maxLines: 3,
                style: TextStyle(
                  overflow: TextOverflow.ellipsis,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.black.withValues(alpha: 0.6),
                ),
              ),
          SizedBox(
            height: 15.h,
          ),
          Text(
            "Disc",
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
                currentMediaItem.extras!['disc_number'].toString(),
                maxLines: 3,
                style: TextStyle(
                  overflow: TextOverflow.ellipsis,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.black.withValues(alpha: 0.6),
                ),
              ),
          SizedBox(
            height: 15.h,
          ),
          Text(
            "Uploader",
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
                currentMediaItem.extras?['uploader']
                        .toString()
                        .split('@')
                        .first
                        .capitalize ??
                    'Cybeat',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.black.withValues(alpha: 0.6),
                ),
              ),
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
          Text(
                currentMediaItem.extras?['original_source'],
                maxLines: 1,
                style: TextStyle(
                  overflow: TextOverflow.ellipsis,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.black.withValues(alpha: 0.6),
                ),
              ),
          SizedBox(
            height: 15.h,
          ),
          Text(
            "Cached From",
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
                currentMediaItem.extras?['is_cached']
                    ? currentMediaItem.extras!['url']
                            .toString()
                            .contains('cdncloudflare/')
                        ? "Cloudflare CDN"
                        : currentMediaItem.extras!['url']
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
