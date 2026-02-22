import 'package:audio_service/audio_service.dart';
import 'package:cybeat_music_player/common/utils/toast.dart';
import 'package:cybeat_music_player/core/controllers/audio_state_controller.dart';
import 'package:cybeat_music_player/core/controllers/music_player_controller.dart';
import 'package:cybeat_music_player/core/models/music.dart';
import 'package:cybeat_music_player/core/services/album_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class AlbumMusicController extends GetxController {
  final AudioStateController audioStateController = Get.find();
  final musicPlayerController = Get.find<MusicPlayerController>();
  final AlbumService albumService = Get.find();
  final textController = TextEditingController();

  var flexibleSpaceMachineHeight = 0.0.obs;
  var jumlahMusicDitampilkan = 0.obs;
  var countMusicAlbum = 0;
  var sisaJumlahMusicTersedia = 0;

  var textValue = ''.obs;
  var filteredMusic = RxList<Music>([]);

  var isTapSearch = false.obs;
  var isTyping = false.obs;
  var isSearch = false.obs;
  var isKeybordFocus = false.obs;
  var underLoadingFetchMusic = false;

  RxBool get initAlbumLoading => audioStateController.initAlbumLoading;
  RxString get defaultAlbumColor => albumService.defaultAlbumColor;
  bool get isSimpleMode => albumService.isSimpleMode.value;

  // logic untuk shuffle music.
  void shuffleMusic() {
    if (initAlbumLoading.value) {
      showRemoveAlbumToast('Wait a moment...');
    } else if (audioStateController.isAlbumEmpty.value) {
      showRemoveAlbumToast('Album is empty');
    } else {
      musicPlayerController.seekNextButton(isFromShuffleButton: true);
      // Langsung buka detail screen.
      Get.toNamed('/detail');
    }
  }

  void toggleTapIconSearch() {
    if (initAlbumLoading.value) {
      showRemoveAlbumToast('Wait a moment...');
    } else if (audioStateController.isAlbumEmpty.value) {
      showRemoveAlbumToast('Album is empty');
    } else {
      isTapSearch.value = !isTapSearch.value;
      filterAlbum('');
    }
  }

  void onTyping(String value) {
    isTyping.value = value.isNotEmpty;
    update();
  }

  void onChanged(String value) {
    isTyping.value = value.isNotEmpty;
    textValue.value = value;
    isKeybordFocus.value = true;
    filterAlbum(value);
    update();
  }

  void backButtonSearchTapped() async {
    isKeybordFocus.value
        ? await Future.delayed(const Duration(milliseconds: 100), () {
            toggleTapIconSearch();
            isKeybordFocus.value = false;
          })
        : toggleTapIconSearch();
    // untuk menghilangkan keyboard
    FocusManager.instance.primaryFocus?.unfocus();
    clearTextField();
  }

  void clearTextField() {
    textController.clear();
    textValue.value = '';
    isTyping.value = false;
    filterAlbum('');
  }

  void filterAlbum(String value) {
    final results = audioStateController.playlist
        .where((music) =>
            music.title.toLowerCase().contains(value.toLowerCase()) ||
            music.artist.toLowerCase().contains(value.toLowerCase()))
        .toList();
    filteredMusic.value = results;
    isSearch.value = !isSearch.value;
  }

  void updateLastPlayedAlbum(String uid) async {
    await albumService.updateLastPlayedAlbum(uid);
  }

  void rebuildPlaylist() {
    // Untuk build ulang susunan album di home screen.
    if (musicPlayerController.isNeedRebuildLastPlaylist.value) {
      musicPlayerController.isNeedRebuildLastPlaylist.value = false;
      // Method untuk update playlsit terakhir yang diputar.
      updateLastPlayedAlbum(
          musicPlayerController.currentActivePlaylist.value!.uid);
    }
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
    FocusManager.instance.primaryFocus?.unfocus();
    final mediaItem = MediaItem(
      id: music.musicId.toString(),
      title: music.title,
      album: music.album,
      artUri: Uri.parse(music.cover),
      artist: music.artist,
      extras: music.extras,
    );
    final musicList =
        isTapSearch.value ? filteredMusic : audioStateController.playlist;
    Get.toNamed('/detail');
    if (musicPlayerController.getCurrentMediaItem?.id == "" ||
        musicPlayerController.getCurrentMediaItem?.id !=
            musicList[index].musicId.toString()) {
      musicPlayerController.playMusicNow(
        mediaItem: mediaItem,
        audioStateController: audioStateController,
      );
    }
  }

  void onLoading(RefreshController refreshController) {
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
