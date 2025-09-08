import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:cybeat_music_player/common/utils/colorize_terminal.dart';
import 'package:cybeat_music_player/core/controllers/audio_state_controller.dart';
import 'package:cybeat_music_player/core/models/playlist.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';

class MusicPlayerController extends GetxController {
  var currentActivePlaylist = Rx<Playlist?>(null);
  final _currentMediaItem = Rx<MediaItem?>(null);

  var isMusicActiveNow = false.obs;
  var isMusicPlayingNow = false.obs;
  var isNeedRebuildLastPlaylist = false.obs;
  var isAzlistviewScreenActive = false.obs;

  var currentMusicDuration = Duration.zero.obs;
  var currentMusicPosition = Duration.zero.obs;
  var currentMusicBuffer = Duration.zero.obs;
  var currentMusicPlayerState = ProcessingState.idle.obs;

  StreamSubscription<Duration?>? durationStreamSubscription;
  StreamSubscription<Duration?>? positionStreamSubscription;
  StreamSubscription<Duration?>? bufferedStreamSubscription;
  StreamSubscription<SequenceState?>? sequenceStateStreamSubscription;
  StreamSubscription<PlayerState?>? playerStateStreamSubscription;
  StreamSubscription<PlayerException?>? playerErrorStreamSubscription;

  MediaItem? get getCurrentMediaItem => _currentMediaItem.value;

  // Dipakai di floating widget.
  double get sliderValue {
    return (currentMusicPosition.value.inMilliseconds > 0 &&
            currentMusicPosition.value.inMilliseconds <
                currentMusicDuration.value.inMilliseconds)
        ? currentMusicPosition.value.inMilliseconds /
            currentMusicDuration.value.inMilliseconds
        : 0.0;
  }

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

      bufferedStreamSubscription =
          player.bufferedPositionStream.listen((buffer) {
        updateCurrentMusicBuffer(buffer);
      });

      playerStateStreamSubscription = player.playerStateStream.listen((state) {
        updateCurrentMusicPlayerState(state, player);
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
        }
      });

      playerErrorStreamSubscription = player.errorStream.listen((error) async {
        logError(
            'Player Error code: ${error.code}. Error message: ${error.message}. AudioSource index: ${error.index}');
        if (error.index != null && error.message == "Source error") {
          await player.pause();
          await Future.delayed(const Duration(milliseconds: 500));
          await player.play();
        }
      });
    }
  }

  // Fungsi helper untuk membatalkan semua subscription
  void _cancelSubscriptions() {
    durationStreamSubscription?.cancel();
    positionStreamSubscription?.cancel();
    bufferedStreamSubscription?.cancel();
    sequenceStateStreamSubscription?.cancel();
    playerErrorStreamSubscription?.cancel();
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
    currentMusicDuration.value = duration ?? Duration.zero;
  }

  void updateCurrentMusicPosition(Duration? position) {
    currentMusicPosition.value = position ?? Duration.zero;
  }

  void updateCurrentMusicBuffer(Duration? buffer) {
    currentMusicBuffer.value = buffer ?? Duration.zero;
  }

  Future<void> updateCurrentMusicPlayerState(
      PlayerState? state, AudioPlayer player) async {
    final processingState = state?.processingState;
    currentMusicPlayerState.value = processingState ?? ProcessingState.idle;
    isMusicPlayingNow.value = state!.playing;
  }

  void updateCurrentMediaItem(MediaItem mediaItem) {
    _currentMediaItem.value = mediaItem;
  }

  void clearCurrentMediaItem() {
    _currentMediaItem.value = null;
  }

  void activateMusic() {
    isMusicActiveNow.value = true;
  }

  void killMusic() {
    isMusicActiveNow.value = false;
  }

  void setActivePlaylist(Playlist playlist) {
    // Setiap album/playlist yang di-play akan disimpan di currentPlaylistPlay.
    // Isinya hanya 1, yaitu album/playlist yang sedang di-play.
    currentActivePlaylist.value = playlist;
  }

  Future<void> setLastPlayingPlaylist() async {
    String endpoint = dotenv.env['PLAYLIST_API_URL'] ?? '';
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

    // {kode "APEL"}
    audioStateController.activePlayer.value?.setAudioSources(
      audioStateController.playlist,
      initialIndex: index,
    );

    activateMusic();

    if (currentActivePlaylist.value!.type != 'offline') {
      setLastPlayingPlaylist();
    }

    audioStateController.activePlayer.value?.play();
  }
}
