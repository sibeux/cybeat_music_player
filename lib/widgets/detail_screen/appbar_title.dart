import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AppbarTitle extends StatelessWidget {
  const AppbarTitle({
    super.key,
    required this.player,
  });

  final AudioPlayer? player;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'PLAYING FROM ALBUM',
          style: TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        StreamBuilder<SequenceState?>(
          stream: player?.sequenceStateStream,
          builder: (context, snapshot) {
            String album = '';

            if (snapshot.hasData) {
              final currentItem = snapshot.data?.currentSource;
              album = currentItem?.tag.album ?? '';
            }

            return Text(
              // "日本の歌",
              album,
              style: const TextStyle(
                color: Colors.white,
                overflow: TextOverflow.ellipsis,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        )
      ],
    );
  }
}
