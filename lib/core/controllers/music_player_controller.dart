import 'package:audio_service/audio_service.dart';
import 'package:cybeat_music_player/common/utils/colorize_terminal.dart';
import 'package:cybeat_music_player/controller/music_play/music_state_controller.dart';
import 'package:cybeat_music_player/core/controllers/audio_state_controller.dart';
import 'package:cybeat_music_player/core/models/playlist.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class MusicPlayerController extends GetxController {
  var currentActivePlaylist = Rx<Playlist?>(null);
  final _currentMediaItem = Rx<MediaItem?>(null);

  var isPlayingNow = false.obs;
  var isNeedRebuildLastPlaylist = false.obs;
  var isAzlistviewScreenActive = false.obs;

  var currentMusicDuration = Duration.zero.obs;
  var currentMusicPosition = Duration.zero.obs;

  MediaItem? get currentMediaItem => _currentMediaItem.value;

  @override
  void onInit() {
    super.onInit();
    final audioStateController = Get.find<AudioStateController>();
    // Subscribe ke stream dan perbarui durasi.
    audioStateController.player.value?.durationStream.listen((event) {
      updateCurrentMusicDuration(event);
    });

    // Subscribe ke stream dan perbarui posisi.
    audioStateController.player.value?.positionStream.listen((event) {
      updateCurrentMusicPosition(event);
    });
  }

  /*
  untuk kasus stream durasi dan posisi, tidak perlu pakai onclose,
  karena akan selalu ada perubahan durasi dan posisi,
  sehingga tidak perlu di-dispose.

  Akibatnya jika ada subscription dan di-close,
  maka progress bar tidak akan berjalan, karena stream sudah di-close.
  */

  void updateCurrentMusicDuration(Duration? duration) {
    // pakai this karena nama parameter sama dengan nama variabel
    currentMusicDuration.value = duration ?? Duration.zero;
  }

  void updateCurrentMusicPosition(Duration? position) {
    currentMusicPosition.value = position ?? Duration.zero;
  }

  void playMusic() {
    isPlayingNow.value = true;
  }

  void pauseMusic() {
    isPlayingNow.value = false;
  }

  void setCurrentMediaItem(MediaItem mediaItem) {
    _currentMediaItem.value = mediaItem;
  }

  void clearCurrentMediaItem() {
    _currentMediaItem.value = null;
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
      // Get.put(ProgressMusicController(player: audioState.player));
    } catch (e) {
      logError('Error setLastPlayingPlaylist: $e');
    }
  }

  void playMusicNow({
    required AudioStateController audioStateController,
    required int index,
  }) {
    final musicStateController = Get.find<MusicStateController>();

    audioStateController.player.value?.seek(Duration.zero, index: index);

    audioStateController.player.value?.setAudioSource(
        audioStateController.playlist.value!,
        initialIndex: index);

    playMusic();

    musicStateController.streamAudioPlayer(
      audioStateController.player.value!,
      _currentMediaItem.value!,
    );

    setCurrentMediaItem(_currentMediaItem.value!);

    setLastPlayingPlaylist();

    audioStateController.player.value?.play();
  }
}
