import 'package:audio_service/audio_service.dart';
import 'package:cybeat_music_player/core/controllers/music_download_controller.dart';
import 'package:cybeat_music_player/core/controllers/audio_state_controller.dart';
import 'package:cybeat_music_player/features/album_music/widgets/album_music_widget_musiclist/album_music_effect_tap_modal.dart';
import 'package:cybeat_music_player/features/album_music/widgets/album_music_widget_musiclist/list_tile_bottom_modal.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
              AlbumMusicEffectTapModal(
                child: ListTileBottomModal(
                  title: 'Play now',
                  player: audioPlayer,
                  mediaItem: mediaItem,
                  index: index,
                  audioStateController: audioState,
                ),
              ),
              AlbumMusicEffectTapModal(
                child: ListTileBottomModal(
                  title: 'Add to playlist',
                  player: audioPlayer,
                  mediaItem: mediaItem,
                  index: index,
                  audioStateController: audioState,
                ),
              ),
              if (mediaItem.extras?['url'].contains('http') ||
                  mediaItem.extras?['url'].contains('cdncloudflare/'))
                AbsorbPointer(
                  absorbing: mediaItem.extras?['is_downloaded'] ||
                      musicDownloadController.dataProgressDownload[
                                  mediaItem.extras?['music_id']] !=
                              null &&
                          musicDownloadController.dataProgressDownload[
                                  mediaItem.extras?['music_id']]!['progress'] !=
                              0.0,
                  child: AlbumMusicEffectTapModal(
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
              AlbumMusicEffectTapModal(
                child: ListTileBottomModal(
                  title: 'Delete',
                  player: audioPlayer,
                  mediaItem: mediaItem,
                  index: index,
                  audioStateController: audioState,
                ),
              ),
              AlbumMusicEffectTapModal(
                child: ListTileBottomModal(
                  title: 'View Credits',
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
