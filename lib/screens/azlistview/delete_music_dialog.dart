import 'package:audio_service/audio_service.dart';
import 'package:cybeat_music_player/components/toast.dart';
import 'package:cybeat_music_player/controller/music_download_controller.dart';
import 'package:cybeat_music_player/controller/playlist_play_controller.dart';
import 'package:cybeat_music_player/providers/audio_state.dart';
import 'package:cybeat_music_player/providers/music_state.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';

void deleteMusicDialog({
  required BuildContext context,
  required PlaylistPlayController playlistPlayController,
  required MediaItem mediaItem,
  required AudioState audioState,
}) {
  Get.dialog(
    name: 'Dialog Delete Music',
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: const Duration(milliseconds: 100),
    AlertDialog(
      backgroundColor: HexColor('#fefffe'),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
      ),
      actionsPadding: const EdgeInsets.only(top: 10),
      contentPadding: const EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: 10,
      ),
      content: Text(
        'Are you sure you want to delete this music?',
        style: TextStyle(
          fontSize: 13,
          color: Colors.black.withOpacity(0.6),
        ),
      ),
      actions: <Widget>[
        Column(
          children: [
            const Divider(
              height: 0.4,
              thickness: 0.4,
            ),
            SizedBox(
              height: 45,
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        alignment: Alignment.center,
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.7),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // *** verticalDivider baru muncul jika row di-wrap sizebox + height
                  // Intinya tinggi harus diatur
                  const VerticalDivider(
                    width: 0.9,
                    thickness: 0.9,
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Get.back();
                        context.read<MusicState>().clear();
                        deleteMusic(
                          playlistPlayController.playlistEditable.value,
                          playlistPlayController.playlistType.value,
                          mediaItem,
                          audioState,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        alignment: Alignment.center,
                        child: Text(
                          'Confirm',
                          style: TextStyle(
                            color: HexColor('#8238be'),
                            fontSize: 14,
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
  AudioState audioState,
) async {
  if (editable == 'true') {
    if (type.toLowerCase() == 'offline') {
      // delete music from offline
      final musicDownloadController = Get.find<MusicDownloadController>();
      await musicDownloadController.deleteSpecificFile(
        mediaItem.extras?['url'],
        mediaItem,
        audioState,
      );
    }
    showRemoveAlbumToast('Music has been deleted from the album');
    Get.back();
  } else {
    showRemoveAlbumToast('You have no permission to delete this music');
  }
}
