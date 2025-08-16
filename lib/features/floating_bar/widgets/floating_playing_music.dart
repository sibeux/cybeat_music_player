import 'package:auto_size_text/auto_size_text.dart';
import 'package:cybeat_music_player/features/floating_bar/controllers/floating_playing_music_controller.dart';
import 'package:cybeat_music_player/controller/music_play/music_state_controller.dart';
import 'package:cybeat_music_player/core/controllers/music_player_controller.dart';
import 'package:cybeat_music_player/widgets/animated_rotate_cover.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:just_audio/just_audio.dart';
import 'package:marquee/marquee.dart';
import '../../../core/controllers/audio_state_controller.dart';

final floatingPlayingMusicController =
    Get.put(FloatingPlayingMusicController());

class FloatingPlayingMusic extends StatelessWidget {
  const FloatingPlayingMusic({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final audioStateController = Get.find<AudioStateController>();
    final musicPlayerController = Get.find<MusicPlayerController>();
    final musicStateController = Get.find<MusicStateController>();

    return GestureDetector(
      child: Container(
        width: double.infinity,
        height: 50.h,
        color: HexColor('#fefffe'),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w),
          child: Stack(
            alignment: AlignmentDirectional.bottomStart,
            children: [
              Row(
                children: [
                  Container(
                    width: 25.w,
                    height: 45.h,
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
                        height: 45.h,
                        decoration: BoxDecoration(
                          color: floatingPlayingMusicController.listColor[0],
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(100.r),
                            bottomRight: Radius.circular(100.r),
                          ),
                        ),
                        child: Stack(
                          alignment: AlignmentDirectional.bottomEnd,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 35.w),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          height: 20.h,
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
                                                fontSize: 14.sp,
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
                                          height: 20.h,
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
                                                fontSize: 12.sp,
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
                                  stream: audioStateController
                                      .player.value?.playerStateStream,
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
                                    audioStateController.player.value
                                        ?.seekToNext();
                                  },
                                ),
                                SizedBox(width: 5.w),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.only(right: 20),
                              height: 3.5,
                              child: LinearProgressIndicator(
                                value: (musicPlayerController
                                                .currentMusicPosition
                                                .value
                                                .inMilliseconds >
                                            0 &&
                                        musicPlayerController
                                                .currentMusicPosition
                                                .value
                                                .inMilliseconds <
                                            musicPlayerController
                                                .currentMusicDuration
                                                .value
                                                .inMilliseconds)
                                    ? musicPlayerController.currentMusicPosition
                                            .value.inMilliseconds /
                                        musicPlayerController
                                            .currentMusicDuration
                                            .value
                                            .inMilliseconds
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
        Get.toNamed('/detail');
      },
    );
  }

  Widget _playPauseButton(PlayerState? playerState) {
    final processingState = playerState?.processingState;
    final audioStateController = Get.find<AudioStateController>();
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
          onPressed: audioStateController.player.value?.play,
        ),
      );
    } else if (processingState != ProcessingState.completed) {
      return Obx(
        () => IconButton(
          icon: const Icon(Icons.pause_circle_filled),
          color: floatingPlayingMusicController.listColor[1],
          onPressed: audioStateController.player.value?.pause,
        ),
      );
    } else {
      return Obx(
        () => IconButton(
          icon: const Icon(Icons.replay),
          onPressed: () => audioStateController.player.value?.seek(
            Duration.zero,
            index: audioStateController.player.value?.effectiveIndices!.first,
          ),
        ),
      );
    }
  }
}
