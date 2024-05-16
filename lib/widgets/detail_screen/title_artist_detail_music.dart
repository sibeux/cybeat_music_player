import 'package:auto_size_text/auto_size_text.dart';
import 'package:cybeat_music_player/components/capitalize.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:marquee/marquee.dart';

class TitleArtistDetailMusic extends StatelessWidget {
  const TitleArtistDetailMusic({super.key, required this.player});

  final AudioPlayer? player;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SequenceState?>(
        stream: player?.sequenceStateStream,
        builder: (context, snapshot) {
          String title = '';
          String artist = '';

          if (snapshot.hasData) {
            final currentItem = snapshot.data?.currentSource;
            title = currentItem?.tag.title ?? '';
            artist = currentItem?.tag.artist ?? '';
          }

          return Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 30,
                  child: AutoSizeText(
                    capitalizeEachWord(title),
                    minFontSize: 18,
                    maxLines: 1,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.values[5],
                    ),
                    overflowReplacement: Marquee(
                      text: capitalizeEachWord(title),
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.values[5],
                      ),
                      scrollAxis: Axis.horizontal,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      // spacing end of text
                      blankSpace: 30,
                      // second needed before slide again
                      pauseAfterRound: const Duration(seconds: 0),
                      // text gonna slide first time after this second
                      startAfter: const Duration(seconds: 2),
                      decelerationCurve: Curves.easeOut,
                      // speed of slide text
                      velocity: 35,
                      accelerationCurve: Curves.linear,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  capitalizeEachWord(artist),
                  style: const TextStyle(
                    overflow: TextOverflow.ellipsis,
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        });
  }
}
