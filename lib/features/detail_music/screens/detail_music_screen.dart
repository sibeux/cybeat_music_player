import 'package:cybeat_music_player/core/controllers/audio_state_controller.dart';
import 'package:cybeat_music_player/features/detail_music/widgets/detail_music_appbar_title.dart';
import 'package:cybeat_music_player/features/detail_music/widgets/detail_music_codec_info.dart';
import 'package:cybeat_music_player/features/detail_music/widgets/detail_music_cover_image.dart';
import 'package:cybeat_music_player/features/detail_music/widgets/detail_music_favorite_button.dart';
import 'package:cybeat_music_player/features/detail_music/widgets/detail_music_control_buttons.dart';
import 'package:cybeat_music_player/features/detail_music/widgets/detail_music_modal.dart';
import 'package:cybeat_music_player/features/detail_music/widgets/detail_music_title_artist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../widgets/detail_music_background_blur.dart';
import '../widgets/detail_music_progress_bar.dart';

class DetailMusicScreen extends StatelessWidget {
  const DetailMusicScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final audioStateController = Get.find<AudioStateController>();
    return Stack(
      children: [
        Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black,
            ),
            const SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: ClipRRect(
                // ClipRRect is used to clip the image to a rounded rectangle
                // awikwok banget nih, kalo ga pake ClipRRect, gambarnya bakal melebar melebihi ukuran layar.
                child: DetailMusicBackgroundBlur(),
              ),
            )
          ],
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            centerTitle: true,
            toolbarHeight: 70.h,
            leading: IconButton(
              icon: Icon(
                Icons.keyboard_arrow_down,
                size: 35.sp,
                color: Colors.white,
              ),
              onPressed: () {
                Get.back();
              },
            ),
            title: const DetailMusicAppbarTitle(),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.more_vert,
                  size: 35.sp,
                  color: Colors.white,
                ),
                onPressed: () {
                  detailMusicModal(context, audioStateController);
                },
              ),
            ],
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.w),
            child: Column(
              children: [
                // cover kecil
                const DetailMusicCoverImage(),
                SizedBox(
                  height: 30.h,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Row(
                    children: [
                      const DetailMusicTitleArtist(),
                      SizedBox(
                        width: 15.w,
                      ),
                      DetailMusicFavoriteButton(
                        player: audioStateController.activePlayer.value!,
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 20.h,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: DetailMusicCodecInfo(),
                ),
                SizedBox(
                  height: 25.h,
                ),
                // to create one straight line
                // child: Divider(
                //   color: Colors.white,
                //   thickness: 1,
                DetailMusicProgressBarMusic(),
                SizedBox(
                  height: 15.h,
                ),
                Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: DetailMusicControlButtons(
                      audioPlayer: audioStateController.activePlayer.value!),
                ),
                SizedBox(
                  // buat ngatur jarak antara control buttons
                  // dan bottom navigation
                  height: 35.h,
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
