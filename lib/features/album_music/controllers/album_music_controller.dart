import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:cybeat_music_player/common/utils/toast.dart';
import 'package:cybeat_music_player/core/controllers/audio_state_controller.dart';
import 'package:cybeat_music_player/core/controllers/music_player_controller.dart';
import 'package:cybeat_music_player/core/models/music.dart';
import 'package:cybeat_music_player/core/services/album_service.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class AlbumMusicController extends GetxController {
  final AudioStateController audioStateController = Get.find();
  final musicPlayerController = Get.find<MusicPlayerController>();
  final AlbumService albumService = Get.find();
  final RefreshController refreshController =
      RefreshController(initialRefresh: false);

  var flexibleSpaceMachineHeight = 0.0.obs;
  var jumlahMusicDitampilkan = 0.obs;

  var countMusicAlbum = 0;
  var sisaJumlahMusicTersedia = 0;
  var underLoadingFetchMusic = false;

  RxBool get initAlbumLoading => audioStateController.initAlbumLoading;
  RxString get defaultAlbumColor => albumService.defaultAlbumColor;
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
    required int index,
    required Music music,
  }) {
    final mediaItem = MediaItem(
      id: music.musicId,
      title: music.title,
      album: music.album,
      artUri: Uri.parse(music.cover),
      artist: music.artist,
      extras: music.extras,
    );
    final musicList = audioStateController.playlist;
    Get.toNamed('/detail');
    if (musicPlayerController.getCurrentMediaItem?.id == "" ||
        musicPlayerController.getCurrentMediaItem?.id !=
            musicList[index].musicId) {
      musicPlayerController.playMusicNow(
        mediaItem: mediaItem,
        audioStateController: audioStateController,
      );
    }
  }

  void onLoading() {
    if (!underLoadingFetchMusic && sisaJumlahMusicTersedia == 0) {
      refreshController.loadNoData();
    } else {
      if (sisaJumlahMusicTersedia >= 100) {
        jumlahMusicDitampilkan.value += 100;
        sisaJumlahMusicTersedia -= 100;
      } else {
        jumlahMusicDitampilkan.value += sisaJumlahMusicTersedia;
        sisaJumlahMusicTersedia = 0;
      }
      refreshController.loadComplete();
    }
  }
}
