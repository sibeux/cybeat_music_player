import 'package:cybeat_music_player/common/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_audio/just_audio.dart';

class DetailMusicControlButtons extends StatelessWidget {
  const DetailMusicControlButtons({
    super.key,
    required this.audioPlayer,
  });

  final AudioPlayer audioPlayer;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 80.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          StreamBuilder<LoopMode>(
            stream: audioPlayer.loopModeStream,
            builder: (context, snapshot) {
              return _repeatButton(context, snapshot.data ?? LoopMode.off);
            },
          ),
          IconButton(
            icon: Icon(
              Icons.skip_previous,
              size: 30.sp,
              color: Colors.white,
            ),
            onPressed: () {
              audioPlayer.seekToPrevious();
              audioPlayer.play();
            },
          ),
          StreamBuilder<PlayerState>(
            stream: audioPlayer.playerStateStream,
            builder: (_, snapshot) {
              final playerState = snapshot.data;
              return _playPauseButton(playerState);
            },
          ),
          IconButton(
            icon: Icon(
              Icons.skip_next,
              size: 30.sp,
              color: Colors.white,
            ),
            onPressed: () {
              audioPlayer.seekToNext();
              audioPlayer.play();
            },
          ),
          StreamBuilder<bool>(
            stream: audioPlayer.shuffleModeEnabledStream,
            builder: (context, snapshot) {
              return _shuffleButton(context, snapshot.data ?? false);
            },
          ),
        ],
      ),
    );
  }

  Widget _shuffleButton(BuildContext context, bool isEnabled) {
    return IconButton(
      icon: isEnabled
          ? Icon(
              Icons.shuffle,
              color: Colors.lightBlueAccent,
              size: 30.sp,
            )
          : Icon(
              Icons.shuffle,
              color: Colors.white,
              size: 30.sp,
            ),
      onPressed: () async {
        final enable = !isEnabled;
        audioPlayer.setShuffleModeEnabled(enable);
        if (enable) {
          showToast('Shuffle enabled');
          await audioPlayer.shuffle();
        } else {
          showToast('Shuffle disabled');
        }
      },
    );
  }

  Widget _playPauseButton(PlayerState? playerState) {
    final processingState = playerState?.processingState;
    final playing = playerState?.playing;
    if (processingState == ProcessingState.loading ||
        processingState == ProcessingState.buffering) {
      return IconButton(
        icon: Icon(
          Icons.play_circle_filled,
          size: 60.sp,
          color: Colors.grey,
        ),
        onPressed: () {},
      );
    }
    if (playing != true) {
      return IconButton(
        icon: const Icon(Icons.play_circle_fill),
        iconSize: 60.0.sp,
        color: Colors.white,
        onPressed: audioPlayer.play,
      );
    } else if (processingState != ProcessingState.completed) {
      return IconButton(
        icon: const Icon(Icons.pause_circle_filled),
        iconSize: 60.0.sp,
        color: Colors.white,
        onPressed: audioPlayer.pause,
      );
    } else {
      return IconButton(
        icon: const Icon(Icons.replay),
        iconSize: 60.0.sp,
        color: Colors.white,
        onPressed: () => audioPlayer.seek(
          Duration.zero,
          index: audioPlayer.effectiveIndices.first,
        ),
      );
    }
  }

  Widget _repeatButton(BuildContext context, LoopMode loopMode) {
    final icons = [
      Icon(Icons.repeat, color: Colors.white, size: 30.sp),
      Icon(Icons.repeat, color: Colors.amber, size: 30.sp),
      Icon(Icons.repeat_one, color: Colors.redAccent, size: 30.sp),
    ];

    final msg = [
      'Repeat off',
      'Repeat all',
      'Repeat one',
    ];

    const cycleModes = [
      LoopMode.off,
      LoopMode.all,
      LoopMode.one,
    ];
    final index = cycleModes.indexOf(loopMode);
    return IconButton(
      icon: icons[index],
      onPressed: () {
        showToast(msg[(index + 1) % msg.length]);
        audioPlayer.setLoopMode(
            cycleModes[(cycleModes.indexOf(loopMode) + 1) % cycleModes.length]);
      },
    );
  }
}
