import 'package:cybeat_music_player/components/toast.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class ControlButtons extends StatelessWidget {
  const ControlButtons({
    super.key,
    required this.audioPlayer,
  });

  final AudioPlayer audioPlayer;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        StreamBuilder<LoopMode>(
          stream: audioPlayer.loopModeStream,
          builder: (context, snapshot) {
            return _repeatButton(context, snapshot.data ?? LoopMode.off);
          },
        ),
        IconButton(
          icon: const Icon(
            Icons.skip_previous,
            size: 30,
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
          icon: const Icon(
            Icons.skip_next,
            size: 30,
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
    );
  }

  Widget _shuffleButton(BuildContext context, bool isEnabled) {
    return IconButton(
      icon: isEnabled
          ? const Icon(
              Icons.shuffle,
              color: Colors.lightBlueAccent,
              size: 30,
            )
          : const Icon(
              Icons.shuffle,
              color: Colors.white,
              size: 30,
            ),
      onPressed: () async {
        final enable = !isEnabled;
        if (enable) {
          showToast('Shuffle enabled');

          await audioPlayer.shuffle();
        } else {
          showToast('Shuffle disabled');
        }
        await audioPlayer.setShuffleModeEnabled(enable);
      },
    );
  }

  Widget _playPauseButton(PlayerState? playerState) {
    final processingState = playerState?.processingState;
    final playing = playerState?.playing;
    if (processingState == ProcessingState.loading ||
        processingState == ProcessingState.buffering) {
      return IconButton(
        icon: const Icon(
          Icons.play_circle_filled,
          size: 60,
          color: Colors.grey,
        ),
        onPressed: () {},
      );
    }
    if (playing != true) {
      return IconButton(
        icon: const Icon(Icons.play_circle_fill),
        iconSize: 60.0,
        color: Colors.white,
        onPressed: audioPlayer.play,
      );
    } else if (processingState != ProcessingState.completed) {
      return IconButton(
        icon: const Icon(Icons.pause_circle_filled),
        iconSize: 60.0,
        color: Colors.white,
        onPressed: audioPlayer.pause,
      );
    } else {
      return IconButton(
        icon: const Icon(Icons.replay),
        iconSize: 64.0,
        onPressed: () => audioPlayer.seek(
          Duration.zero,
          index: audioPlayer.effectiveIndices!.first,
        ),
      );
    }
  }

  Widget _repeatButton(BuildContext context, LoopMode loopMode) {
    final icons = [
      const Icon(Icons.repeat, color: Colors.white, size: 30),
      const Icon(Icons.repeat, color: Colors.amber, size: 30),
      const Icon(Icons.repeat_one, color: Colors.lightBlueAccent, size: 30),
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
