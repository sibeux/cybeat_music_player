import 'package:audio_service/audio_service.dart';
import 'package:cybeat_music_player/core/controllers/music_download_controller.dart';
import 'package:cybeat_music_player/core/controllers/audio_state_controller.dart';
import 'package:cybeat_music_player/core/controllers/music_player_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';

void albumMusicdeleteDialog({
  required BuildContext context,
  required MusicPlayerController musicPlayerController,
  required MediaItem mediaItem,
  required AudioStateController audioState,
}) {
  Get.dialog(
    name: 'Dialog Delete Music',
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    transitionDuration: const Duration(milliseconds: 100),
    AlertDialog(
      backgroundColor: HexColor('#fefffe'),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
      ),
      actionsPadding: EdgeInsets.only(top: 10.h),
      contentPadding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 20.h,
        bottom: 10.h,
      ),
      content: Text(
        'Are you sure you want to delete this music?',
        style: TextStyle(
          fontSize: 13.sp,
          color: Colors.black.withValues(alpha: 0.6),
        ),
      ),
      actions: <Widget>[
        Column(
          children: [
             Divider(
              height: 0.4.h,
              thickness: 0.4.h,
            ),
            SizedBox(
              height: 45.h,
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: Container(
                        padding:  EdgeInsets.symmetric(horizontal: 20.w),
                        alignment: Alignment.center,
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.black.withValues(alpha: 0.7),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // *** verticalDivider baru muncul jika row di-wrap sizebox + height
                  // Intinya tinggi harus diatur
                   VerticalDivider(
                    width: 0.9.w,
                    thickness: 0.9,
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Get.back();
                        musicPlayerController.clearCurrentMediaItem();
                        deleteMusic(
                          musicPlayerController
                                  .currentActivePlaylist.value?.isEditable ??
                              '',
                          musicPlayerController
                                  .currentActivePlaylist.value?.type ??
                              '',
                          mediaItem,
                          audioState,
                        );
                      },
                      child: Container(
                        padding:  EdgeInsets.symmetric(horizontal: 20.w),
                        alignment: Alignment.center,
                        child: Text(
                          'Confirm',
                          style: TextStyle(
                            color: HexColor('#8238be'),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        )
      ],
    ),
  );
}

void deleteMusic(
  String editable,
  String type,
  MediaItem mediaItem,
  AudioStateController audioState,
) async {
  if (type.toLowerCase() == 'offline') {
    // delete music from offline
    final musicDownloadController = Get.find<MusicDownloadController>();
    await musicDownloadController.deleteSpecificFile(
      mediaItem.extras?['url'],
      mediaItem,
      audioState,
    );
  } else if (type.toLowerCase() == 'playlist') {
    // delete music from playlist
    audioState.deleteMusicFromPlaylist(
      idPlaylistMusic: mediaItem.extras?['id_playlist_music'],
    );
  }
}
