import 'package:auto_size_text/auto_size_text.dart';
import 'package:cybeat_music_player/components/capitalize.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:marquee/marquee.dart';

class TitleDetailMusic extends StatelessWidget {
  const TitleDetailMusic({
    super.key,
    required this.currentItem,
  });

  final IndexedAudioSource? currentItem;

  @override
  Widget build(BuildContext context) {
    return AutoSizeText(
      capitalizeEachWord(currentItem?.tag.title),
      minFontSize: 18,
      maxLines: 1,
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.values[5],
      ),
      overflowReplacement: SizedBox(
        height: 30,
        child: Marquee(
          text: capitalizeEachWord(currentItem?.tag.title),
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
    );
  }
}
