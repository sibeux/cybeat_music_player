import 'package:cybeat_music_player/providers/dominant_color_state.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

import '../components/dominant_color.dart';
import '../providers/audio_state.dart';
import '../providers/music_state.dart';
import '../screens/music_detail_screen.dart';

class FloatingPlayingMusic extends StatefulWidget {
  const FloatingPlayingMusic({
    super.key,
    required this.audioState,
    required this.currentItem,
    required this.paletteColor,
  });

  final AudioState audioState;
  final IndexedAudioSource? currentItem;
  final Color paletteColor;

  @override
  State<FloatingPlayingMusic> createState() => _FloatingPlayingMusicState();
}

class _FloatingPlayingMusicState extends State<FloatingPlayingMusic> {
  @override
  Widget build(BuildContext context) {

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
                        color: widget.paletteColor,
                        borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(100),
                            bottomRight: Radius.circular(100)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 35),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              // String ini dianggap setState()
                              widget.currentItem!.tag.title ?? '',
                              style: const TextStyle(
                                  color: Colors.white,
                                  overflow: TextOverflow.ellipsis,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              widget.currentItem!.tag.artist ?? '',
                              style: const TextStyle(
                                  color: Colors.white,
                                  overflow: TextOverflow.ellipsis,
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal),
                            ),
                          ],
                        ),
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
            childCurrent: build(context),
          ),
        );
      },
    );
  }
}
