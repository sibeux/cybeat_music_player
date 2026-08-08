import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/get_utils.dart';

class AuthButton extends StatelessWidget {
  const AuthButton({
    super.key,
    required this.authType,
    required this.foreground,
    required this.background,
    required this.isEnable,
    required this.buttonText,
    required this.onPressed,
  });

  final String authType, buttonText;
  final Color foreground, background;
  final bool isEnable;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      child: ElevatedButton(
        onPressed: () {
          if (isEnable) {
            onPressed();
          }
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: foreground,
          backgroundColor: background,
          elevation: 0, // Menghilangkan shadow
          splashFactory: InkRipple.splashFactory,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
          minimumSize: Size(
            double.infinity,
            40.h,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 24.0.w,
            vertical: 12.0.h,
          ),
          child: Text(
            buttonText.capitalizeFirst!,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
