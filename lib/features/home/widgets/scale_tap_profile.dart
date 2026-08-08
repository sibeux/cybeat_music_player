import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ScaleTapProfile extends StatefulWidget {
  const ScaleTapProfile({
    super.key,
    required this.onTap,
  });

  final Function()? onTap;

  @override
  ScaleTapSortState createState() => ScaleTapSortState();
}

class ScaleTapSortState extends State<ScaleTapProfile>
    with SingleTickerProviderStateMixin {
  static const clickAnimationDurationMillis = 100;
  double _scaleTransformValue = 1;

  // needed for the "click" tap effect
  late final AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: clickAnimationDurationMillis),
      lowerBound: 0.0,
      upperBound: 0.2,
    )..addListener(() {
        setState(() => _scaleTransformValue = 1 - animationController.value);
      });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  void _shrinkButtonSize() {
    animationController.forward();
  }

  void _restoreButtonSize() {
    Future.delayed(
      const Duration(milliseconds: clickAnimationDurationMillis),
      () => animationController.reverse(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanDown: (details) {
        _shrinkButtonSize();
      },
      onPanCancel: () {
        _restoreButtonSize();
      },
      onPanEnd: (_) {
        _restoreButtonSize();
      },
      onTapUp: (_) {
        _restoreButtonSize();
        if (widget.onTap != null) {
          widget.onTap!();
        }
      },
      onTapCancel: _restoreButtonSize, // ini kemungkinan ada sih
      child: Transform.scale(
        scale: _scaleTransformValue,
        child: SizedBox(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100.r),
            child: Image(
              image: AssetImage('assets/images/cybeat_splash.png'),
              width: 40.w,
              height: 40.h,
            ),
          ),
        ),
      ),
    );
  }
}
