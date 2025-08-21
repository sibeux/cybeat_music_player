import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:cybeat_music_player/common/utils/colorize_terminal.dart';
import 'package:cybeat_music_player/core/controllers/audio_state_controller.dart';
import 'package:cybeat_music_player/core/models/playlist.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';

class MusicPlayerController extends GetxController {
  var currentActivePlaylist = Rx<Playlist?>(null);
  final _currentMediaItem = Rx<MediaItem?>(null);

  var isPlayingNow = false.obs;
  var isNeedRebuildLastPlaylist = false.obs;
  var isAzlistviewScreenActive = false.obs;

  var listColor = RxList<Color>([Colors.black, Colors.white]);

  var currentMusicDuration = Duration.zero.obs;
  var currentMusicPosition = Duration.zero.obs;

  StreamSubscription<Duration?>? durationStreamSubscription;
  StreamSubscription<Duration?>? positionStreamSubscription;
  StreamSubscription<SequenceState?>? sequenceStateStreamSubscription;

  MediaItem? get getCurrentMediaItem => _currentMediaItem.value;

  @override
  void onReady() {
    super.onReady();
    final audioStateController = Get.find<AudioStateController>();
    // 'ever' akan mendengarkan perubahan pada audioStateController.player
    // dan menjalankan _listenToPlayerStreams setiap kali nilainya berubah.
    ever(audioStateController.activePlayer, _listenToPlayerStreams);
  }

  // Fungsi baru untuk menangani semua logika subscription
  void _listenToPlayerStreams(AudioPlayer? player) {
    // 1. Selalu batalkan subscription lama untuk mencegah kebocoran memori
    _cancelSubscriptions();

    // 2. Jika player baru tidak null, buat subscription baru
    if (player != null) {
      durationStreamSubscription = player.durationStream.listen((duration) {
        updateCurrentMusicDuration(duration);
      });

      positionStreamSubscription = player.positionStream.listen((position) {
        updateCurrentMusicPosition(position);
      });

      sequenceStateStreamSubscription =
          player.sequenceStateStream.listen((sequenceState) {
        // PERBAIKAN: Tambahkan null check untuk menghindari error
        final mediaItem = sequenceState.currentSource?.tag as MediaItem?;
        // getCurrentMediaItem != null berfungsi untuk cek apakah ini pertama kali-
        // buka album atau tidak.
        // By default, audio player udah "siap" putar dari indeks pertama.
        if (mediaItem != null && getCurrentMediaItem != null) {
          updateCurrentMediaItem(mediaItem);
          getDominantColor(mediaItem.artUri.toString());
        }
      });
    }
  }

  // Fungsi helper untuk membatalkan semua subscription
  void _cancelSubscriptions() {
    durationStreamSubscription?.cancel();
    positionStreamSubscription?.cancel();
    sequenceStateStreamSubscription?.cancel();
  }

  @override
  void onClose() {
    // Panggil fungsi cancel di onClose untuk pembersihan akhir
    _cancelSubscriptions();
    super.onClose();
  }

  // ** INI UDAH GAK BERLAKU, KARENA CONTROLLER INI ABADI.
  /*
  untuk kasus stream durasi dan posisi, tidak perlu pakai onclose,
  karena akan selalu ada perubahan durasi dan posisi,
  sehingga tidak perlu di-dispose.

  Akibatnya jika ada subscription dan di-close,
  maka progress bar tidak akan berjalan, karena stream sudah di-close.
  */
  // ** ----------------------------------------------------

  void updateCurrentMusicDuration(Duration? duration) {
    // pakai this karena nama parameter sama dengan nama variabel
    currentMusicDuration.value = duration ?? Duration.zero;
  }

  void updateCurrentMusicPosition(Duration? position) {
    currentMusicPosition.value = position ?? Duration.zero;
  }

  void updateCurrentMediaItem(MediaItem mediaItem) {
    _currentMediaItem.value = mediaItem;
  }

  void clearCurrentMediaItem() {
    _currentMediaItem.value = null;
  }

  void playMusic() {
    isPlayingNow.value = true;
  }

  void pauseMusic() {
    isPlayingNow.value = false;
  }

  void setActivePlaylist(Playlist playlist) {
    // Setiap album/playlist yang di-play akan disimpan di currentPlaylistPlay.
    // Isinya hanya 1, yaitu album/playlist yang sedang di-play.
    currentActivePlaylist.value = playlist;
  }

  Future<void> setLastPlayingPlaylist() async {
    const endpoint =
        "https://sibeux.my.id/cloud-music-player/database/mobile-music-player/api/playlist";
    String api = '$endpoint?play_playlist=${currentActivePlaylist.value?.uid}';
    try {
      await http.post(
        Uri.parse(api),
      );
      isNeedRebuildLastPlaylist.value = true;
    } catch (e) {
      logError('Error setLastPlayingPlaylist: $e');
    }
  }

  void playMusicNow({
    required AudioStateController audioStateController,
    required int index,
    required MediaItem mediaItem,
  }) {
    updateCurrentMediaItem(mediaItem);

    audioStateController.activePlayer.value?.seek(Duration.zero, index: index);

    audioStateController.activePlayer.value?.setAudioSource(
        audioStateController.playlist.value!,
        initialIndex: index);

    playMusic();

    setLastPlayingPlaylist();

    audioStateController.activePlayer.value?.play();
  }

  Future<void> getDominantColor(String url) async {
    // final PaletteGenerator paletteGenerator =
    //     await PaletteGenerator.fromImageProvider(
    //   // Penyesuaian ukuran gambar agar lebih cepat.
    //   CachedNetworkImageProvider(
    //     url,
    //     maxHeight: 8,
    //     maxWidth: 8,
    //     scale: 0.1,
    //   ),
    //   size: const Size(256.0, 170.0),
    //   region: const Rect.fromLTRB(41.8, 4.4, 217.8, 170.0),
    //   maximumColorCount: 20,
    // );

    // final Map<String, Color?> color = {
    //   'lightMutedColor': paletteGenerator.lightMutedColor?.color,
    //   'darkMutedColor': paletteGenerator.darkMutedColor?.color,
    //   'lightVibrantColor': paletteGenerator.lightVibrantColor?.color,
    //   'darkVibrantColor': paletteGenerator.darkVibrantColor?.color,
    //   'mutedColor': paletteGenerator.mutedColor?.color,
    //   'vibrantColor': paletteGenerator.vibrantColor?.color,
    // };

    // double numLuminance = 0;
    // Color fixColor = Colors.black;

    // for (final value in color.values) {
    //   if (value != null &&
    //       value.computeLuminance() +
    //               paletteGenerator.dominantColor!.color.computeLuminance() >
    //           numLuminance) {
    //     numLuminance = value.computeLuminance();
    //     fixColor = value;
    //   }
    // }

    // if (fixColor == paletteGenerator.dominantColor!.color) {
    //   fixColor = Colors.white;
    // }
    // final list = [paletteGenerator.dominantColor!.color, fixColor];
    // listColor.value = list;
  }

  double isDark(Color background) {
    return (background.computeLuminance());
  }
}
