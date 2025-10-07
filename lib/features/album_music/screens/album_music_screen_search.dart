import 'package:audio_service/audio_service.dart';
import 'package:cybeat_music_player/features/album_music/controllers/album_music_controller.dart';
import 'package:cybeat_music_player/core/controllers/music_download_controller.dart';
import 'package:cybeat_music_player/core/controllers/audio_state_controller.dart';
import 'package:cybeat_music_player/core/controllers/music_player_controller.dart';
import 'package:cybeat_music_player/common/widgets/shimmer_music_list.dart';
import 'package:cybeat_music_player/features/album_music/widgets/album_music_list_mode/azlist_mode/album_music_azlist_list.dart';
import 'package:cybeat_music_player/features/album_music/widgets/album_music_list_mode/simple_mode/simple_view_mode.dart';
import 'package:cybeat_music_player/features/home/widgets/home_list/home_list_four_cover.dart';
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

class AlbumMusicScreenSearch extends StatefulWidget {
  const AlbumMusicScreenSearch({super.key});

  @override
  State<AlbumMusicScreenSearch> createState() => _AlbumMusicScreenSearchState();
}

class _AlbumMusicScreenSearchState extends State<AlbumMusicScreenSearch> {
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
        backgroundColor: HexColor('#fefffe'),
        body: CustomScrollView(
          scrollBehavior: NoGlowScrollBehavior(),
          slivers: [
            SliverAppBar(
              // backgroundColor: Colors.transparent,
              backgroundColor: HexColor('#fefffe'),
              surfaceTintColor: HexColor('#519756').withValues(alpha: 1),
              expandedHeight: 180.h,
              pinned: true,
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
              flexibleSpace: FlexibleSpaceBar(
                expandedTitleScale: 1,
                centerTitle: true,
                title: LayoutBuilder(builder: (context, constraints) {
                  if (albumMusicController.flexibleSpaceMachineHeight.value ==
                      0.0) {
                    albumMusicController.flexibleSpaceMachineHeight.value =
                        constraints.biggest.height;
                  }
                  final maxHeightToCollapse =
                      albumMusicController.flexibleSpaceMachineHeight.value -
                          (180 - kToolbarHeight);
                  final isTitleBarAppear = ((maxHeightToCollapse).ceil()) ==
                      ((constraints.biggest.height).ceil());
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 60.w),
                    width: double.infinity,
                    child: Opacity(
                      opacity: isTitleBarAppear ? 1.0 : 0.0,
                      child: Text(
                        musicPlayerController
                                .currentActivePlaylist.value?.title ??
                            "Album Music",
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          overflow: TextOverflow.ellipsis,
                          color: Colors.black.withValues(alpha: 1),
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.1, 0.9],
                      colors: <Color>[
                        HexColor('#519756').withValues(alpha: 0.7),
                        HexColor('#ffffff'),
                      ],
                    ),
                  ),
                  padding: EdgeInsets.only(top: kToolbarHeight),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      HomeListFourCover(
                          size: 150,
                          type: musicPlayerController
                              .currentActivePlaylist.value!.type,
                          playlist: musicPlayerController
                              .currentActivePlaylist.value!)
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                // color: Colors.transparent,
                color: HexColor('#fefffe'),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 5.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      musicPlayerController
                              .currentActivePlaylist.value?.title ??
                          "Album Music",
                      maxLines: 3,
                      style: TextStyle(
                        overflow: TextOverflow.ellipsis,
                        color: Colors.black,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        SizedBox(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100.r),
                            child: Image(
                              image:
                                  AssetImage('assets/images/cybeat_splash.png'),
                              width: 30.w,
                              height: 30.h,
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            musicPlayerController
                                .currentActivePlaylist.value!.author,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              overflow: TextOverflow.ellipsis,
                            ),
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SliverAppBar(
              primary: false,
              automaticallyImplyLeading: false,
              toolbarHeight: kToolbarHeight,
              pinned: true,
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                expandedTitleScale: 1,
                background: Container(
                  // color: Colors.transparent,
                  color: HexColor('#fefffe'),
                  width: double.infinity,
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          albumMusicController.shuffleMusic();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w),
                          margin: EdgeInsets.only(left: 18.w),
                          width: 180.w,
                          height: 35.h,
                          decoration: BoxDecoration(
                            color: HexColor('#ac8bc9'),
                            borderRadius: BorderRadius.circular(50.r),
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
                      ),
                      const Expanded(
                        child: SizedBox(),
                      ),
                      IconButton(
                        highlightColor: Colors.black.withValues(alpha: 0.02),
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
              ),
            ),
            StreamBuilder<SequenceState?>(
              stream:
                  audioStateController.activePlayer.value?.sequenceStateStream,
              builder: (context, snapshot) {
                if (snapshot.data?.sequence.isEmpty ??
                    true && albumMusicController.initAlbumLoading.value) {
                  if (audioStateController.isAlbumEmpty.value) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text(
                          'No songs available in this ${musicPlayerController.currentActivePlaylist.value!.type.toLowerCase()}',
                          style: TextStyle(
                            color: Colors.black.withValues(alpha: 0.7),
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                    );
                  }
                  return SliverToBoxAdapter(child: ShimmerMusicList());
                }

                final state = snapshot.data;
                final sequence = state?.sequence ?? [];

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    childCount: sequence.length,
                    (context, index) {
                      return InkWell(
                        // Menghilangkan efek tap.
                        splashFactory: NoSplash.splashFactory,
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        child: AlbumMusicAzlistList(
                          mediaItem: sequence[index].tag as MediaItem,
                          audioPlayer: audioStateController.activePlayer.value!,
                          index: index,
                          audioState: audioStateController,
                        ),
                        onTap: () {
                          albumMusicController.navigateToDetailMusicScreen(
                            sequence: sequence,
                            index: index,
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Obx(
                () => SizedBox(
                  height:
                      musicPlayerController.isMusicActiveNow.value ? 50.h : 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
