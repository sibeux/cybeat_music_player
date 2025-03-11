import 'package:auto_size_text/auto_size_text.dart';
import 'package:cybeat_music_player/components/dominant_color.dart';
import 'package:cybeat_music_player/controller/progress_music_controller.dart';
import 'package:cybeat_music_player/widgets/animated_rotate_cover.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';
import '../providers/audio_state.dart';
import '../providers/music_state.dart';
import '../screens/detail_screen/music_detail_screen.dart';

class FloatingPlayingMusic extends StatefulWidget {
  const FloatingPlayingMusic({
    super.key,
    required this.audioState,
    required this.currentItem,
  });

  final AudioState audioState;
  final IndexedAudioSource? currentItem;

  @override
  State<FloatingPlayingMusic> createState() => _FloatingPlayingMusicState();
}

class _FloatingPlayingMusicState extends State<FloatingPlayingMusic> {
  Color? colorContainer = Colors.black;
  Color? colorInfoMusic = Colors.white;

  @override
  Widget build(BuildContext context) {
    getDominantColor(widget.currentItem!.tag.artUri.toString())
        .then((paletteGenerator) {
      if (colorContainer != paletteGenerator[0]) {
        setState(() {
          colorContainer = paletteGenerator[0];
          colorInfoMusic = paletteGenerator[1];
        });
      }
    });

    final progressMusicController =
        Get.put(ProgressMusicController(player: widget.audioState.player));

    return GestureDetector(
      child: SizedBox(
        width: double.infinity,
        height: 50,
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
                    child: Container(
                      width: double.infinity,
                      height: 45,
                      decoration: BoxDecoration(
                        // color: colorContainer,
                        color: colorContainer,
                        borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(100),
                            bottomRight: Radius.circular(100)),
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Text(
                                      // String ini dianggap setState()
                                      //   widget.currentItem!.tag.title ?? '',
                                      //   style: TextStyle(
                                      //       color: colorInfoMusic,
                                      //       overflow: TextOverflow.ellipsis,
                                      //       fontSize: 14,
                                      //       fontWeight: FontWeight.bold),
                                      // ),
                                      SizedBox(
                                        height: 20,
                                        child: AutoSizeText(
                                          widget.currentItem!.tag.title ?? '',
                                          minFontSize: 14,
                                          maxFontSize: 14,
                                          maxLines: 1,
                                          style: TextStyle(
                                            // fontSize: 14,
                                            color: colorInfoMusic,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflowReplacement: Marquee(
                                            text:
                                                widget.currentItem!.tag.title ??
                                                    '',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: colorInfoMusic,
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
                                          widget.currentItem!.tag.artist ?? '',
                                          minFontSize: 12,
                                          maxFontSize: 12,
                                          maxLines: 1,
                                          style: TextStyle(
                                              // fontSize: 12,
                                              color: colorInfoMusic,
                                              fontWeight: FontWeight.normal),
                                          overflowReplacement: Marquee(
                                            text: widget
                                                    .currentItem!.tag.artist ??
                                                '',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: colorInfoMusic,
                                                fontWeight: FontWeight.normal),
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
                                stream:
                                    widget.audioState.player.playerStateStream,
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
                                  color: colorInfoMusic,
                                ),
                                onPressed: () {
                                  widget.audioState.player.seekToNext();
                                },
                              ),
                              const SizedBox(width: 5),
                            ],
                          ),
                          Obx(
                            () {
                              final duration =
                                  progressMusicController.duration.value;
                              final position =
                                  progressMusicController.position.value;

                              return Container(
                                padding: const EdgeInsets.only(right: 20),
                                height: 3.5,
                                child: LinearProgressIndicator(
                                  value: (position.inMilliseconds > 0 &&
                                          position.inMilliseconds <
                                              duration.inMilliseconds)
                                      ? position.inMilliseconds /
                                          duration.inMilliseconds
                                      : 0.0,
                                  borderRadius: BorderRadius.circular(50),
                                  color: colorInfoMusic,
                                  backgroundColor: Colors.grey,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              AnimatedRotateCover(
                imageUrl: widget.currentItem!.tag.artUri.toString(),
              ),
            ],
          ),
        ),
      ),
      onTap: () {
        Get.to(
          () => MusicDetailScreen(
            player: widget.audioState.player,
            mediaItem: context.read<MusicState>().currentMediaItem!,
            audioState: widget.audioState,
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
      return IconButton(
        icon: const Icon(Icons.play_circle_fill),
        color: colorInfoMusic,
        onPressed: widget.audioState.player.play,
      );
    } else if (processingState != ProcessingState.completed) {
      return IconButton(
        icon: const Icon(Icons.pause_circle_filled),
        color: colorInfoMusic,
        onPressed: widget.audioState.player.pause,
      );
    } else {
      return IconButton(
        icon: const Icon(Icons.replay),
        onPressed: () => widget.audioState.player.seek(
          Duration.zero,
          index: widget.audioState.player.effectiveIndices!.first,
        ),
      );
    }
  }
}
