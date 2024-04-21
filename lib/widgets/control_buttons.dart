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
        IconButton(
          icon: const Icon(
            Icons.repeat,
            size: 30,
            color: Colors.white,
          ),
          onPressed: () {},
        ),
        const SizedBox(
          width: 10,
        ),
        IconButton(
          icon: const Icon(
            Icons.skip_previous,
            size: 30,
            color: Colors.white,
          ),
          onPressed: () {},
        ),
        const SizedBox(
          width: 10,
        ),
        StreamBuilder<PlayerState?>(
          stream: audioPlayer.playerStateStream,
          builder: (context, snapshot) {
            final playerState = snapshot.data;
            final processingState = playerState?.processingState;
            final playing = playerState?.playing;
            if (processingState == ProcessingState.loading ||
                processingState == ProcessingState.buffering) {
              return IconButton(
                icon: const Icon(
                  Icons.pause_circle_filled,
                  size: 60,
                  color: Colors.white,
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
          },
        ),
        const SizedBox(
          width: 10,
        ),
        IconButton(
          icon: const Icon(
            Icons.skip_next,
            size: 30,
            color: Colors.white,
          ),
          onPressed: () {},
        ),
        const SizedBox(
          width: 10,
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
          await audioPlayer.shuffle();
        }
        await audioPlayer.setShuffleModeEnabled(enable);
      },
    );
  }
}
