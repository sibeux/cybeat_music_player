import 'dart:async';

import 'package:flutter/material.dart';
// import 'dart:developer' as developer;

double colorOnTap = 1;

class ScaleTap extends StatefulWidget {
  const ScaleTap({
    super.key,
    required this.onTap,
    required this.child,
  });

  final Widget child;
  final Function onTap;

  @override
  ScaleTapState createState() => ScaleTapState();
}

class ScaleTapState extends State<ScaleTap>
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
      upperBound: 0.1,
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

    colorOnTap = 0.5;
  }

  void _restoreButtonSize() {
    Future.delayed(
      const Duration(milliseconds: clickAnimationDurationMillis),
      () => animationController.reverse(),
    );
    colorOnTap = 1;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Digunakan untuk menampilkan modal bottom sheet ketika long press
      // onLongPress: () {
      //   HapticFeedback.vibrate();
      //   showAlbumModalBottom(context, widget.playlist);
      // },
      onTap: () => widget.onTap(),
      onPanDown: (details) {
        _shrinkButtonSize();
      },
      // onTapDown: (_) {
      //   developer.log('tapdown');
      //   _shrinkButtonSize();
      //   dateTime1 = DateTime.now();
      // },
      onPanCancel: () {
        // ini masih ada gunanya
        _restoreButtonSize();
      },
      onPanEnd: (_) {
        // ini masih ada gunanya
        _restoreButtonSize();
      },
      onTapCancel: _restoreButtonSize, // ini kemungkinan ada sih
      child: Transform.scale(
        scale: _scaleTransformValue,
        child: SizedBox(
          child: Opacity(
            opacity: colorOnTap,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
