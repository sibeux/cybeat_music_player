import 'dart:async';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:cybeat_music_player/common/utils/colorize_terminal.dart';
import 'package:cybeat_music_player/common/utils/toast.dart';
import 'package:cybeat_music_player/core/controllers/audio_state_controller.dart';
import 'package:cybeat_music_player/core/models/album.dart';
import 'package:cybeat_music_player/core/models/music.dart';
import 'package:cybeat_music_player/core/networks/dio_client.dart';
import 'package:cybeat_music_player/core/services/album_service.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

class MusicPlayerController extends GetxController {
  var currentActivePlaylist = Rx<Album?>(null);
  var currentViewedAlbum = Rx<Album?>(null);
  var currentPlayingPlaylist = RxList<Music>([]);
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

  // --- CANCEL TOKENS ---
  CancelToken? _streamCancelToken;
  CancelToken? _prefetchCancelToken;

  // --- PRE-FETCH STATE ---
  String? _prefetchedTrackId;
  String? _prefetchedStreamUrl;
  int? _prefetchedCandidateIndex;
  bool _isPrefetching = false;
  bool _hasTriggeredPrefetchForCurrentTrack = false;

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
  Rx<MediaItem?> get rxCurrentMediaItem => _currentMediaItem;
  bool get isLastIndexMusic {
    final list = currentPlayingPlaylist.isNotEmpty
        ? currentPlayingPlaylist
        : Get.find<AudioStateController>().playlist;
    if (getCurrentMediaItem == null ||
        getCurrentMediaItem!.extras?['index'] == null) {
      return false;
    }
    return list.length ==
        int.parse(getCurrentMediaItem!.extras!['index']) - 1 + 1;
  }

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
      if (repeatMode.value == 'one') {
        player.setLoopMode(LoopMode.one);
      } else {
        player.setLoopMode(LoopMode.off);
      }

      durationStreamSubscription = player.durationStream.listen((duration) {
        updateCurrentMusicDuration(duration);
      });

      positionStreamSubscription = player.positionStream.listen((position) {
        updateCurrentMusicPosition(position);
        _checkAndTriggerDynamicPrefetch();
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

      playerErrorStreamSubscription = player.errorStream.listen((error) {
        logError(
          'Player Error code: ${error.code}. Error message: ${error.message}. AudioSource index: ${error.index}',
          error: error,
        );
      });
    }
  }

  void _cancelSubscriptions() {
    durationStreamSubscription?.cancel();
    positionStreamSubscription?.cancel();
    bufferedStreamSubscription?.cancel();
    sequenceStateStreamSubscription?.cancel();
    playerErrorStreamSubscription?.cancel();
  }

  @override
  void onClose() {
    _streamCancelToken?.cancel();
    _prefetchCancelToken?.cancel();
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
    final wasNotCompleted =
        currentMusicPlayerState.value != ProcessingState.completed;

    currentMusicPlayerState.value = processingState ?? ProcessingState.idle;
    isMusicPlayingNow.value = state!.playing;
    
    // Saat music telah selesai diputar, langsung beralih ke lagu berikutnya
    // agar Android tidak menganggap service idle dan membunuh proses background.
    if (processingState == ProcessingState.completed && wasNotCompleted) {
      seekNextButton(isFromButton: false);
    }
  }

  // ==========================================
  // DYNAMIC PRE-FETCH LOGIC
  // ==========================================
  void _resetPrefetchState() {
    _prefetchCancelToken?.cancel();
    _prefetchCancelToken = null;
    _prefetchedTrackId = null;
    _prefetchedStreamUrl = null;
    _prefetchedCandidateIndex = null;
    _isPrefetching = false;
    _hasTriggeredPrefetchForCurrentTrack = false;
  }

  Music? _getNextTrackCandidate() {
    final playlist = currentPlayingPlaylist.isNotEmpty
        ? currentPlayingPlaylist
        : Get.find<AudioStateController>().playlist;
    if (playlist.isEmpty || getCurrentMediaItem == null) return null;

    final rawIndex = getCurrentMediaItem!.extras?['index'];
    if (rawIndex == null) return null;

    int currentIdx = int.tryParse(rawIndex.toString()) ?? 1;
    int nextIndex = currentIdx; // 1-based index di extras

    if (isShuffleEnabled.value) {
      if (playlist.length <= 1) {
        _prefetchedCandidateIndex = 0;
        return playlist[0];
      }
      final currentZeroIndex = currentIdx - 1;
      final random = Random();
      int randomCandidate =
          (currentZeroIndex + 1 + random.nextInt(playlist.length - 1)) %
              playlist.length;
      _prefetchedCandidateIndex = randomCandidate;
      return playlist[randomCandidate];
    }

    if (nextIndex >= playlist.length) {
      if (repeatMode.value == 'all') {
        nextIndex = 0;
      } else {
        return null;
      }
    }

    _prefetchedCandidateIndex = nextIndex;
    return playlist[nextIndex];
  }

