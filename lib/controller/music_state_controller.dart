import 'dart:async';

import 'package:cybeat_music_player/models/playlist.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;

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

class PlaylistPlayController extends GetxController {
  var playlistTitle = ''.obs;
  var playlistType = ''.obs;
  var playlistUid = ''.obs;
  var playlistEditable = ''.obs;
  var needRebuild = false.obs;

  void onPlaylist(Playlist playlist) {
    playlistTitle.value = playlist.title;
    playlistType.value = playlist.type.toUpperCase();
    playlistUid.value = playlist.uid;
    playlistEditable.value = playlist.editable;
  }

  Future<void> onPlaylistMusicPlay() async {
    String url =
        'https://sibeux.my.id/cloud-music-player/database/mobile-music-player/api/playlist.php?play_playlist=${playlistUid.value}';
        
    needRebuild.value = true;

    try {
      await http.post(
        Uri.parse(url),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error onPlaylistMusicPlay: $e');
      }
    }
  }

  String get playlistTitleValue {
    return playlistTitle.value;
  }

  String get playlistUidValue {
    return playlistUid.value;
  }
}

class ProgressMusicController extends GetxController {
  var duration = Duration.zero.obs;
  var position = Duration.zero.obs;

  final AudioPlayer player;

  ProgressMusicController({required this.player});

  @override
  void onInit() {
    super.onInit();
    // Subscribe ke stream dan perbarui durasi.
    player.durationStream.listen((event) {
      updateDuration(event);
    });

    // Subscribe ke stream dan perbarui posisi.
    player.positionStream.listen((event) {
      updatePosition(event);
    });
  }

  /*
  untuk kasus stream durasi dan posisi, tidak perlu pakai onclose,
  karena akan selalu ada perubahan durasi dan posisi,
  sehingga tidak perlu di-dispose.

  Akibatnya jika ada subscription dan di-close,
  maka progress bar tidak akan berjalan, karena stream sudah di-close.
  */

  void updateDuration(Duration? duration) {
    // pakai this karena nama parameter sama dengan nama variabel
    this.duration.value = duration ?? Duration.zero;
  }

  void updatePosition(Duration? position) {
    this.position.value = position ?? Duration.zero;
  }
}

class PlayingStateController extends GetxController {
  var isPlaying = false.obs;

  void play() {
    isPlaying.value = true;
  }

  void pause() {
    isPlaying.value = false;
  }
}
