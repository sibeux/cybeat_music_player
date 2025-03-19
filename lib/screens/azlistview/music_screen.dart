import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:cybeat_music_player/controller/home_album_grid_controller.dart';
import 'package:cybeat_music_player/controller/music_download_controller.dart';
import 'package:cybeat_music_player/controller/music_play/music_play_method.dart';
import 'package:cybeat_music_player/controller/music_play/playing_state_controller.dart';
import 'package:cybeat_music_player/controller/playlist_play_controller.dart';
import 'package:cybeat_music_player/providers/audio_state.dart';
import 'package:cybeat_music_player/providers/music_state.dart';
import 'package:cybeat_music_player/screens/detail_screen/music_detail_screen.dart';
import 'package:cybeat_music_player/widgets/music_list.dart';
import 'package:cybeat_music_player/widgets/shimmer_music_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:azlistview/azlistview.dart';

import './/./widgets/floating_playing_music.dart';

var isPlaying = false;

class AzListMusic extends ISuspensionBean {
  final String title;
  final String tag;

  AzListMusic({required this.title, required this.tag});

  @override
  String getSuspensionTag() => tag;
}

class AzListMusicScreen extends StatefulWidget {
  const AzListMusicScreen({super.key, required this.audioState});

  final AudioState audioState;

  @override
  State<AzListMusicScreen> createState() => _AzListMusicScreenState();
}

class _AzListMusicScreenState extends State<AzListMusicScreen> {
  String? _error;
  Color dominantColor = Colors.black;
  List<AzListMusic> musicItems = [];
  get audioState => widget.audioState;

  final playlistPlayController = Get.find<PlaylistPlayController>();
  final homeAlbumGridController = Get.find<HomeAlbumGridController>();
  final playingStateController = Get.put(PlayingStateController());

  @override
  void initState() {
    super.initState();
    playlistPlayController.isAzlistviewScreenActive.value = true;
  }

  @override
  void dispose() {
    super.dispose();
    playlistPlayController.isAzlistviewScreenActive.value = false;
  }

  void setColor(Color color) {
    setState(() {
      dominantColor = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Untuk menampilkan ulang list musik saat ada yang dihapus.
    if (playlistPlayController.playlistTitle.value.toLowerCase() ==
            "offline music" ||
        playlistPlayController.playlistType.value.toLowerCase() == "playlist") {
      final musicDownloadController = Get.find<MusicDownloadController>();
      ever(musicDownloadController.rebuildDelete, (callback) {
        if (!context.mounted) return;
        setState(() {
          // setState di sini agar list musik di rebuild saat ada-
          // musik yang dihapus.
        });
      });
    }

    Widget content = StreamBuilder<SequenceState?>(
      stream: audioState.player.sequenceStateStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Menampilkan shimmer saat data sedang dimuat.
          return const ShimmerMusicList();
        }
        if (snapshot.hasData) {
          final state = snapshot.data;
          final sequence = state?.sequence ?? [];

          if (sequence.isEmpty) {
            return Center(
              child: Text(
                'No songs available in this ${playlistPlayController.playlistType.value.toLowerCase()}',
                style: TextStyle(
                  color: Colors.black.withOpacity(0.7),
                  fontSize: 16,
                ),
              ),
            );
          }

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
            // itemCount: 50,
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
              // Akan di-print terus saat scroll.
              // print(index);
              return InkWell(
                child: MusicList(
                  mediaItem: sequence[index].tag as MediaItem,
                  audioPlayer: audioState.player,
                  index: index,
                  audioState: audioState,
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
                  //     childCurrent: AzListMusicScreen(
                  //       playlist: widget.playlist,
                  //       audioState: audioState,
                  //     ),
                  //   ),
                  // );

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

                  if (context.read<MusicState>().currentMediaItem?.id == "" ||
                      context.read<MusicState>().currentMediaItem?.id !=
                          sequence[index].tag.id) {
                    musicPlayMethod(
                      state: audioState,
                      index: index,
                      context: context,
                      mediaItem: sequence[index].tag as MediaItem,
                    );
                  }
                },
              );
            },
          );
        }
        return const SizedBox();
      },
    );

    if (_error != null) {
      content = Center(
        child: Text(_error!),
      );
    }

    void rebuildPlaylist() {
      if (playlistPlayController.needRebuild.value) {
        playlistPlayController.needRebuild.value = false;
        homeAlbumGridController
            .recentPlaylistUpdate(playlistPlayController.playlistUid.value);
      }
    }

    return PopScope(
      // Logic saat back button bawaan hp ditekan.
      onPopInvoked: (didPop) {
        if (didPop) {
          if (playlistPlayController.playlistType.value.toLowerCase() ==
              'offline') {
            return;
          }
          rebuildPlaylist();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: HexColor('#fefffe'),
          scrolledUnderElevation: 0.0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            tooltip: 'Menu',
            onPressed: () {
              // On pressed ini berlaku saat icon back button diklik.
              // Tidak berlaku saat nav back button diklik.
              Get.back();
              if (playlistPlayController.playlistType.value.toLowerCase() ==
                  'offline') {
                return;
              }
              rebuildPlaylist();
            },
          ),
          centerTitle: true,
          toolbarHeight: 60,
          title: Obx(
            () => Text(
              playlistPlayController.playlistTitle.value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: HexColor('#1e0b2b'),
                fontSize: 21,
              ),
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
                                stream: audioState.player.sequenceStateStream,
                                builder: (context, snapshot) {
                                  List<IndexedAudioSource> sequence = [];
                                  if (snapshot.hasData) {
                                    final state = snapshot.data;
                                    sequence = state?.sequence ?? [];
                                  }
                                  return InkWell(
                                    onTap: () {
                                      if (snapshot.hasData &&
                                          sequence.isNotEmpty) {
                                        _shuffleMusic(
                                          audioState,
                                          sequence,
                                        );
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
            Obx(
              () => playingStateController.isPlaying.value
                  ? FloatingPlayingMusic(
                      audioState: audioState,
                    )
                  : const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }

  // logic untuk shuffle music.
  void _shuffleMusic(
    AudioState audioState,
    List<IndexedAudioSource> sequence,
  ) {
    final index = audioState.playlist.length < 2
        ? 0
        : random(0, audioState.playlist.length - 1);
    // Langsung buka detail screen.
    Get.to(
      () => MusicDetailScreen(
        player: audioState.player,
        audioState: audioState,
      ),
      transition: Transition.downToUp,
      popGesture: false,
      fullscreenDialog: true,
    );
    musicPlayMethod(
      state: audioState,
      index: index,
      context: context,
      mediaItem: sequence[index].tag as MediaItem,
    );
  }

  int random(int min, int max) {
    return min + Random().nextInt(max - min);
  }
}
