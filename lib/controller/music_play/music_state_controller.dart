import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:cybeat_music_player/controller/floating_playing_music/floating_playing_music_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

// Buat sebuah controller untuk mengelola state.
class MusicStateController extends GetxController {
  var musicId = ''.obs;
  var musicUri = ''.obs;
  var title = ''.obs;
  var artist = ''.obs;
  var album = ''.obs;
  var cover = ''.obs;

  var currentMusicPlay = RxList<MediaItem>([]);

  StreamSubscription<SequenceState?>? playerSubscription;
  // Terpaksa di-Get.put karena rawan terjadi error controller tidak ditemukan.
  final floatingPlayingMusicController =
      Get.put(FloatingPlayingMusicController());

  // Constructor untuk menginisialisasi player.
  // MusicStateController({required this.player});

  // final AudioPlayer player;

  // @override
  // void onInit() {
  //   super.onInit();
  //   // Subscribe ke stream dan perbarui state.
  //   playerSubscription = player.sequenceStateStream.listen((sequenceState) {
  //     updateState(sequenceState);
  //   });
  // }

  @override
  void onClose() {
    // Batalkan subscription saat controller dihapus.
    playerSubscription?.cancel();
    super.onClose();
  }

  void streamAudioPlayer(
    AudioPlayer player,
    MediaItem mediaItem,
  ) {
    // Subscribe ke stream dan perbarui state.
    playerSubscription = player.sequenceStateStream.listen((sequenceState) {
      updateState(sequenceState);
    });

    // Masukkan data musik ke variable observable.
    musicId.value = mediaItem.extras!['music_id'] ?? '';
    musicUri.value = mediaItem.extras!['url'];
    title.value = mediaItem.title;
    artist.value = mediaItem.artist ?? '';
    album.value = mediaItem.album ?? '';
    cover.value = mediaItem.artUri.toString();
  }

  void updateState(SequenceState? sequenceState) {
    currentMusicPlay.value = [sequenceState?.currentSource?.tag as MediaItem];

    musicId.value = sequenceState?.currentSource?.tag.extras?['music_id'] ?? '';
    musicUri.value = sequenceState?.currentSource?.tag.extras?['url'] ?? '';
    title.value = sequenceState?.currentSource?.tag.title ?? '';
    artist.value = sequenceState?.currentSource?.tag.artist ?? '';
    album.value = sequenceState?.currentSource?.tag.album ?? '';
    cover.value = sequenceState?.currentSource?.tag.artUri.toString() ??
        'https://raw.githubusercontent.com/sibeux/license-sibeux/MyProgram/placeholder_cover_music.png';

    // Ini penyebab ada junk lama saat ganti lagu.
    if (cover.value.contains('.webp')) {
      floatingPlayingMusicController.listColor.value = [
        Colors.black,
        Colors.white
      ];
    } else {
      floatingPlayingMusicController.getDominantColor(cover.value);
    }
  }
}
