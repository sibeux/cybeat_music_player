import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:cybeat_music_player/common/utils/colorize_terminal.dart';
import 'package:cybeat_music_player/common/utils/toast.dart';
import 'package:cybeat_music_player/common/utils/url_formatter.dart';
import 'package:cybeat_music_player/core/controllers/audio_state_controller.dart';
import 'package:cybeat_music_player/core/models/album.dart';
import 'package:cybeat_music_player/core/networks/dio_client.dart';
import 'package:cybeat_music_player/core/services/album_service.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';

class MusicPlayerController extends GetxController {
  var currentActivePlaylist = Rx<Album?>(null);
  final _currentMediaItem = Rx<MediaItem?>(null);

  final dio = DioClient().dio;

  var isMusicActiveNow = false.obs;
  var isMusicPlayingNow = false.obs;
  var isNeedRebuildLastPlaylist = false.obs;
  var isAzlistviewScreenActive = false.obs;
  var isWaitingGetMusicStreamUrl = false.obs;
  var isShuffleEnabled = false.obs;

  var repeatMode = 'off'.obs; // off, all, one

  var numberOfError = 0;
  int currentIndexShuffle = 0;
  int _playRequestId = 0;
  CancelToken? _streamCancelToken;

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
  StreamSubscription<LoopMode>? loopModeStreamSubscription;

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

