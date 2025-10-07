import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:cybeat_music_player/features/album_music/controllers/album_music_controller.dart';
import 'package:cybeat_music_player/core/controllers/music_download_controller.dart';
import 'package:cybeat_music_player/core/controllers/audio_state_controller.dart';
import 'package:cybeat_music_player/core/controllers/music_player_controller.dart';
import 'package:cybeat_music_player/common/widgets/shimmer_music_list.dart';
import 'package:cybeat_music_player/features/album_music/screens/album_music_screen_search.dart';
import 'package:cybeat_music_player/features/album_music/widgets/album_music_list_mode/azlist_mode/azlist_view_mode.dart';
import 'package:cybeat_music_player/features/album_music/widgets/album_music_list_mode/simple_mode/simple_view_mode.dart';
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

class AlbumMusicScreen extends StatefulWidget {
  const AlbumMusicScreen({super.key});

  @override
  State<AlbumMusicScreen> createState() => _AlbumMusicScreenState();
}

class _AlbumMusicScreenState extends State<AlbumMusicScreen> {
  String? _error;
  Color dominantColor = Colors.black;
  List<AzListMusic> musicItems = [];

  final musicPlayerController = Get.find<MusicPlayerController>();
  final audioStateController = Get.find<AudioStateController>();
  final AlbumMusicController albumMusicController = Get.find();

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
    if (musicPlayerController.currentActivePlaylist.value?.title
                .toLowerCase() ==
            "offline music" ||
        musicPlayerController.currentActivePlaylist.value?.type.toLowerCase() ==
            "playlist") {
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
      stream: audioStateController.activePlayer.value?.sequenceStateStream,
      builder: (context, snapshot) {
        if (snapshot.data?.sequence.isEmpty ??
            true && albumMusicController.initAlbumLoading.value) {
          if (audioStateController.isAlbumEmpty.value) {
            return Center(
              child: Text(
                'No songs available in this ${musicPlayerController.currentActivePlaylist.value!.type.toLowerCase()}',
                style: TextStyle(
                  color: Colors.black.withValues(alpha: 0.7),
                  fontSize: 16.sp,
                ),
              ),
            );
          }
          return ShimmerMusicList();
        }

        final state = snapshot.data;
        final sequence = state?.sequence ?? [];

        return Obx(
          () => albumMusicController.isSimpleMode
              ? SimpleViewMode(
                  sequence: sequence,
                  audioStateController: audioStateController,
                  albumMusicController: albumMusicController,
                )
              : AzlistViewMode(
                  audioStateController: audioStateController,
                  albumMusicController: albumMusicController,
                  sequence: sequence,
                ),
        );
      },
    );

    if (_error != null) {
      content = Center(
        child: Text(_error!),
      );
    }

    void rebuildPlaylist() {
      // Untuk build ulang susunan album di home screen.
      if (musicPlayerController.isNeedRebuildLastPlaylist.value) {
        musicPlayerController.isNeedRebuildLastPlaylist.value = false;
        // Method untuk update playlsit terakhir yang diputar.
        albumMusicController.updateLastPlayedAlbum(
            musicPlayerController.currentActivePlaylist.value!.uid);
      }
    }

    return PopScope(
      // Logic saat back button bawaan hp ditekan.
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          if (musicPlayerController.currentActivePlaylist.value!.type
                  .toLowerCase() ==
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
              if (musicPlayerController.currentActivePlaylist.value!.type
                      .toLowerCase() ==
                  'offline') {
                return;
              }
              rebuildPlaylist();
            },
          ),
          actions: [
            IconButton(onPressed: (){
              Get.to(()=> const AlbumMusicScreenSearch());
            }, icon: Icon(
              Icons.search,
              size: 28.sp,
              color: HexColor('#8d8c8c'),
            ))
          ],
          centerTitle: true,
          toolbarHeight: 60.h,
          title: Obx(
            () => Text(
              musicPlayerController.currentActivePlaylist.value?.title ?? '',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: HexColor('#1e0b2b'),
                fontSize: 21.sp,
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
                          height: 50.h,
                          child: Row(
                            children: [
                              StreamBuilder<SequenceState?>(
                                stream: audioStateController
                                    .activePlayer.value?.sequenceStateStream,
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
                                          audioStateController,
                                          sequence,
                                        );
                                      }
                                    },
                                    child: Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 8.w),
                                      margin: EdgeInsets.only(left: 18.w),
                                      width: 180.w,
                                      height: 35.h,
                                      decoration: BoxDecoration(
                                        color: HexColor('#ac8bc9'),
                                        borderRadius:
                                            BorderRadius.circular(50.r),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.play_circle_fill,
                                            color: HexColor('#fefffe'),
                                            size: 30.sp,
                                          ),
                                          SizedBox(
                                            width: 5.w,
                                          ),
                                          Text(
                                            'Shuffle Playback',
                                            style: TextStyle(
                                              color: HexColor('#fefffe'),
                                              fontSize: 16.sp,
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
                                  Icons.library_music_outlined,
                                  size: 30.sp,
                                  color: HexColor('#8d8c8c'),
                                ),
                                onPressed: () {
                                  albumMusicController
                                      .getToAddAllMusicToPlaylistScreen();
                                },
                              ),
                              SizedBox(
                                width: 15.w,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Container(
                            color: HexColor('#fefffe'),
                            padding: EdgeInsets.only(top: 8.h),
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
                height: musicPlayerController.isMusicActiveNow.value ? 50.h : 0,
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
    final index = audioStateController.playlist.length < 2
        ? 0
        : random(0, audioStateController.playlist.length - 1);
    // Langsung buka detail screen.
    Get.toNamed('/detail');
    musicPlayerController.playMusicNow(
      audioStateController: audioStateController,
      index: index,
      mediaItem: sequence[index].tag as MediaItem,
    );
  }

  int random(int min, int max) {
    return min + Random().nextInt(max - min);
  }
}
