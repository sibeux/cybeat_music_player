import 'package:audio_service/audio_service.dart';
import 'package:cybeat_music_player/common/utils/toast.dart';
import 'package:cybeat_music_player/core/controllers/audio_state_controller.dart';
import 'package:cybeat_music_player/core/controllers/music_download_controller.dart';
import 'package:cybeat_music_player/core/controllers/music_player_controller.dart';
import 'package:cybeat_music_player/features/album_music/widgets/album_music_widget_musiclist/album_music_delete_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:just_audio/just_audio.dart';

class ListTileBottomModal extends StatelessWidget {
  const ListTileBottomModal({
    super.key,
    required this.title,
    required this.player,
    required this.mediaItem,
    required this.index,
    required this.audioStateController,
  });

  final String title;
  final AudioPlayer player;
  final MediaItem mediaItem;
  final int index;
  final AudioStateController audioStateController;

  @override
  Widget build(BuildContext context) {
    final musicDownloadController = Get.put(MusicDownloadController());
    final musicPlayerController = Get.find<MusicPlayerController>();

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      minVerticalPadding: 5,
      title: Text(title),
      titleTextStyle: TextStyle(
        color: title.toLowerCase() == 'downloaded'
            ? Colors.grey
            : title.toLowerCase() == 'downloading'
                ? HexColor('#8238be')
                : Colors.black,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
      onTap: () {
        switch (title.toLowerCase()) {
          case 'play now':
            if (musicPlayerController.getCurrentMediaItem?.id == "" ||
                musicPlayerController.getCurrentMediaItem?.id != mediaItem.id) {
              musicPlayerController.playMusicNow(
                audioStateController: audioStateController,
                mediaItem: mediaItem,
              );
              Get.back();
            }
          case 'add to playlist':
            // add music to playlist
            Get.back();
            Get.toNamed(
              '/add_music_to_playlist',
              arguments: {
                'idMusic': mediaItem.extras?['music_id'],
              },
            );
          case 'download':
            // download music
            showRemoveAlbumToast('Downloading music');
            musicDownloadController.downloadOfflineMusic(mediaItem);
            Get.back();
          case 'delete':
            // delete music
            if (musicPlayerController.currentActivePlaylist.value?.isEditable ==
                'true') {
              albumMusicdeleteDialog(
                context: context,
                musicPlayerController: musicPlayerController,
                mediaItem: mediaItem,
                audioState: audioStateController,
              );
            } else {
              showRemoveAlbumToast(
                  'You have no permission to delete this music');
            }
        }
      },
    );
  }
}
