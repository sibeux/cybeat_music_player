import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:cybeat_music_player/common/utils/colorize_terminal.dart';
import 'package:cybeat_music_player/common/utils/toast.dart';
import 'package:cybeat_music_player/core/controllers/audio_state_controller.dart';
import 'package:cybeat_music_player/core/models/playlist.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';

class MusicPlayerController extends GetxController {
  var currentActivePlaylist = Rx<Playlist?>(null);
  final _currentMediaItem = Rx<MediaItem?>(null);
  List<int> shuffledIndices = [];

  var isMusicActiveNow = false.obs;
  var isMusicPlayingNow = false.obs;
  var isNeedRebuildLastPlaylist = false.obs;
  var isAzlistviewScreenActive = false.obs;
  var isShuffleEnabled = false.obs;
  var isRepeatEnabled = false.obs;

  var numberOfError = 0;
  int currentIndexShuffle = 0;

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
  bool get isLastIndexMusic =>
      Get.find<AudioStateController>().playlist.length ==
      int.parse(getCurrentMediaItem!.extras!['index']) - 1 + 1;

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
        if (error.index != null) {
          numberOfError += 1;
          logInfo('Trying to reload the audio source...');
          await player.pause();
          await Future.delayed(const Duration(milliseconds: 500));
          await player.play();
        }
        if (numberOfError >= 10) {
          logError('Too many errors, skipping playback.');
          await player.seekToNext();
          numberOfError = 0;
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
    if (state.processingState == ProcessingState.completed) {
      seekNextButton();
    }
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
    required MediaItem mediaItem,
  }) async {
    // Gunakan variabel lokal untuk menghindari pengulangan dan null check
    final player = audioStateController.activePlayer.value;
    if (player == null) return; // Guard clause jika player tidak ada

    updateCurrentMediaItem(
        mediaItem); // Ini dipakai saat pertama kali putar music.
    activateMusic();

    if (currentActivePlaylist.value!.type != 'offline') {
      setLastPlayingPlaylist();
    }

    try {
      // setAudioSources adalah operasi utama dan harus ditunggu (await)
      // Tidak perlu seek() sebelumnya karena initialIndex sudah menanganinya.
      // player.seek(Duration.zero, index:index);
      // {kode "APEL"}
      await player.setAudioSource(
        AudioSource.uri(
          Uri.parse(mediaItem.extras!['url']),
          tag: mediaItem,
        ),
        initialIndex: 0,
      );

      // Panggil play() setelah playlist berhasil di-load.
      player.play();
    } catch (e, st) {
      // Tambahkan penanganan error jika proses load playlist gagal
      logError("Error playMusicNow: $e. ST: $st");
    }
  }

  void seekNextButton() {
    int originalCurrentIndexSong =
        int.parse(getCurrentMediaItem!.extras!['index']) - 1;
    if (isShuffleEnabled.value) {
      currentIndexShuffle += 1;
    } else {
      originalCurrentIndexSong += 1;
    }

    int seekToIndex = isShuffleEnabled.value
        ? shuffledIndices[currentIndexShuffle]
        : originalCurrentIndexSong;

    if (Get.find<AudioStateController>().playlist.length > seekToIndex + 1) {
      final music = Get.find<AudioStateController>().playlist[seekToIndex];
      final mediaItem = MediaItem(
        id: music.musicId,
        title: music.title,
        album: music.album,
        artUri: Uri.parse(music.cover),
        artist: music.artist,
        extras: music.extras,
      );
      playMusicNow(
          audioStateController: Get.find<AudioStateController>(),
          mediaItem: mediaItem);
    }
  }

  void seekPreviousButton() {
    int currentIndex = int.parse(getCurrentMediaItem!.extras!['index']) - 1;
    if (1 != currentIndex + 1) {
      currentIndex -= 1;
      final music = Get.find<AudioStateController>().playlist[currentIndex];
      final mediaItem = MediaItem(
        id: music.musicId,
        title: music.title,
        album: music.album,
        artUri: Uri.parse(music.cover),
        artist: music.artist,
        extras: music.extras,
      );
      playMusicNow(
          audioStateController: Get.find<AudioStateController>(),
          mediaItem: mediaItem);
    }
  }

  void toggleShuffleButton() {
    isShuffleEnabled.value = !isShuffleEnabled.value;
    if (isShuffleEnabled.value) {
      showToast('Shuffle enabled');
      shuffledIndices = List.generate(
          Get.find<AudioStateController>().playlist.length, (i) => i);

      // Buat lagu saat ini tetap di awal
      int currentSongIndex =
          int.parse(getCurrentMediaItem!.extras!['index']) - 1;
      shuffledIndices.remove(currentSongIndex);
      shuffledIndices.shuffle();
      shuffledIndices.insert(0, currentSongIndex);

      currentIndexShuffle = 0;
    } else {
      showToast('Shuffle disabled');
    }
  }

  void toggleRepeatButton() {
    isRepeatEnabled.value = !isRepeatEnabled.value;
  }
}
