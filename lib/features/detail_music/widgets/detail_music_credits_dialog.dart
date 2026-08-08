import 'package:audio_service/audio_service.dart';
import 'package:cybeat_music_player/common/widgets/music_credits_dialog.dart';
import 'package:flutter/material.dart';

void detailMusicCreditsDialog(
    {required BuildContext context, required MediaItem currentMediaItem}) {
  showMusicCreditsDialog(context: context, currentMediaItem: currentMediaItem);
}
