import 'package:cybeat_music_player/core/controllers/music_player_controller.dart';
import 'package:cybeat_music_player/features/album_music/controllers/album_music_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class AlbumMusicTitleArtist extends StatelessWidget {
  const AlbumMusicTitleArtist({
    super.key,
    required this.albumMusicController,
    required this.musicPlayerController,
  });

  final AlbumMusicController albumMusicController;
  final MusicPlayerController musicPlayerController;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SliverToBoxAdapter(
        child: albumMusicController.isTapSearch.value
            ? SizedBox(
                height: 0.h,
              )
            : Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 5.h),
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
    );
  }
}
