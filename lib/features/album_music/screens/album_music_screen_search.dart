import 'package:cybeat_music_player/features/album_music/controllers/album_music_controller.dart';
import 'package:cybeat_music_player/core/controllers/music_download_controller.dart';
import 'package:cybeat_music_player/core/controllers/audio_state_controller.dart';
import 'package:cybeat_music_player/core/controllers/music_player_controller.dart';
import 'package:cybeat_music_player/common/widgets/shimmer_music_list.dart';
import 'package:cybeat_music_player/features/album_music/widgets/album_music_list_mode/azlist_mode/album_music_azlist_list.dart';
import 'package:cybeat_music_player/features/album_music/widgets/album_music_list_mode/simple_mode/album_music_simple_list.dart';
import 'package:cybeat_music_player/features/album_music/widgets/album_music_list_mode/simple_mode/simple_view_mode.dart';
import 'package:cybeat_music_player/features/home/widgets/home_list/home_list_four_cover.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:azlistview/azlistview.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

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
        body: ScrollConfiguration(
          behavior: NoGlowScrollBehavior(),
          child: SmartRefresher(
            controller: albumMusicController.refreshController,
            onLoading: albumMusicController.onLoading,
            enablePullDown: false,
            enablePullUp: true,
            footer: ClassicFooter(
              height: 60.h,
              loadStyle: LoadStyle.ShowWhenLoading,
              loadingIcon: SizedBox(
                width: 25.w,
                height: 25.h,
                child: CircularProgressIndicator(
                  color: Colors.black,
                  strokeWidth: 2.w,
                ),
              ),
              idleText: 'Pull up to load more',
              loadingText: 'Loading data...',
              noDataText: 'No more data',
              textStyle: TextStyle(
                color: Colors.black,
                fontSize: 12.sp,
              ),
            ),
            child: CustomScrollView(
              slivers: [
                Obx(
                  () => SliverAppBar(
                    // backgroundColor: Colors.transparent,
                    backgroundColor: HexColor('#fefffe'),
                    surfaceTintColor:
                        HexColor(albumMusicController.defaultAlbumColor.value)
                            .withValues(alpha: 1),
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
                        if (musicPlayerController
                                .currentActivePlaylist.value!.type
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
                        if (albumMusicController
                                .flexibleSpaceMachineHeight.value ==
                            0.0) {
                          albumMusicController.flexibleSpaceMachineHeight
                              .value = constraints.biggest.height;
                        }
                        final maxHeightToCollapse = albumMusicController
                                .flexibleSpaceMachineHeight.value -
                            (180.h - kToolbarHeight);
                        final isTitleBarAppear =
                            ((maxHeightToCollapse).ceil()) ==
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
                      background: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: const [0.1, 0.9],
                            colors: <Color>[
                              HexColor(albumMusicController
                                      .defaultAlbumColor.value)
                                  .withValues(alpha: 0.8),
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
                ),
                SliverToBoxAdapter(
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 5.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 5.h,
                        ),
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
                                  image: AssetImage(
                                      'assets/images/cybeat_splash.png'),
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
                  ),
                ),
                Obx(
                  () {
                    if (albumMusicController.initAlbumLoading.value) {
                      return SliverToBoxAdapter(child: ShimmerMusicList());
                    }
                    if (audioStateController.playlist.isEmpty) {
                      if (audioStateController.isAlbumEmpty.value) {
                        albumMusicController.underLoadingFetchMusic = false;
                        albumMusicController.sisaJumlahMusicTersedia = 0;
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
                      albumMusicController.underLoadingFetchMusic = true;
                    }

                    albumMusicController.underLoadingFetchMusic = false;
                    final musicList = audioStateController.playlist;
                    if (albumMusicController.countMusicAlbum == 0) {
                      albumMusicController.countMusicAlbum = musicList.length;
                      albumMusicController.jumlahMusicDitampilkan.value =
                          musicList.length >= 100 ? 100 : musicList.length;
                      albumMusicController.sisaJumlahMusicTersedia =
                          musicList.length -
                              albumMusicController.jumlahMusicDitampilkan.value;
                    }

                    return Obx(
                      () => SliverList(
                        delegate: SliverChildBuilderDelegate(
                          childCount:
                              albumMusicController.jumlahMusicDitampilkan.value,
                          (context, index) {
                            return Obx(
                              () => InkWell(
                                // Menghilangkan efek tap.
                                splashFactory: NoSplash.splashFactory,
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                child: albumMusicController.isSimpleMode
                                    ? AlbumMusicSimpleList(
                                        index: index,
                                        music: musicList[index],
                                        audioStateController:
                                            audioStateController,
                                        albumMusicController:
                                            albumMusicController,
                                      )
                                    : AlbumMusicAzlistList(
                                        music: musicList[index],
                                        audioPlayer: audioStateController
                                            .activePlayer.value!,
                                        index: index,
                                        audioState: audioStateController,
                                      ),
                                onTap: () {
                                  albumMusicController
                                      .navigateToDetailMusicScreen(
                                    music: musicList[index],
                                    index: index,
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Obx(
                    () => SizedBox(
                      height: musicPlayerController.isMusicActiveNow.value
                          ? 50.h
                          : 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