  void _checkAndTriggerDynamicPrefetch() {
    if (_hasTriggeredPrefetchForCurrentTrack || _isPrefetching) return;
    if (repeatMode.value == 'one') return;

    final duration = currentMusicDuration.value;
    final position = currentMusicPosition.value;

    if (duration == Duration.zero) return;

    bool shouldTrigger = false;

    if (duration.inSeconds <= 10) {
      // Lagu sangat pendek (<= 10 detik): trigger segera setelah 500ms pemutaran
      if (position.inMilliseconds >= 500) {
        shouldTrigger = true;
      }
    } else if (duration.inSeconds <= 30) {
      // Lagu pendek (10-30 detik): trigger di detik ke-1
      if (position.inSeconds >= 1) {
        shouldTrigger = true;
      }
    } else {
      // Lagu normal / panjang (> 30 detik): trigger saat sisa durasi <= 30 detik
      final remaining = duration - position;
      if (remaining.inSeconds <= 30 && remaining.inSeconds > 0) {
        shouldTrigger = true;
      }
    }

    if (shouldTrigger) {
      _hasTriggeredPrefetchForCurrentTrack = true;
      _executePrefetchNextTrack();
    }
  }

  Future<void> _executePrefetchNextTrack() async {
    final nextTrack = _getNextTrackCandidate();
    if (nextTrack == null) return;

    final trackId = nextTrack.musicId.toString();
    final url = nextTrack.extras?.musicUrl;
    if (url == null || url.isEmpty) return;

    _isPrefetching = true;
    _prefetchCancelToken?.cancel();
    _prefetchCancelToken = CancelToken();

    try {
      logInfo('⚡ [Pre-fetch] Memulai pre-fetch presigned URL untuk: ${nextTrack.title} ($trackId)');
      final response = await dio.get(
        url,
        queryParameters: {'music_id': trackId},
        cancelToken: _prefetchCancelToken,
      );

      final String? streamUrl = response.data?['stream_url'];
      if (streamUrl != null && streamUrl.isNotEmpty) {
        _prefetchedTrackId = trackId;
        _prefetchedStreamUrl = streamUrl;
        logSuccess('⚡ [Pre-fetch] Berhasil pre-fetch presigned URL untuk: $trackId');
      }
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.cancel) {
        return;
      }
      logWarning('⚠️ [Pre-fetch] Gagal pre-fetch $trackId: $e');
    } finally {
      _isPrefetching = false;
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

  Future<void> playMusicNow({
    required AudioStateController audioStateController,
    required MediaItem mediaItem,
    bool isFromButton = true,
  }) async {
    if (isFromButton) {
      logInfo('User pressed PLAY: ${mediaItem.title}');
    }

    // Update UI state terlebih dahulu agar title/artist/cover langsung tampil.
    updateCurrentMediaItem(mediaItem);
    currentMusicPosition.value = Duration.zero;
    currentMusicBuffer.value = Duration.zero;
    currentMusicDuration.value = mediaItem.duration ?? Duration.zero;
    audioStateController.checkCodecAudio(mediaItem: mediaItem);
    audioStateController.checkDominantColor(mediaItem: mediaItem);
    audioStateController.audioHandler?.mediaItem.add(mediaItem);

    final player = audioStateController.activePlayer.value;
    if (player == null) return;

    // Hentikan pemutaran audio lama seketika agar suara tidak terus berlanjut
    // saat menunggu fetch stream_url / buffering audio baru.
    player.stop();

    activateMusic();

    if (currentActivePlaylist.value?.type != 'offline') {
      isNeedRebuildLastPlaylist.value = true;
    }

    if (isFromButton) {
      numberOfError = 0; // Hanya reset jika user berinteraksi manual (klik lagu / next manual)
    }

    // Batalkan request lagu sebelumnya dan ambil requestId sebelum await apapun,
    // agar guard requestId aktif selama seluruh async flow.
    _streamCancelToken?.cancel();
    _streamCancelToken = CancelToken();
    final int requestId = ++_playRequestId;

    // Cek ketersediaan URL dari Pre-fetch Cache
    String? streamUrl;
    if (_prefetchedTrackId == mediaItem.id && _prefetchedStreamUrl != null) {
      streamUrl = _prefetchedStreamUrl;
      logSuccess('⚡ [Cache Hit] Memutar langsung dari presigned pre-fetch URL: ${mediaItem.id}');
    }

    // Reset pre-fetch state untuk lagu yang baru aktif
    _resetPrefetchState();

    try {
      if (streamUrl == null) {
        isWaitingGetMusicStreamUrl.value = true;
        logInfo('⏳ [On-demand Fetch] Mengambil presigned URL untuk: ${mediaItem.id}');

        final response = await dio.get(
          mediaItem.extras!['url'],
          queryParameters: {
            'music_id': mediaItem.id,
          },
          cancelToken: _streamCancelToken,
        );

        // Kalau ada request yang lebih baru, abaikan hasil ini
        if (requestId != _playRequestId) return;

        streamUrl = response.data['stream_url'];
      }

      // Kalau ada request yang lebih baru, abaikan hasil ini
      if (requestId != _playRequestId) return;

      logSuccess(
          'Streaming ${mediaItem.id} -> ${Uri.parse(streamUrl!).path} (exp=${Uri.parse(streamUrl).queryParameters['expires']})');

      const int maxPlayerRetries = 3;
      int playerRetryCount = 0;
      bool isAudioLoaded = false;

      while (!isAudioLoaded && playerRetryCount < maxPlayerRetries) {
        if (requestId != _playRequestId) return;

        try {
          playerRetryCount++;
          await player.setAudioSources(
            [
              AudioSource.uri(
                Uri.parse(streamUrl),
                tag: mediaItem,
              ),
            ],
            initialIndex: 0,
          );
          isAudioLoaded = true;
        } catch (playerErr, playerSt) {
          logWarning(
            'Gagal memuat audio source ($playerRetryCount/$maxPlayerRetries): $playerErr -> $streamUrl',
          );

          if (playerRetryCount >= maxPlayerRetries) {
            logError(
              'Gagal setAudioSources setelah $maxPlayerRetries percobaan: $playerErr',
              error: playerErr,
              stack: playerSt,
            );
            rethrow;
          }

          // Backoff: 1s, 2s sebelum mencoba lagi
          await Future.delayed(Duration(milliseconds: 1000 * playerRetryCount));
        }
      }

      // Double check lagi setelah proses async
      if (requestId != _playRequestId) return;

      numberOfError = 0; // Reset counter saat pemutaran berhasil
      isWaitingGetMusicStreamUrl.value = false;

      // Gunakan audioHandler.play() agar AudioService memulai foreground service notification.
      // Jika handler belum siap (null pada cold-start sangat cepat), fallback ke player.play().
      final handler = audioStateController.audioHandler;
      if (handler != null) {
        await handler.play();
      } else {
        await player.play();
      }
    } catch (e, st) {
      if (requestId == _playRequestId) {
        isWaitingGetMusicStreamUrl.value = false;
      }

      // Kalau request sudah obsolete, tidak perlu dianggap error
      if (requestId != _playRequestId) return;

      if (e is DioException && e.type == DioExceptionType.cancel) {
        // Request dibatalkan (misal user ganti lagu lain sebelum selesai)
        return;
      }

      numberOfError++;
      logError("Gagal memutar lagu (${mediaItem.title}): $e", error: e, stack: st);

      const int maxConsecutiveErrors = 3;
      if (numberOfError < maxConsecutiveErrors) {
        logWarning(
            "Lagu gagal setelah 3x retry. Beralih ke lagu berikutnya (Lagu gagal berurutan: $numberOfError/$maxConsecutiveErrors)...");
        showToast("Lagu bermasalah, memutar lagu berikutnya...");
        await Future.delayed(const Duration(milliseconds: 1000));
        if (requestId == _playRequestId) {
          seekNextButton(isFromButton: false);
        }
      } else {
        logError(
            "Sudah $maxConsecutiveErrors lagu berturut-turut gagal. Koneksi internet/server terputus. Menghentikan player.");
        showToast("Gagal memutar $maxConsecutiveErrors lagu berturut-turut. Periksa koneksi internet Anda.");
        numberOfError = 0; // Reset agar pemutaran manual berikutnya bisa dicoba lagi
      }
    }
  }

  void setPlayingPlaylist(List<Music> list) {
    currentPlayingPlaylist.assignAll(list);
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
    final audioStateController = Get.find<AudioStateController>();
    final bool isPlayingAlbum = currentActivePlaylist.value?.uid == album.uid &&
        currentActivePlaylist.value?.type == album.type &&
        currentPlayingPlaylist.isNotEmpty;
    final bool isAlreadyLoadedViewedAlbum =
        currentViewedAlbum.value?.uid == album.uid &&
            currentViewedAlbum.value?.type == album.type &&
            audioStateController.playlist.isNotEmpty;

    currentViewedAlbum.value = album;
    getDominantColorAlbum(album: album);

    if (isPlayingAlbum) {
      // Jika album yang dibuka sedang aktif diputar, gunakan list yang sudah ada di memory
      audioStateController.playlist.assignAll(currentPlayingPlaylist);
      audioStateController.isAlbumEmpty.value = currentPlayingPlaylist.isEmpty;
      audioStateController.initAlbumLoading.value = false;
    } else if (isAlreadyLoadedViewedAlbum) {
      // Jika album sama persis dengan yang terakhir dilihat dan datanya sudah ada di memory
      audioStateController.isAlbumEmpty.value =
          audioStateController.playlist.isEmpty;
      audioStateController.initAlbumLoading.value = false;
    } else {
      // Hanya fetch dari API jika membuka album baru yang belum ada di memory
      audioStateController.init(album);
    }

    Get.toNamed(
      '/album_music',
      id: 1,
    );
  }

  void seekNextButton(
      {bool isFromButton = true, bool isFromShuffleButton = false}) {
    // Guard: jika bukan dari shuffle button, getCurrentMediaItem harus ada
    // karena dipakai untuk menentukan posisi lagu berikutnya.
    // isFromShuffleButton tidak butuh currentMediaItem (langsung mulai dari index acak).
    if (!isFromShuffleButton && getCurrentMediaItem == null) return;
    int originalCurrentSongSequence = isFromShuffleButton
        ? 0
        : int.parse(getCurrentMediaItem!.extras!['index']) - 1;
    final playlist = currentPlayingPlaylist.isNotEmpty
        ? currentPlayingPlaylist
        : Get.find<AudioStateController>().playlist;
    final playlistLength = playlist.length;
    if (playlistLength == 0) return;
    final random = Random();

    int index;
    if (isShuffleEnabled.value || isFromShuffleButton) {
      // Jika kita punya hasil pre-fetch yang valid untuk mode shuffle, gunakan index pre-fetch tersebut!
      if (!isFromShuffleButton &&
          _prefetchedCandidateIndex != null &&
          _prefetchedTrackId != null &&
          _prefetchedCandidateIndex! < playlistLength &&
          playlist[_prefetchedCandidateIndex!].musicId.toString() ==
              _prefetchedTrackId) {
        index = _prefetchedCandidateIndex!;
      } else {
        index = playlistLength > 1
            ? (originalCurrentSongSequence +
                    1 +
                    random.nextInt(playlistLength - 1)) %
                playlistLength
            : 0;
      }
    } else {
      originalCurrentSongSequence += 1;
      index = originalCurrentSongSequence;
      if (playlistLength < originalCurrentSongSequence + 1) {
        if (repeatMode.value == 'all') {
          originalCurrentSongSequence = 0;
          index = 0;
        }
      }
    }

    if (!(!isShuffleEnabled.value &&
        playlistLength < originalCurrentSongSequence + 1)) {
      final music = playlist[index];
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
    if (getCurrentMediaItem == null) return;
    int currentIndex = int.parse(getCurrentMediaItem!.extras!['index']) - 1;
    final playlist = currentPlayingPlaylist.isNotEmpty
        ? currentPlayingPlaylist
        : Get.find<AudioStateController>().playlist;
    if (1 != currentIndex + 1 && playlist.isNotEmpty && currentIndex > 0) {
      currentIndex -= 1;
      final music = playlist[currentIndex];
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
    _resetPrefetchState();
    if (isShuffleEnabled.value) {
      showToast('Shuffle enabled');
    } else {
      showToast('Shuffle disabled');
    }
  }

  void toggleRepeatButton(String repeat) {
    repeatMode.value = repeat;
    _resetPrefetchState();
    final player = Get.find<AudioStateController>().activePlayer.value;
    if (player != null) {
      if (repeat == 'one') {
        player.setLoopMode(LoopMode.one);
      } else {
        player.setLoopMode(LoopMode.off);
      }
    }
  }
}
