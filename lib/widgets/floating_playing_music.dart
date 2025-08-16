import 'package:auto_size_text/auto_size_text.dart';
import 'package:cybeat_music_player/controller/floating_playing_music/floating_playing_music_controller.dart';
import 'package:cybeat_music_player/controller/music_play/music_state_controller.dart';
import 'package:cybeat_music_player/controller/music_play/progress_music_controller.dart';
import 'package:cybeat_music_player/widgets/animated_rotate_cover.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:just_audio/just_audio.dart';
import 'package:marquee/marquee.dart';
import '../core/controllers/audio_state_provider.dart';
import '../screens/detail_screen/music_detail_screen.dart';

final floatingPlayingMusicController =
    Get.put(FloatingPlayingMusicController());

class FloatingPlayingMusic extends StatelessWidget {
  const FloatingPlayingMusic({
    super.key,
    required this.audioState,
  });

  final AudioState audioState;

  @override
  Widget build(BuildContext context) {
    final progressMusicController =
        Get.put(ProgressMusicController(player: audioState.player));
    final musicStateController = Get.find<MusicStateController>();

    return GestureDetector(
      child: Container(
        width: double.infinity,
        height: 50,
        color: HexColor('#fefffe'),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Stack(
            alignment: AlignmentDirectional.bottomStart,
            children: [
              Row(
                children: [
                  Container(
                    width: 25,
                    height: 45,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white,
                          Colors.grey,
                        ],
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(100),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Obx(
                      () => Container(
                        width: double.infinity,
                        height: 45,
                        decoration: BoxDecoration(
                          color: floatingPlayingMusicController.listColor[0],
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(100),
                            bottomRight: Radius.circular(100),
                          ),
                        ),
                        child: Stack(
                          alignment: AlignmentDirectional.bottomEnd,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 35),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          height: 20,
                                          child: AutoSizeText(
                                            musicStateController.title.value,
                                            minFontSize: 14,
                                            maxFontSize: 14,
                                            maxLines: 1,
                                            style: TextStyle(
                                              // fontSize: 14,
                                              color:
                                                  floatingPlayingMusicController
                                                      .listColor[1],
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflowReplacement: Marquee(
                                              text: musicStateController
                                                  .title.value,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color:
                                                    floatingPlayingMusicController
                                                        .listColor[1],
                                                fontWeight: FontWeight.bold,
                                              ),
                                              scrollAxis: Axis.horizontal,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              // spacing end of text
                                              blankSpace: 30,
                                              // second needed before slide again
                                              pauseAfterRound:
                                                  const Duration(seconds: 0),
                                              // text gonna slide first time after this second
                                              startAfter:
                                                  const Duration(seconds: 2),
                                              decelerationCurve: Curves.easeOut,
                                              // speed of slide text
                                              velocity: 35,
                                              accelerationCurve: Curves.linear,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 20,
                                          child: AutoSizeText(
                                            musicStateController.artist.value,
                                            minFontSize: 12,
                                            maxFontSize: 12,
                                            maxLines: 1,
                                            style: TextStyle(
                                                // fontSize: 12,
                                                color:
                                                    floatingPlayingMusicController
                                                        .listColor[1],
                                                fontWeight: FontWeight.normal),
                                            overflowReplacement: Marquee(
                                              text: musicStateController
                                                  .artist.value,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color:
                                                    floatingPlayingMusicController
                                                        .listColor[1],
                                                fontWeight: FontWeight.normal,
                                              ),
                                              scrollAxis: Axis.horizontal,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              // spacing end of text
                                              blankSpace: 30,
                                              // second needed before slide again
                                              pauseAfterRound:
                                                  const Duration(seconds: 0),
                                              // text gonna slide first time after this second
                                              startAfter:
                                                  const Duration(seconds: 2),
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
                                ),
                                StreamBuilder<PlayerState>(
                                  stream: audioState.player.playerStateStream,
                                  builder: (_, snapshot) {
                                    final playerState = snapshot.data;
                                    return _playPauseButton(playerState);
                                  },
                                ),
                                IconButton(
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  icon: Icon(
                                    Icons.skip_next_rounded,
                                    color: floatingPlayingMusicController
                                        .listColor[1],
                                  ),
                                  onPressed: () {
                                    audioState.player.seekToNext();
                                  },
                                ),
                                const SizedBox(width: 5),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.only(right: 20),
                              height: 3.5,
                              child: LinearProgressIndicator(
                                value: (progressMusicController
                                                .position.value.inMilliseconds >
                                            0 &&
                                        progressMusicController
                                                .position.value.inMilliseconds <
                                            progressMusicController
                                                .duration.value.inMilliseconds)
                                    ? progressMusicController
                                            .position.value.inMilliseconds /
                                        progressMusicController
                                            .duration.value.inMilliseconds
                                    : 0.0,
                                borderRadius: BorderRadius.circular(50),
                                color:
                                    floatingPlayingMusicController.listColor[1],
                                backgroundColor: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Obx(
                () => AnimatedRotateCover(
                  imageUrl: musicStateController.cover.value,
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: () {
        Get.to(
          () => MusicDetailScreen(
            player: audioState.player,
            audioState: audioState,
          ),
          transition: Transition.downToUp,
          duration: const Duration(milliseconds: 300),
          popGesture: false,
          fullscreenDialog: true,
        );
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
          color: Colors.grey,
        ),
        onPressed: () {},
      );
    }
    if (playing != true) {
      return Obx(
        () => IconButton(
          icon: const Icon(Icons.play_circle_fill),
          color: floatingPlayingMusicController.listColor[1],
          onPressed: audioState.player.play,
        ),
      );
    } else if (processingState != ProcessingState.completed) {
      return Obx(
        () => IconButton(
          icon: const Icon(Icons.pause_circle_filled),
          color: floatingPlayingMusicController.listColor[1],
          onPressed: audioState.player.pause,
        ),
      );
    } else {
      return Obx(
        () => IconButton(
          icon: const Icon(Icons.replay),
          onPressed: () => audioState.player.seek(
            Duration.zero,
            index: audioState.player.effectiveIndices!.first,
          ),
        ),
      );
    }
  }
}
