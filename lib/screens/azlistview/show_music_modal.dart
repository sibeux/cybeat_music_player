import 'package:audio_service/audio_service.dart';
import 'package:cybeat_music_player/common/utils/toast.dart';
import 'package:cybeat_music_player/controller/music_download_controller.dart';
import 'package:cybeat_music_player/controller/music_play/music_play_method.dart';
import 'package:cybeat_music_player/controller/playlist_play_controller.dart';
import 'package:cybeat_music_player/core/controllers/audio_state_controller.dart';
import 'package:cybeat_music_player/core/controllers/music_state_provider.dart';
import 'package:cybeat_music_player/screens/azlistview/delete_music_dialog.dart';
import 'package:cybeat_music_player/screens/azlistview/effect_tap_music_modal.dart';
import 'package:cybeat_music_player/screens/music_playlist_screen/music_playlist_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:just_audio/just_audio.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';

Future<dynamic> showMusicModalBottom(
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
                  audioState: audioState,
                ),
              ),
              EffectTapMusicModal(
                child: ListTileBottomModal(
                  title: 'Add to playlist',
                  player: audioPlayer,
                  mediaItem: mediaItem,
                  index: index,
                  audioState: audioState,
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
                        audioState: audioState,
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
                  audioState: audioState,
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
    required this.audioState,
  });

  final String title;
  final AudioPlayer player;
  final MediaItem mediaItem;
  final int index;
  final AudioStateController audioState;

  @override
  Widget build(BuildContext context) {
    final playlistPlayController = Get.find<PlaylistPlayController>();
    final musicDownloadController = Get.put(MusicDownloadController());

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
            if (context.read<MusicStateProvider>().currentMediaItem?.id == "" ||
                context.read<MusicStateProvider>().currentMediaItem?.id !=
                    mediaItem.id) {
              playMusicNow(
                audioStateController: audioState,
                index: index,
                context: context,
                mediaItem: mediaItem,
              );
              Get.back();
            }
          case 'add to playlist':
            // add music to playlist
            Get.back();
            Get.to(
              () => MusicPlaylistScreen(
                idMusic: mediaItem.extras?['music_id'],
                audioState: audioState,
              ),
              transition: Transition.downToUp,
              fullscreenDialog: true,
              popGesture: false,
            );
          case 'download':
            // download music
            showRemoveAlbumToast('Downloading music');
            musicDownloadController.downloadOfflineMusic(mediaItem);
            Get.back();
          case 'delete':
            // delete music
            if (playlistPlayController.playlistEditable.value == 'true') {
              deleteMusicDialog(
                context: context,
                playlistPlayController: playlistPlayController,
                mediaItem: mediaItem,
                audioState: audioState,
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
