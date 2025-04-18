import 'dart:async';

import 'package:cybeat_music_player/models/playlist.dart';
import 'package:cybeat_music_player/providers/audio_state.dart';
import 'package:cybeat_music_player/widgets/home_widget/list_album/grid_playlist_album.dart';
import 'package:cybeat_music_player/widgets/home_widget/list_album/show_album_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'dart:developer' as developer;

double colorOnTap = 1;

class ScaleTapPlaylist extends StatefulWidget {
  const ScaleTapPlaylist({
    super.key,
    required this.playlist,
    required this.audioState,
  });

  final Playlist playlist;
  final AudioState audioState;

  @override
  ScaleTapPlaylistState createState() => ScaleTapPlaylistState();
}

class ScaleTapPlaylistState extends State<ScaleTapPlaylist>
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
    onTap() {
      // print('tapped');
    }

    DateTime dateTime1 = DateTime.now();

    return GestureDetector(
      onLongPress: () {
        HapticFeedback.vibrate();
        showAlbumModalBottom(context, widget.playlist);
      },
      // onTap: () {
      //   developer.log('tapped');
      //   _shrinkButtonSize();
      //   _restoreButtonSize();
      // },
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
      onTapUp: (_) {
        // sejauh ini nggak ada gunanya
        _restoreButtonSize();
        Duration difference = DateTime.now().difference(dateTime1);
        if (difference.inMilliseconds < 500) {
          // UX delight: Adding this delay let's the user see the tap
          // animation before the tap action is performed instead of instantly
          // performing the action. This is great in cases where the tap action
          // triggers navigation. If we remove this delay, the app would navigate
          // instantly and hence the user wouldn't be able to see the button
          // animation in action.
          Future.delayed(
            const Duration(milliseconds: clickAnimationDurationMillis * 2),
            () => onTap.call(),
          );
        }
      },
      onTapCancel: _restoreButtonSize, // ini kemungkinan ada sih
      child: Transform.scale(
        scale: _scaleTransformValue,
        child: SizedBox(
          child: Opacity(
            opacity: colorOnTap,
            child: GridPlaylistAlbum(
              playlist: widget.playlist,
              audioState: widget.audioState,
            ),
          ),
        ),
      ),
    );
  }
}
