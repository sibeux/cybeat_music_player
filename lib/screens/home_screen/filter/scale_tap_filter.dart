import 'dart:async';
import 'package:flutter/material.dart';

double colorOnTap = 1;

class ScaleTapFilter extends StatefulWidget {
  const ScaleTapFilter({
    super.key, required this.child,
  });

  final Widget child;

  @override
  ScaleTapFilterState createState() => ScaleTapFilterState();
}

class ScaleTapFilterState extends State<ScaleTapFilter>
    with SingleTickerProviderStateMixin {
  static const clickAnimationDurationMillis = 100;
  // ignore: unused_field
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
      onPanDown: (details) {
        _shrinkButtonSize();
      },
      onPanCancel: () {
        // ini masih ada gunanya
        _restoreButtonSize();
      },
      onPanEnd: (_) {
        // ini masih ada gunanya
        _restoreButtonSize();
      },
      onTapCancel: _restoreButtonSize, // ini kemungkinan ada sih
      child: SizedBox(
        child: Opacity(
          opacity: colorOnTap,
          child: widget.child,
        ),
      ),
    );
  }
}
