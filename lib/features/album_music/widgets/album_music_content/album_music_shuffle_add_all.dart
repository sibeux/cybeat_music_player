import 'package:cybeat_music_player/features/album_music/controllers/album_music_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';

class AlbumMusicShuffleAddAll extends StatelessWidget {
  const AlbumMusicShuffleAddAll({
    super.key,
    required this.albumMusicController,
  });

  final AlbumMusicController albumMusicController;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => albumMusicController.isTapSearch.value
          ? SliverToBoxAdapter(
              child: SizedBox(
                height: 0.h,
              ),
            )
          : SliverAppBar(
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
    );
  }
}
