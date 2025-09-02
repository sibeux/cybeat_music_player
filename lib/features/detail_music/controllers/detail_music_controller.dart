import 'package:audio_service/audio_service.dart';
import 'package:cybeat_music_player/core/controllers/audio_state_controller.dart';
import 'package:cybeat_music_player/core/controllers/music_player_controller.dart';
import 'package:cybeat_music_player/core/models/playlist.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:cybeat_music_player/common/utils/colorize_terminal.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';

class DetailMusicController extends GetxController {
  final MusicPlayerController musicPlayerController = Get.find();
  final AudioStateController audioStateController = Get.find();

  // --- TAMBAHKAN STATE BARU ---
  var isSeeking = false.obs;
  var dragValue = Duration.zero.obs;
  // ---------------------------

  // --- TAMBAHKAN LOGIKA UNTUK NILAI SLIDER ---
  // Khusus dipakai di detail music, karena ada seeking.
  double get sliderValue {
    final tempValue = (isSeeking.value ? dragValue.value : position);
    return (tempValue.inMilliseconds > 0 &&
            duration.inMilliseconds > 0 &&
            tempValue.inMilliseconds < duration.inMilliseconds)
        ? tempValue.inMilliseconds / duration.inMilliseconds
        : 0.0;
  }

  double get secondarySliderValue {
    return (buffered.inMilliseconds > 0 &&
            buffered.inMilliseconds < duration.inMilliseconds)
        ? buffered.inMilliseconds / duration.inMilliseconds
        : 0.0;
  }
  // ------------------------------------------

  AudioPlayer? get player => audioStateController.activePlayer.value;
  bool get isMusicPlayingNow => musicPlayerController.isMusicPlayingNow.value;

  Duration get duration => musicPlayerController.currentMusicDuration.value;
  Duration get position => musicPlayerController.currentMusicPosition.value;
  Duration get buffered => musicPlayerController.currentMusicBuffer.value;
  ProcessingState get playerState =>
      musicPlayerController.currentMusicPlayerState.value;

  String get durationText => formatDuration(duration);
  String get positionText =>
      formatDuration(isSeeking.value ? dragValue.value : position);

  MediaItem? get currentMediaItem => musicPlayerController.getCurrentMediaItem;
  Playlist? get currentActivePlaylist =>
      musicPlayerController.currentActivePlaylist.value;
  bool get isAlbumMusicScreenActive =>
      musicPlayerController.isAzlistviewScreenActive.value;

  // Codec
  String get sampleRate => audioStateController.sampleRate.value;
  String get bitsPerRawSample => audioStateController.bitsPerRawSample.value;
  String get bitRate => audioStateController.bitRate.value;

  String formatDuration(Duration? duration) {
    if (duration == null || duration == Duration.zero) return 'buffering';
    String minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void setfavorite(String? id, String? isFavorite) async {
    String api = dotenv.env['FAVORITE_API_URL'] ?? '';
    String url = '$api?_id=$id&_favorite=$isFavorite';

    try {
      await http.post(
        Uri.parse(url),
      );
    } catch (e, st) {
      logError('Error set favorite: $e, stack: $st');
    }
  }

  void onChangeStartSlider() {
    isSeeking.value = true;
  }

  void onChangedSlider(double value) {
    final newPosition = value * (duration.inMilliseconds);
    dragValue.value = Duration(milliseconds: newPosition.round());
  }

  void onChangeEndSlider(double value) {
    final position = value * duration.inMilliseconds;
    player!.seek(Duration(milliseconds: position.round()));
    // Setelah selesai, baru update state
    isSeeking.value = false;
  }
}
