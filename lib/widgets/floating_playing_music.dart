import 'package:auto_size_text/auto_size_text.dart';
import 'package:cybeat_music_player/components/dominant_color.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:marquee/marquee.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import '../providers/audio_state.dart';
import '../providers/music_state.dart';
import '../screens/music_detail_screen.dart';

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
                        color: colorContainer,
                        borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(100),
                            bottomRight: Radius.circular(100)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 35),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                      maxLines: 1,
                                      style: TextStyle(
                                        color: colorInfoMusic,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflowReplacement: Marquee(
                                        text:
                                            widget.currentItem!.tag.title ?? '',
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
                                        startAfter: const Duration(seconds: 2),
                                        decelerationCurve: Curves.easeOut,
                                        // speed of slide text
                                        velocity: 35,
                                        accelerationCurve: Curves.linear,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    widget.currentItem!.tag.artist ?? '',
                                    style: TextStyle(
                                        color: colorInfoMusic,
                                        overflow: TextOverflow.ellipsis,
                                        fontSize: 12,
                                        fontWeight: FontWeight.normal),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          StreamBuilder<PlayerState>(
                            stream: widget.audioState.player.playerStateStream,
                            builder: (_, snapshot) {
                              final playerState = snapshot.data;
                              return _playPauseButton(playerState);
                            },
                          ),
                          IconButton(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            icon: const Icon(
                              Icons.skip_next_rounded,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              widget.audioState.player.seekToNext();
                            },
                          ),
                          const SizedBox(width: 5),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                alignment: Alignment.center,
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Stack(
                  children: [
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Image.network(
                          widget.currentItem!.tag.artUri.toString(),
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.low,
                          cacheHeight: 150,
                          cacheWidth: 150,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.bottomToTop,
              duration: const Duration(milliseconds: 300),
              reverseDuration: const Duration(milliseconds: 300),
              child: MusicDetailScreen(
                player: widget.audioState.player,
                mediaItem: context.read<MusicState>().currentMediaItem!,
              ),
              childCurrent: FloatingPlayingMusic(
                audioState: widget.audioState,
                currentItem: widget.currentItem,
              )),
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
        color: Colors.white,
        onPressed: widget.audioState.player.play,
      );
    } else if (processingState != ProcessingState.completed) {
      return IconButton(
        icon: const Icon(Icons.pause_circle_filled),
        color: Colors.white,
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
