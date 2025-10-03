import 'package:audio_service/audio_service.dart';
import 'package:azlistview/azlistview.dart';
import 'package:cybeat_music_player/core/controllers/audio_state_controller.dart';
import 'package:cybeat_music_player/features/album_music/controllers/album_music_controller.dart';
import 'package:cybeat_music_player/features/album_music/screens/album_music_screen.dart';
import 'package:cybeat_music_player/features/album_music/widgets/album_music_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:just_audio/just_audio.dart';

class AzlistViewMode extends StatelessWidget {
  const AzlistViewMode({
    super.key,
    required this.audioStateController,
    required this.albumMusicController,
    required this.sequence,
  });

  final List<IndexedAudioSource> sequence;
  final AudioStateController audioStateController;
  final AlbumMusicController albumMusicController;

  @override
  Widget build(BuildContext context) {
    final musicItems = sequence
        .map(
          (e) => AzListMusic(
            title: e.tag.title,
            tag: e.tag.title.substring(0, 1).toUpperCase(),
          ),
        )
        .toList();
    return AzListView(
      data: musicItems,
      itemCount: sequence.length,
      indexBarAlignment: Alignment.topRight,
      indexBarOptions: IndexBarOptions(
        indexHintDecoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.7),
          shape: BoxShape.circle,
        ),
        selectItemDecoration: BoxDecoration(
          shape: BoxShape.circle,
          color: HexColor('#6a5081'),
        ),
        needRebuild: true,
        selectTextStyle: TextStyle(
          color: HexColor('#fefffe'),
          fontSize: 12.sp,
        ),
      ),
      itemBuilder: (context, index) {
        // Akan di-print terus saat scroll.
        // print(index);
        return InkWell(
          child: AlbumMusicList(
            mediaItem: sequence[index].tag as MediaItem,
            audioPlayer: audioStateController.activePlayer.value!,
            index: index,
            audioState: audioStateController,
          ),
          onTap: () {
            albumMusicController.navigateToDetailMusicScreen(
              sequence: sequence,
              index: index,
            );
          },
        );
      },
    );
  }
}
