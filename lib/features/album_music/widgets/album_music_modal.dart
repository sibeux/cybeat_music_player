import 'package:audio_service/audio_service.dart';
import 'package:cybeat_music_player/common/utils/toast.dart';
import 'package:cybeat_music_player/core/controllers/music_download_controller.dart';
import 'package:cybeat_music_player/core/controllers/audio_state_controller.dart';
import 'package:cybeat_music_player/core/controllers/music_player_controller.dart';
import 'package:cybeat_music_player/features/album_music/widgets/delete_music_dialog.dart';
import 'package:cybeat_music_player/features/album_music/widgets/effect_tap_music_modal.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:just_audio/just_audio.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

Future<dynamic> albumMusicModal(
  BuildContext context,
  MediaItem mediaItem,
  AudioPlayer audioPlayer,
  int index,
  AudioStateController audioState,
) {
  final musicDownloadController = Get.find<MusicDownloadController>();
  return showMaterialModalBottomSheet(
    context: context,
    // Pakai {useRootNavigator: true} agar modal bottom sheet tidak terhalangi-
    // oleh FloatingPlayingMusic dari root_page.dart
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    clipBehavior: Clip.antiAliasWithSaveLayer,
    builder: (context) => Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(
          Radius.circular(20),
        ),
      ),
      margin: const EdgeInsets.all(12),
      child: Column(
        // mainAxisSize: MainAxisSize.min - mencegah layar full
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              mediaItem.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(height: 10),
          // by default, ListTile has a padding of 16
          Column(
            children: [
              EffectTapMusicModal(
                child: ListTileBottomModal(
                  title: 'Play now',
                  player: audioPlayer,
                  mediaItem: mediaItem,
                  index: index,
                  audioStateController: audioState,
                ),
              ),
              EffectTapMusicModal(
                child: ListTileBottomModal(
                  title: 'Add to playlist',
                  player: audioPlayer,
                  mediaItem: mediaItem,
                  index: index,
                  audioStateController: audioState,
                ),
              ),
              if (mediaItem.extras?['url'].contains('http'))
                AbsorbPointer(
                  absorbing: mediaItem.extras?['is_downloaded'] ||
                      musicDownloadController.dataProgressDownload[
                                  mediaItem.extras?['music_id']] !=
                              null &&
                          musicDownloadController.dataProgressDownload[
                                  mediaItem.extras?['music_id']]!['progress'] !=
                              0.0,
                  child: EffectTapMusicModal(
                    child: Obx(
                      () => ListTileBottomModal(
                        title: musicDownloadController.dataProgressDownload[
                                        mediaItem.extras?['music_id']] !=
                                    null &&
                                musicDownloadController.dataProgressDownload[
                                            mediaItem.extras?['music_id']]![
                                        'progress'] !=
                                    0.0
                            ? 'Downloading'
                            : mediaItem.extras?['is_downloaded'] ?? false
                                ? 'Downloaded'
                                : 'Download',
                        player: audioPlayer,
                        mediaItem: mediaItem,
                        index: index,
                        audioStateController: audioState,
                      ),
                    ),
                  ),
                ),
              EffectTapMusicModal(
                child: ListTileBottomModal(
                  title: 'Delete',
                  player: audioPlayer,
                  mediaItem: mediaItem,
                  index: index,
                  audioStateController: audioState,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    ),
  );
}

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
                index: index,
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
            if (musicPlayerController.currentActivePlaylist.value?.editable ==
                'true') {
              deleteMusicDialog(
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