    // FIX: Race condition guard.
    // _initAudioService() di AudioStateController bersifat async fire & forget.
    // Jika ia selesai SEBELUM onReady() dipanggil, activePlayer sudah punya value
    // tapi ever() belum terdaftar → ever tidak pernah menangkap perubahan awal itu.
    // Solusi: panggil _listenToPlayerStreams secara manual jika player sudah ada.
    if (audioStateController.activePlayer.value != null) {
      _listenToPlayerStreams(audioStateController.activePlayer.value);
    }
  }

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
        // PERBAIKAN: Listener ini awalnya mengupdate _currentMediaItem dari source lama
        // saat player.stop() dipanggil, yang membuat metadata UI kembali ke lagu lama 
        // selama menunggu API. Karena Cybeat mengatur antrean lagu secara manual 
        // (1 lagu per setAudioSources) dan memanggil updateCurrentMediaItem secara manual 
        // di playMusicNow, kita tidak perlu mengupdate UI dari sequenceStateStream.
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

      loopModeStreamSubscription = player.loopModeStream.listen((loopMode) {
        if (loopMode == LoopMode.off) {
          repeatMode.value = 'off';
        } else if (loopMode == LoopMode.all) {
          repeatMode.value = 'all';
        } else if (loopMode == LoopMode.one) {
          repeatMode.value = 'one';
        }
      });
    }
  }

  void _cancelSubscriptions() {
    durationStreamSubscription?.cancel();
    positionStreamSubscription?.cancel();
    bufferedStreamSubscription?.cancel();
    sequenceStateStreamSubscription?.cancel();
    playerErrorStreamSubscription?.cancel();
    loopModeStreamSubscription?.cancel();
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

  void setActivePlaylist(Album playlist) {
    // Setiap album/playlist yang di-play akan disimpan di currentPlaylistPlay.
    // Isinya hanya 1, yaitu album/playlist yang sedang di-play.
    currentActivePlaylist.value = playlist;
  }

  Future<void> setLastPlayingPlaylist() async {
    // String endpoint = dotenv.env['PLAYLIST_API_URL'] ?? '';
    // String api = '$endpoint?play_playlist=${currentActivePlaylist.value?.uid}';
    try {
      // await http.post(
      //   Uri.parse(api),
      // );
      isNeedRebuildLastPlaylist.value = true;
    } catch (e) {
      logError('Error setLastPlayingPlaylist: $e');
    }
  }

  Future<void> playMusicNow({
    required AudioStateController audioStateController,
    required MediaItem mediaItem,
    bool isFromButton = true,
  }) async {
    updateCurrentMediaItem(mediaItem);

    final player = audioStateController.activePlayer.value;
    if (player == null) return;

    activateMusic();

    if (currentActivePlaylist.value?.type != 'offline') {
      setLastPlayingPlaylist();
    }

    numberOfError = 0;

    _streamCancelToken?.cancel();

    _streamCancelToken = CancelToken();

    final int requestId = ++_playRequestId;

    try {
      isWaitingGetMusicStreamUrl.value = true;

      // Segera stop dan reset progress bar ke 0 agar UI tidak terlihat delay/stuck
      // saat menunggu response API.
      await player.stop();
      await player.setAudioSources([]);
      await player.seek(Duration.zero);

      final response = await dio.get(
        mediaItem.extras!['url'],
        queryParameters: {
          'music_id': mediaItem.id,
        },
        cancelToken: _streamCancelToken,
      );

      // Kalau ada request yang lebih baru, abaikan hasil ini
      if (requestId != _playRequestId) return;

      final String streamUrl = response.data['stream_url'];

      await player.setAudioSources(
        [
          AudioSource.uri(
            Uri.parse(streamUrl),
            tag: mediaItem,
          ),
        ],
        initialIndex: 0,
      );

      // Double check lagi setelah proses async
      if (requestId != _playRequestId) return;

      isWaitingGetMusicStreamUrl.value = false;

      await player.play();
    } catch (e, st) {
      if (requestId == _playRequestId) {
        isWaitingGetMusicStreamUrl.value = false;
      }

      // Kalau request sudah obsolete, tidak perlu dianggap error
      if (requestId != _playRequestId) return;

      logError("Error playMusicNow: $e\n$st");
    }
  }

  void getDominantColorAlbum({required Album album}) {
    String albumCover = '';
    if (album.image['default_cover'] != null) {
      albumCover = album.image['default_cover'].toString();
    } else {
      albumCover = album.image['cover_1'].toString();
    }
    final AlbumService albumService = Get.find<AlbumService>();
    if (albumCover != '' && album.bgColor == 'ffffff') {
      albumService.getDominantColorAlbum(
          albumCover: albumCover, albumId: album.uid);
    } else {
      albumService.setDominantColorAlbum(color: album.bgColor);
    }
  }

  void openAlbum({required Album album}) {
    final String albumId = currentActivePlaylist.value?.uid ?? "";
    final String albumType = currentActivePlaylist.value?.type ?? "";
    final audioStateController = Get.find<AudioStateController>();
    // 1 - album
    // 1 - playlist
    if ((albumId != album.uid) || (albumType != album.type)) {
      getDominantColorAlbum(album: album);
      audioStateController.clear();
      killMusic();
      clearCurrentMediaItem();
      audioStateController.init(album);
      setActivePlaylist(album);
    }
    Get.toNamed(
      '/album_music',
      id: 1,
    );
  }

  void seekNextButton(
      {bool isFromButton = true, bool isFromShuffleButton = false}) {
    int originalCurrentSongSequence = isFromShuffleButton
        ? 0
        : int.parse(getCurrentMediaItem!.extras!['index']) - 1;
    final playlistLength = Get.find<AudioStateController>().playlist.length;
    final random = Random();

    // if (isRepeatEnabled.value == 'one') {
    //   int index = originalCurrentIndexSong;
    //   final music = Get.find<AudioStateController>().playlist[index];
    //   final mediaItem = MediaItem(
    //     id: music.musicId.toString(),
    //     title: music.title,
    //     album: music.album,
    //     artUri: Uri.parse(music.cover),
    //     artist: music.artist,
    //     extras: music.extras?.toMap() ?? {},
    //   );
    //   playMusicNow(
    //     audioStateController: Get.find<AudioStateController>(),
    //     mediaItem: mediaItem,
    //     isFromButton: isFromButton,
    //   );
    //   return;
    // }

    if (!isShuffleEnabled.value) {
      originalCurrentSongSequence += 1;
    }
    int index = isShuffleEnabled.value || isFromShuffleButton
        ? random.nextInt(
            playlistLength) // 0 sampai 1000 (inklusif 0, eksklusif 1001)
        : originalCurrentSongSequence;

    if (!isShuffleEnabled.value &&
        playlistLength < originalCurrentSongSequence + 1) {
      if (repeatMode.value == 'all') {
        originalCurrentSongSequence = 0;
        index = 0;
      }
    }

    if (!(!isShuffleEnabled.value &&
        playlistLength < originalCurrentSongSequence + 1)) {
      final music = Get.find<AudioStateController>().playlist[index];
      final mediaItem = MediaItem(
        id: music.musicId.toString(),
        title: music.title,
        album: music.album,
        artUri: Uri.parse(music.cover),
        artist: music.artist,
        extras: music.extras?.toMap() ?? {},
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
        id: music.musicId.toString(),
        title: music.title,
        album: music.album,
        artUri: Uri.parse(music.cover),
        artist: music.artist,
        extras: music.extras?.toMap() ?? {},
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
    repeatMode.value = repeat;
  }
}
