import 'package:auto_size_text/auto_size_text.dart';
import 'package:cybeat_music_player/controller/music_state_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:marquee/marquee.dart';

class TitleArtistDetailMusic extends StatelessWidget {
  const TitleArtistDetailMusic({super.key, required this.player});

  final AudioPlayer? player;

  @override
  Widget build(BuildContext context) {
    final musicController = Get.put(MusicStateController(player: player!));

    return Obx(
      () => Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 30,
              child: AutoSizeText(
                musicController.title.value,
                minFontSize: 18,
                maxFontSize: 18,
                maxLines: 1,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.values[5],
                ),
                overflowReplacement: Marquee(
                  text: musicController.title.value,
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
            SizedBox(
              height: 30,
              child: AutoSizeText(
                musicController.artist.value,
                minFontSize: 14,
                maxFontSize: 14,
                maxLines: 1,
                style: const TextStyle(
                  // fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.normal,
                ),
                overflowReplacement: Marquee(
                  text: musicController.artist.value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.normal,
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
          ],
        ),
      ),
    );
  }
}
