import 'package:cached_network_image/cached_network_image.dart';
import 'package:cybeat_music_player/core/controllers/audio_state_controller.dart';
import 'package:cybeat_music_player/features/album_music/bindings/album_music_binding.dart';
import 'package:cybeat_music_player/features/detail_music/controllers/detail_music_controller.dart';
import 'package:cybeat_music_player/features/detail_music/widgets/detail_music_credits_dialog.dart';
import 'package:cybeat_music_player/features/album_music/screens/album_music_screen.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:marquee/marquee.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

Future<dynamic> detailMusicModal(
  BuildContext context,
  AudioStateController audioStateController,
) {
  final DetailMusicController detailMusicController = Get.find();
  return showMaterialModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(20.r),
      ),
    ),
    clipBehavior: Clip.antiAliasWithSaveLayer,
    builder: (context) => Container(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min, // mencegah layar full
        children: [
          Container(
            margin: EdgeInsets.only(top: 10.h, bottom: 20.h),
            height: 5.h,
            width: 40.w,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: [
                CachedNetworkImage(
                  imageUrl:
                      detailMusicController.currentMediaItem!.artUri.toString(),
                  height: 50.h,
                  width: 50.w,
                  maxHeightDiskCache: 200,
                  maxWidthDiskCache: 200,
                  filterQuality: FilterQuality.low,
                  placeholder: (context, url) => Image.asset(
                    'assets/images/placeholder_cover_music.png',
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.low,
                  ),
                  errorWidget: (context, url, error) {
                    return Image.asset(
                      'assets/images/cybeat_splash.png',
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.low,
                    );
                  },
                ),
                SizedBox(width: 10.w),
                Flexible(
                  fit: FlexFit.tight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 25.h,
                        child: AutoSizeText(
                          detailMusicController.currentMediaItem!.title,
                          maxLines: 1,
                          // Error saat diberi .sp
                          minFontSize: 16,
                          maxFontSize: 16,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                          overflowReplacement: Marquee(
                            text: detailMusicController.currentMediaItem!.title,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                            scrollAxis: Axis.horizontal,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            // spacing end of text
                            blankSpace: 30.w,
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
                      SizedBox(
                        height: 3.h,
                      ),
                      Text(
                        "${detailMusicController.currentMediaItem!.artist} • ${detailMusicController.currentMediaItem!.album}",
                        style: TextStyle(
                          overflow: TextOverflow.ellipsis,
                          fontSize: 13.sp,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          Divider(
            height: 1.h,
            thickness: 1.h,
          ),
          // const SizedBox(height: 20),
          // by default, ListTile has a padding of 16
          Column(
            children: [
              ListTileBottomModal(
                title:
                    'Go to ${detailMusicController.currentActivePlaylist.title.toLowerCase()}',
                icon: Icons.mode_standby_outlined,
                changeColor: false,
                onTap: () {
                  Get.back();
                  if (detailMusicController.isAlbumMusicScreenActive) {
                    Get.back();
                  } else {
                    Get.back();
                    // Tidak pakai Get.toNamed karena beda transisi.
                    Get.to(
                      () => AlbumMusicScreen(),
                      transition: Transition.downToUp,
                      duration: const Duration(milliseconds: 300),
                      binding: AlbumMusicBinding(),
                      popGesture: false,
                      fullscreenDialog: true,
                      id: 1,
                    );
                  }
                },
              ),
              ListTileBottomModal(
                  icon: Icons.my_library_music_outlined,
                  title: "View Credits",
                  changeColor: false,
                  onTap: () {
                    Get.back();
                    detailMusicCreditsDialog(
                      context: context,
                    );
                  }),
            ],
          ),
        ],
      ),
    ),
  );
}

class ListTileBottomModal extends StatelessWidget {
  const ListTileBottomModal({
    super.key,
    required this.icon,
    required this.title,
    required this.changeColor,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final bool changeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 0.h),
      minVerticalPadding: 5.h,
      leading: Icon(
        icon,
        color: changeColor ? HexColor('#ac8bc9') : Colors.black,
      ),
      title: Text(title),
      // trailing: const Icon(Icons.arrow_forward_ios),
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 14.sp,
        fontWeight: FontWeight.bold,
      ),
      onTap: onTap,
    );
  }
}
