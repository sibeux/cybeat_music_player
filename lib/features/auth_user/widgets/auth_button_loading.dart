import 'package:cybeat_music_player/common/utils/color_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hexcolor/hexcolor.dart';

class AuthButtonLoading extends StatelessWidget {
  const AuthButtonLoading({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      child: ElevatedButton(
        onPressed: () {
          // Do nothing
        },
        style: ElevatedButton.styleFrom(
          elevation: 0, // Menghilangkan shadow
          backgroundColor: HexColor('#fefffe'),
          splashFactory: InkRipple.splashFactory,
          side: BorderSide(
            color: ColorPalette().primary,
            strokeAlign: BorderSide.strokeAlignCenter,
            width: 2.w,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
          minimumSize: Size(
            double.infinity,
            40.h,
          ),
        ),
        child: Center(
          child: Transform.scale(
            scale: 0.7,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                ColorPalette().primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
