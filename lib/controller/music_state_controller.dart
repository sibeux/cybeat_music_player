import 'dart:async';

import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

// Buat sebuah controller untuk mengelola state.
class MusicStateController extends GetxController {
  var title = ''.obs;
  var artist = ''.obs;
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
      updateState(sequenceState);
    });
  }

  @override
  void onClose() {
    // Batalkan subscription saat controller dihapus.
    playerSubscription?.cancel();
    super.onClose();
  }

  void updateState(SequenceState? sequenceState) {
    title.value = sequenceState?.currentSource?.tag.title ?? '';
    artist.value = sequenceState?.currentSource?.tag.artist ?? '';
    album.value = sequenceState?.currentSource?.tag.album ?? '';
    cover.value = sequenceState?.currentSource?.tag.artUri.toString() ??
        'https://raw.githubusercontent.com/sibeux/license-sibeux/MyProgram/placeholder_cover_music.png';
  }
}
