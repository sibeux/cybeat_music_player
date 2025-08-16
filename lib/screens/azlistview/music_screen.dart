import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:cybeat_music_player/features/home/controllers/home_controller.dart';
import 'package:cybeat_music_player/controller/music_download_controller.dart';
import 'package:cybeat_music_player/core/controllers/audio_state_controller.dart';
import 'package:cybeat_music_player/core/controllers/music_player_controller.dart';
import 'package:cybeat_music_player/features/detail_music/screens/detail_music_screen.dart';
import 'package:cybeat_music_player/features/album_music/widgets/album_music_list.dart';
import 'package:cybeat_music_player/widgets/shimmer_music_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:just_audio/just_audio.dart';
import 'package:azlistview/azlistview.dart';

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

  final AudioStateController audioState;

  @override
  State<AzListMusicScreen> createState() => _AzListMusicScreenState();
}

class _AzListMusicScreenState extends State<AzListMusicScreen> {
  String? _error;
  Color dominantColor = Colors.black;
  List<AzListMusic> musicItems = [];
  get audioState => widget.audioState;

  final homeAlbumGridController = Get.find<HomeController>();
  final musicPlayerController = Get.find<MusicPlayerController>();

  @override
  void initState() {
    super.initState();
    musicPlayerController.isAzlistviewScreenActive.value = true;
  }

  @override
  void dispose() {
    super.dispose();
    musicPlayerController.isAzlistviewScreenActive.value = false;
  }

  void setColor(Color color) {
    setState(() {
      dominantColor = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Untuk menampilkan ulang list musik saat ada yang dihapus.
    if (musicPlayerController.currentActivePlaylist.value?.title.toLowerCase() ==
            "offline music" ||
        musicPlayerController.currentActivePlaylist.value?.type.toLowerCase() == "playlist") {
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
                'No songs available in this ${musicPlayerController.playlistType.value.toLowerCase()}',
                style: TextStyle(
                  color: Colors.black.withValues(alpha: 0.7),
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
                color: Colors.grey.withValues(alpha: 0.7),
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
                child: AlbumMusicList(
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
                    () => DetailMusicScreen(
                      player: audioState.player,
                      audioState: audioState,
                    ),
                    transition: Transition.downToUp,
                    duration: const Duration(milliseconds: 300),
                    popGesture: false,
                    fullscreenDialog: true,
                  );

                  if (musicPlayerController.currentMediaItem?.id == "" ||
                      musicPlayerController.currentMediaItem?.id !=
                          sequence[index].tag.id) {
                    musicPlayerController.playMusicNow(
                      audioStateController: audioState,
                      index: index,
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
      if (musicPlayerController.isNeedRebuildLastPlaylist.value) {
        musicPlayerController.isNeedRebuildLastPlaylist.value = false;
        homeAlbumGridController
            .recentPlaylistUpdate(musicPlayerController.playlistUid.value);
      }
    }

    return PopScope(
      // Logic saat back button bawaan hp ditekan.
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          if (musicPlayerController.playlistType.value.toLowerCase() ==
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
              Get.back(
                id: 1,
              );
              if (musicPlayerController.playlistType.value.toLowerCase() ==
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
              musicPlayerController.playlistTitle.value,
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
                                highlightColor:
                                    Colors.black.withValues(alpha: 0.02),
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
              () => SizedBox(
                height: musicPlayerController.isPlayingNow.value ? 50.h : 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // logic untuk shuffle music.
  void _shuffleMusic(
    AudioStateController audioStateController,
    List<IndexedAudioSource> sequence,
  ) {
    final index = audioStateController.playlist.value!.length < 2
        ? 0
        : random(0, audioStateController.playlist.value!.length - 1);
    // Langsung buka detail screen.
    Get.to(
      () => DetailMusicScreen(
        player: audioStateController.player.value!,
        audioState: audioStateController,
      ),
      transition: Transition.downToUp,
      popGesture: false,
      fullscreenDialog: true,
    );
    musicPlayerController.playMusicNow(
      audioStateController: audioStateController,
      index: index,
    );
  }

  int random(int min, int max) {
    return min + Random().nextInt(max - min);
  }
}
