import 'package:cybeat_music_player/core/controllers/music_player_controller.dart';
import 'package:cybeat_music_player/features/album_music/controllers/album_music_controller.dart';
import 'package:cybeat_music_player/features/home/widgets/home_list/home_list_four_cover.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';

class AlbumMusicMainAppbar extends StatelessWidget {
  const AlbumMusicMainAppbar({
    super.key,
    required this.albumMusicController,
    required this.musicPlayerController,
  });

  final AlbumMusicController albumMusicController;
  final MusicPlayerController musicPlayerController;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SliverAppBar(
        // backgroundColor: Colors.transparent,
        backgroundColor: HexColor('#fefffe'),
        surfaceTintColor: HexColor(albumMusicController.defaultAlbumColor.value)
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
            if (musicPlayerController.currentActivePlaylist.value!.type
                    .toLowerCase() ==
                'offline') {
              return;
            }
            albumMusicController.rebuildPlaylist();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.search_rounded,
            ),
            color: Colors.black,
            tooltip: 'Search',
            onPressed: () {
              albumMusicController.toggleTapIconSearch();
            },
          ),
        ],
        flexibleSpace: FlexibleSpaceBar(
          expandedTitleScale: 1,
          centerTitle: true,
          title: LayoutBuilder(builder: (context, constraints) {
            if (albumMusicController.flexibleSpaceMachineHeight.value == 0.0) {
              albumMusicController.flexibleSpaceMachineHeight.value =
                  constraints.biggest.height;
            }
            final maxHeightToCollapse =
                albumMusicController.flexibleSpaceMachineHeight.value -
                    (180.h - kToolbarHeight);
            final isTitleBarAppear = ((maxHeightToCollapse).ceil()) ==
                ((constraints.biggest.height).ceil());
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 60.w),
              width: double.infinity,
              child: Opacity(
                opacity: isTitleBarAppear ? 1.0 : 0.0,
                child: Text(
                  musicPlayerController.currentActivePlaylist.value?.title ??
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
                  HexColor(albumMusicController.defaultAlbumColor.value)
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
                    type:
                        musicPlayerController.currentActivePlaylist.value!.type,
                    album: musicPlayerController.currentActivePlaylist.value!)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
