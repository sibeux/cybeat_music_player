import 'package:cybeat_music_player/features/home/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

double colorOnTap = 1;

class HomeFilterScaleTap extends StatefulWidget {
  const HomeFilterScaleTap({
    super.key,
    required this.child,
    required this.filter,
  });

  final Widget child;
  final String filter;

  @override
  HomeFilterScaleTapState createState() => HomeFilterScaleTapState();
}

class HomeFilterScaleTapState extends State<HomeFilterScaleTap>
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
        if (mounted) {
          setState(() => _scaleTransformValue = 1 - animationController.value);
        }
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
    animationController.reverse();
    colorOnTap = 1;
  }

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();

    return GestureDetector(
      onTapDown: (details) {
        _shrinkButtonSize();
      },
      onTapCancel: () => _restoreButtonSize(),
      onTapUp: (details) {
        if (widget.filter != homeController.homeSelectedFilter.value &&
            homeController.homeSelectedFilter.value == '') {
          homeController.onTapFilter(filter: widget.filter);
        } else if (widget.filter ==
                homeController.homeSelectedFilter.value ||
            widget.filter == 'cancel') {
          // Reset filter jika filter yang dipilih sama dengan filter yang dipilih sebelumnya,
          // atau filter yang dipilih adalah cancel.
          homeController.onResetFilter();
        }
        _restoreButtonSize();
      },
      child: SizedBox(
        child: Opacity(
          opacity: colorOnTap,
          child: widget.child,
        ),
      ),
    );
  }
}
