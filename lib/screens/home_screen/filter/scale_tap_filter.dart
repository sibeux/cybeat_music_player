import 'dart:async';
import 'package:cybeat_music_player/controller/filter_album_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

double colorOnTap = 1;

class ScaleTapFilter extends StatefulWidget {
  const ScaleTapFilter({
    super.key,
    required this.child,
    required this.filter,
  });

  final Widget child;
  final String filter;

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
    final filterAlbumCOntroller = Get.put(FilterAlbumController());

    return GestureDetector(
      onTapDown: (details) {
        _shrinkButtonSize();
      },
      onTapCancel: () => _restoreButtonSize(),
      onTapUp: (details) {
        if (widget.filter != filterAlbumCOntroller.selectedFilter.value &&
            filterAlbumCOntroller.selectedFilter.value == '') {
          filterAlbumCOntroller.onTapFilter(filter: widget.filter);
        } else if (widget.filter ==
                filterAlbumCOntroller.selectedFilter.value ||
            widget.filter == 'cancel') {
          filterAlbumCOntroller.onResetFilter();
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
