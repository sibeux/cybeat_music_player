import 'package:audio_service/audio_service.dart';
import 'package:cybeat_music_player/controller/music_play/music_state_controller.dart';
import 'package:cybeat_music_player/controller/music_play/playing_state_controller.dart';
import 'package:cybeat_music_player/controller/playlist_play_controller.dart';
import 'package:cybeat_music_player/providers/audio_state.dart';
import 'package:cybeat_music_player/providers/music_state.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:provider/provider.dart';

void musicPlayMethod({
  required AudioState state,
  required int index,
  required BuildContext context,
  required MediaItem mediaItem,
}) {
  final playlistPlayController = Get.find<PlaylistPlayController>();
  final playingStateController = Get.find<PlayingStateController>();
  final musicStateController = Get.find<MusicStateController>();

  state.player.seek(Duration.zero, index: index);

  state.player.setAudioSource(state.playlist, initialIndex: index);

  playingStateController.play();

  musicStateController.streamAudioPlayer(
    state.player,
    mediaItem,
  );

  context.read<MusicState>().setCurrentMediaItem(mediaItem);

  playlistPlayController.onPlaylistMusicPlay(
    audioState: state,
  );

  state.player.play();
}
