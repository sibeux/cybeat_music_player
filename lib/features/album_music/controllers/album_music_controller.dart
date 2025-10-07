import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:cybeat_music_player/common/utils/toast.dart';
import 'package:cybeat_music_player/core/controllers/audio_state_controller.dart';
import 'package:cybeat_music_player/core/controllers/music_player_controller.dart';
import 'package:cybeat_music_player/core/services/album_service.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

class AlbumMusicController extends GetxController {
  final AudioStateController audioStateController = Get.find();
  final musicPlayerController = Get.find<MusicPlayerController>();
  final AlbumService albumService = Get.find();

  var flexibleSpaceMachineHeight = 0.0.obs;

  RxBool get initAlbumLoading => audioStateController.initAlbumLoading;
  bool get isSimpleMode => albumService.isSimpleMode.value;

  // logic untuk shuffle music.
  void shuffleMusic() {
    final sequence = audioStateController.activePlayer.value?.sequence;
    final index = audioStateController.playlist.length < 2
        ? 0
        : random(0, audioStateController.playlist.length - 1);
    if (initAlbumLoading.value) {
      showRemoveAlbumToast('Wait a moment...');
    } else if (audioStateController.isAlbumEmpty.value) {
      showRemoveAlbumToast('Album is empty');
    } else {
      // Langsung buka detail screen.
      Get.toNamed('/detail');
      musicPlayerController.playMusicNow(
        audioStateController: audioStateController,
        index: index,
        mediaItem: sequence![index].tag as MediaItem,
      );
    }
  }

  int random(int min, int max) {
    return min + Random().nextInt(max - min);
  }

  void updateLastPlayedAlbum(String uid) async {
    await albumService.updateLastPlayedAlbum(uid);
  }

  void getToAddAllMusicToPlaylistScreen() {
    if (initAlbumLoading.value) {
      showRemoveAlbumToast('Wait a moment...');
    } else if (audioStateController.isAlbumEmpty.value) {
      showRemoveAlbumToast('Album is empty');
    } else {
      Get.toNamed("/add_all_music_to_playlist");
    }
  }

  void navigateToDetailMusicScreen({
    required List<IndexedAudioSource> sequence,
    required int index,
  }) {
    Get.toNamed('/detail');
    if (musicPlayerController.getCurrentMediaItem?.id == "" ||
        musicPlayerController.getCurrentMediaItem?.id !=
            sequence[index].tag.id) {
      musicPlayerController.playMusicNow(
        mediaItem: sequence[index].tag as MediaItem,
        audioStateController: audioStateController,
        index: index,
      );
    }
  }
}
