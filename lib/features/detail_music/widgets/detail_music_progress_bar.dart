import 'package:cybeat_music_player/features/detail_music/controllers/detail_music_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';

class DetailMusicProgressBarMusic extends StatelessWidget {
  const DetailMusicProgressBarMusic({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final DetailMusicController detailMusicController = Get.find();

    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 1.h,
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 5),
            overlayShape: RoundSliderOverlayShape(overlayRadius: 10),
          ),
          child: Obx(
            () => Slider(
              value: detailMusicController.sliderValue,
              secondaryTrackValue: detailMusicController.secondarySliderValue,
              activeColor: HexColor('#fefffe'),
              secondaryActiveColor: HexColor('#ac8bc9'),
              inactiveColor: HexColor('#726878'),
              // --- MODIFIKASI ONCHANGED DAN TAMBAHKAN CALLBACK BARU ---
              onChangeStart: (value) {
                detailMusicController.onChangeStartSlider();
              },
              onChanged: (value) {
                detailMusicController.onChangedSlider(value);
              },
              onChangeEnd: (value) async {
                detailMusicController.onChangeEndSlider(value);
              },
            ),
          ),
        ),
        SizedBox(height: 3.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  detailMusicController
                      .positionText, // Teks ini sekarang juga akan update saat dragging
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                  ),
                ),
                Text(
                  detailMusicController.durationText,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
