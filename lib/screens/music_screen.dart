import 'dart:async';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:cybeat_music_player/providers/audio_state.dart';
import 'package:cybeat_music_player/providers/music_state.dart';
import 'package:cybeat_music_player/providers/playing_state.dart';
import 'package:cybeat_music_player/widgets/music_list.dart';
import 'package:cybeat_music_player/widgets/shimmer_music_list.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:provider/provider.dart';
import 'package:azlistview/azlistview.dart';

import '../widgets/floating_playing_music.dart';

var isPlaying = false;

class AzListMusic extends ISuspensionBean {
  final String title;
  final String tag;

  AzListMusic({required this.title, required this.tag});

  @override
  String getSuspensionTag() => tag;
}

class MusicScreen extends StatefulWidget {
  const MusicScreen({super.key});

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  String? _error;
  bool isLoadingVertical = false;
  final int increment = 10;
  Color dominantColor = Colors.black;
  List<AzListMusic> musicItems = [];

  StreamSubscription? _playerCompleteSubscription;

  @override
  void initState() {
    super.initState();
    _loadMoreVertical();
  }

  @override
  void dispose() {
    _playerCompleteSubscription?.cancel();
    super.dispose();
  }

  void setColor(Color color) {
    setState(() {
      dominantColor = color;
    });
  }

  Future _loadMoreVertical() async {
    setState(() {
      isLoadingVertical = true;
    });

    // Add in an artificial delay
    await Future.delayed(
      const Duration(seconds: 2),
    );

    setState(() {
      isLoadingVertical = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final audioState = context.watch<AudioState>();

    Widget content = const Center(
      child: Text('No music yet! Add some!'),
    );

    content = LazyLoadScrollView(
      isLoading: isLoadingVertical,
      onEndOfPage: () => _loadMoreVertical(),
      child: StreamBuilder<SequenceState?>(
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final state = snapshot.data;
            final sequence = state?.sequence ?? [];

            musicItems = sequence
                .map(
                  (e) => AzListMusic(
                    title: e.tag.title,
                    tag: e.tag.title.substring(0, 1).toUpperCase(),
                  ),
                )
                .toList();

            return AzListView(
                data: musicItems,
                itemCount: sequence.length,
                indexBarAlignment: Alignment.topRight,
                indexBarOptions: IndexBarOptions(
                  indexHintDecoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.7),
                    shape: BoxShape.circle,
                  ),
                  selectItemDecoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: HexColor('#6a5081'),
                  ),
                  needRebuild: true,
                  selectTextStyle: TextStyle(
                    color: HexColor('#fefffe'),
                    fontSize: 12,
                  ),
                ),
                itemBuilder: (context, index) {
                  return InkWell(
                    child: MusicList(
                      mediaItem: sequence[index].tag as MediaItem,
                      audioPlayer: audioState.player,
                    ),
                    onTap: () {
                      // Navigator.push(
                      //   context,
                      //   PageTransition(
                      //     type: PageTransitionType.bottomToTop,
                      //     duration: const Duration(milliseconds: 300),
                      //     reverseDuration: const Duration(milliseconds: 300),
                      //     child: MusicDetailScreen(
                      //       player: audioState.player,
                      //       mediaItem: sequence[index].tag as MediaItem,
                      //     ),
                      //     childCurrent: const MusicScreen(),
                      //   ),
                      // );

                      if (context.read<MusicState>().currentMediaItem?.id ==
                              "" ||
                          context.read<MusicState>().currentMediaItem?.id !=
                              sequence[index].tag.id) {
                        audioState.player.seek(Duration.zero, index: index);

                        audioState.player.setAudioSource(audioState.playlist,
                            initialIndex: index);

                        context.read<PlayingState>().play();

                        context.read<MusicState>().setCurrentMediaItem(
                            sequence[index].tag as MediaItem);

                        audioState.player.play();
                      } 
                    },
                  );
                });
          }
          return const ShimmerMusicList();
        },
        stream: audioState.player.sequenceStateStream,
      ),
    );

    if (_error != null) {
      content = Center(
        child: Text(_error!),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: HexColor('#fefffe'),
        scrolledUnderElevation: 0.0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          tooltip: 'Menu',
          onPressed: () {},
        ),
        centerTitle: true,
        toolbarHeight: 60,
        title: Text(
          '日本の歌',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: HexColor('#1e0b2b'),
            fontSize: 21,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        color: HexColor('#fefffe'),
                        width: double.infinity,
                        height: 50,
                        child: Row(
                          children: [
                            StreamBuilder<SequenceState?>(
                              builder: (context, snapshot) {
                                List<IndexedAudioSource> sequence = [];
                                if (snapshot.hasData) {
                                  final state = snapshot.data;
                                  sequence = state?.sequence ?? [];
                                }
                                return InkWell(
                                  onTap: () {
                                    if (snapshot.hasData) {
                                      _shuffleMusic(audioState, sequence);
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    margin: const EdgeInsets.only(left: 18),
                                    width: 180,
                                    height: 35,
                                    decoration: BoxDecoration(
                                      color: HexColor('#ac8bc9'),
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.play_circle_fill,
                                          color: HexColor('#fefffe'),
                                          size: 30,
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          'Shuffle Playback',
                                          style: TextStyle(
                                            color: HexColor('#fefffe'),
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              stream: audioState.player.sequenceStateStream,
                            ),
                            const Expanded(
                              child: SizedBox(),
                            ),
                            IconButton(
                              highlightColor: Colors.black.withOpacity(0.02),
                              icon: Icon(
                                Icons.list_rounded,
                                size: 30,
                                color: HexColor('#8d8c8c'),
                              ),
                              onPressed: () {},
                            ),
                            const SizedBox(
                              width: 15,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(
                          color: HexColor('#fefffe'),
                          padding: const EdgeInsets.only(top: 8),
                          width: double.infinity,
                          child: content,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (context.watch<PlayingState>().isPlaying)
            StreamBuilder<SequenceState?>(
              stream: audioState.player.sequenceStateStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final currentItem = snapshot.data?.currentSource;
                  context
                      .read<MusicState>()
                      .setCurrentMediaItem(currentItem!.tag as MediaItem);

                  return FloatingPlayingMusic(
                    audioState: audioState,
                    currentItem: currentItem,
                  );
                }
                return const SizedBox();
              },
            )
        ],
      ),
    );
  }

  void _shuffleMusic(AudioState audioState, List<IndexedAudioSource> sequence) {
    final index = random(0, audioState.playlist.length - 1);

    // Navigator.push(
    //   context,
    //   PageTransition(
    //     type: PageTransitionType.bottomToTop,
    //     duration: const Duration(milliseconds: 300),
    //     reverseDuration: const Duration(milliseconds: 300),
    //     child: MusicDetailScreen(
    //       player: audioState.player,
    //       mediaItem: sequence[index].tag as MediaItem,
    //     ),
    //     childCurrent: const MusicScreen(),
    //   ),
    // );

    audioState.player.seek(Duration.zero, index: index);

    audioState.player.setAudioSource(audioState.playlist, initialIndex: index);

    context.read<PlayingState>().play();

    context
        .read<MusicState>()
        .setCurrentMediaItem(sequence[index].tag as MediaItem);

    audioState.player.play();
  }

  int random(int min, int max) {
    return min + Random().nextInt(max - min);
  }
}
