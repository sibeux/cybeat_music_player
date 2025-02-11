import 'package:cybeat_music_player/controller/playing_state_controller.dart';
import 'package:cybeat_music_player/controller/playlist_play_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ScaleTapButtonNewPlaylist extends StatefulWidget {
  const ScaleTapButtonNewPlaylist({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  ScaleTapButtonNewPlaylistState createState() =>
      ScaleTapButtonNewPlaylistState();
}

class ScaleTapButtonNewPlaylistState extends State<ScaleTapButtonNewPlaylist>
    with SingleTickerProviderStateMixin {
  static const clickAnimationDurationMillis = 100;
  double _scaleTransformValue = 1;
  double colorOnTap = 1;

  PlaylistPlayController playlistPlayController = Get.find();
  PlayingStateController playingStateController = Get.find();

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
      child: Transform.scale(
        scale: _scaleTransformValue,
        child: Opacity(
          opacity: colorOnTap,
          child: widget.child,
        ),
      ),
    );
  }
}
