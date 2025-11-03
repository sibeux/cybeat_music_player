import 'package:cybeat_music_player/features/album_music/controllers/album_music_controller.dart';
import 'package:cybeat_music_player/core/controllers/music_download_controller.dart';
import 'package:cybeat_music_player/core/controllers/audio_state_controller.dart';
import 'package:cybeat_music_player/core/controllers/music_player_controller.dart';
import 'package:cybeat_music_player/features/album_music/widgets/album_music_content/album_music_main_appbar.dart';
import 'package:cybeat_music_player/features/album_music/widgets/album_music_content/album_music_search_bar.dart';
import 'package:cybeat_music_player/features/album_music/widgets/album_music_content/album_music_shuffle_add_all.dart';
import 'package:cybeat_music_player/features/album_music/widgets/album_music_list_mode/simple_mode/simple_view_mode.dart';
import 'package:cybeat_music_player/features/album_music/widgets/album_music_content/album_music_list_music.dart';
import 'package:cybeat_music_player/features/album_music/widgets/album_music_content/album_music_title_artist.dart';
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

    return PopScope(
      // Logic saat back button bawaan hp ditekan.
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          if (musicPlayerController.currentActivePlaylist.value!.type
                  .toLowerCase() ==
              'offline') {
            return;
          }
          albumMusicController.rebuildPlaylist();
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
                  () => albumMusicController.isTapSearch.value
                      ? AlbumMusicSearchBar(
                          albumMusicController: albumMusicController)
                      :
                      // Appbar utama + gambar album
                      AlbumMusicMainAppbar(
                          albumMusicController: albumMusicController,
                          musicPlayerController: musicPlayerController,
                        ),
                ),
                // Title dan Artist
                AlbumMusicTitleArtist(
                  albumMusicController: albumMusicController,
                  musicPlayerController: musicPlayerController,
                ),
                // Tombol Shuffle + Add All
                AlbumMusicShuffleAddAll(
                    albumMusicController: albumMusicController),
                // List musik
                AlbumMusicListMusic(
                  albumMusicController: albumMusicController,
                  audioStateController: audioStateController,
                  musicPlayerController: musicPlayerController,
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
