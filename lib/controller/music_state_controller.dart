import 'dart:async';

import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

// Buat sebuah controller untuk mengelola state.
class MusicStateController extends GetxController {
  var album = ''.obs;
  var cover = ''.obs;

  StreamSubscription<SequenceState?>? playerSubscription;

  MusicStateController({required this.player});

  final AudioPlayer player;

  @override
  void onInit() {
    super.onInit();
    // Subscribe ke stream dan perbarui state.
    playerSubscription = player.sequenceStateStream.listen((sequenceState) {
      updateAlbum(sequenceState);
    });
  }

  @override
  void onClose() {
    // Batalkan subscription saat controller dihapus.
    playerSubscription?.cancel();
    super.onClose();
  }

  void updateAlbum(SequenceState? sequenceState) {
    album.value = sequenceState?.currentSource?.tag.album ?? '';
    cover.value = sequenceState?.currentSource?.tag.artUri.toString() ??
        'https://raw.githubusercontent.com/sibeux/license-sibeux/MyProgram/placeholder_cover_music.png';
  }
}
