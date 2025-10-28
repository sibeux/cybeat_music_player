import 'dart:async';
import 'dart:convert';
import 'dart:math';

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

  var isMusicActiveNow = false.obs;
  var isMusicPlayingNow = false.obs;
  var isNeedRebuildLastPlaylist = false.obs;
  var isAzlistviewScreenActive = false.obs;
  var isWaitingGetMusicStreamUrl = false.obs;
  var isShuffleEnabled = false.obs;
  var isRepeatEnabled = 'off'.obs; // off, all, one

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
        if (numberOfError >= 5) {
          logError('Too many errors, skipping playback.');
          seekNextButton();
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
    // Saat music telah selesai diputar, tunggu 0.5 detik dan ganti lagu berikutnya.
    if (state.processingState == ProcessingState.completed) {
      await Future.delayed(Duration(milliseconds: 500));
      seekNextButton(isFromButton: false);
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

  Future<Map<String, dynamic>> getStreamDirectUrl({required String url}) async {
    isWaitingGetMusicStreamUrl.value = true;
    const methodName = "getStreamDirectUrl";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.body.isEmpty) {
        final reason =
            'Error in $methodName: Response body is empty: ${response.statusCode}';
        logError(reason);
        return {};
      }
      final responseBody = json.decode(response.body);
      if (responseBody['success'] == true) {
        logSuccess('$methodName success: $responseBody');
        return responseBody;
      } else {
        final e = 'Error in $methodName: $responseBody';
        logError(e);
        return {};
      }
    } catch (e, st) {
      logError('Error in $methodName: $e stacktrace: $st');
      return {};
    } finally {
      isWaitingGetMusicStreamUrl.value = false;
    }
  }

  void playMusicNow({
    required AudioStateController audioStateController,
    required MediaItem mediaItem,
    bool isFromButton = true,
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
    // reset number of error saat ganti lagu.
    numberOfError = 0;

    final String initialUrl = mediaItem.extras!['url'];
    final bool isApiStream = initialUrl
        .contains('https://sibeux.my.id/cloud-music-player/api/stream');

    try {
      if (isFromButton) {
        // player.stop();
        // player.seek(Duration.zero, index: 0);
      }
      final url = isApiStream
          // ? (await getStreamDirectUrl(url: initialUrl))['stream_url'] ?? ''
          ? initialUrl
          : initialUrl;
      await player.setAudioSources(
        [
          AudioSource.uri(
            Uri.parse(url),
            tag: mediaItem,
          ),
          // AudioSource.uri(
          //   Uri.parse(url),
          //   tag: mediaItem,
          // ),
        ],
        initialIndex: 0,
      );

      player.play(); // user langsung dengar musik
    } catch (e, st) {
      // Tambahkan penanganan error jika proses load playlist gagal
      logError("Error playMusicNow: $e. ST: $st");
    }
  }

  void seekNextButton(
      {bool isFromButton = true, bool isFromShuffleButton = false}) {
    int originalCurrentIndexSong = isFromShuffleButton
        ? 0
        : int.parse(getCurrentMediaItem!.extras!['index']) - 1;
    final playlistLength = Get.find<AudioStateController>().playlist.length;
    final random = Random();
    if (!isShuffleEnabled.value) {
      originalCurrentIndexSong += 1;
    }
    int index = isShuffleEnabled.value || isFromShuffleButton
        ? random.nextInt(
            playlistLength) // 0 sampai 1000 (inklusif 0, eksklusif 1001)
        : originalCurrentIndexSong;

    if (!(!isShuffleEnabled.value &&
        playlistLength < originalCurrentIndexSong + 1)) {
      final music = Get.find<AudioStateController>().playlist[index];
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
        mediaItem: mediaItem,
        isFromButton: isFromButton,
      );
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
        mediaItem: mediaItem,
        isFromButton: true,
      );
    }
  }

  void toggleShuffleButton() {
    isShuffleEnabled.value = !isShuffleEnabled.value;
    if (isShuffleEnabled.value) {
      showToast('Shuffle enabled');
    } else {
      showToast('Shuffle disabled');
    }
  }

  void toggleRepeatButton(String repeat) {
    isRepeatEnabled.value = repeat;
  }
}
