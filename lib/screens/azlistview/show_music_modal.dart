import 'package:audio_service/audio_service.dart';
import 'package:cybeat_music_player/components/toast.dart';
import 'package:cybeat_music_player/controller/music_download_controller.dart';
import 'package:cybeat_music_player/controller/music_state_controller.dart';
import 'package:cybeat_music_player/providers/audio_state.dart';
import 'package:cybeat_music_player/providers/music_state.dart';
import 'package:cybeat_music_player/screens/azlistview/effect_tap_music_modal.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';

Future<dynamic> showMusicModalBottom(BuildContext context, MediaItem mediaItem,
    AudioPlayer audioPlayer, int index, AudioState audioState) {
  return showMaterialModalBottomSheet(
    context: context,
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
                EffectTapMusicModal(
                  child: ListTileBottomModal(
                    title: 'Download',
                    player: audioPlayer,
                    mediaItem: mediaItem,
                    index: index,
                    audioState: audioState,
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
  final AudioState audioState;

  @override
  Widget build(BuildContext context) {
    final playingStateController = Get.put(PlayingStateController());
    final playlistPlayController = Get.put(PlaylistPlayController());
    final musicDownloadController = Get.put(MusicDownloadController());

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      minVerticalPadding: 5,
      title: Text(title),
      titleTextStyle: const TextStyle(
        color: Colors.black,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
      onTap: () {
        switch (title.toLowerCase()) {
          case 'play now':
            if (context.read<MusicState>().currentMediaItem?.id == "" ||
                context.read<MusicState>().currentMediaItem?.id !=
                    mediaItem.id) {
              player.seek(Duration.zero, index: index);

              player.setAudioSource(audioState.playlist, initialIndex: index);

              playingStateController.play();

              context.read<MusicState>().setCurrentMediaItem(mediaItem);

              playlistPlayController.onPlaylistMusicPlay();

              player.play();
              Get.back();
            }
          case 'add to playlist':
            // add music to playlist
            showRemoveAlbumToast('Music has been added to the playlist');
          case 'download':
            // download music
            showRemoveAlbumToast('Downloading music');
            musicDownloadController.downloadAndCacheMusic(mediaItem);
            Get.back();
          case 'delete':
            // delete music
            context.read<MusicState>().clear();
            deleteMusic(
              playlistPlayController.playlistEditable.value,
              playlistPlayController.playlistType.value,
              mediaItem,
              audioState,
            );
        }
      },
    );
  }
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
