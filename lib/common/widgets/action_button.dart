import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    required this.title,
    required this.hexTextColor,
    required this.hexBackColor,
    required this.onPressed,
  });

  final String title;
  final Color hexTextColor;
  final Color hexBackColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 47.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: hexBackColor,
          elevation: 0, // Menghilangkan shadow
          splashFactory: InkRipple.splashFactory,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 10.0.w,
            vertical: 4.0.h,
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: hexTextColor,
            ),
          ),
        ),
      ),
    );
  }
}
