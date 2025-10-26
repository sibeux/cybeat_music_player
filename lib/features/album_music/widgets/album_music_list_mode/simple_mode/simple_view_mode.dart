import 'package:cybeat_music_player/core/controllers/audio_state_controller.dart';
import 'package:cybeat_music_player/features/album_music/controllers/album_music_controller.dart';
import 'package:cybeat_music_player/features/album_music/widgets/album_music_list_mode/simple_mode/album_music_simple_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:just_audio/just_audio.dart';

class NoGlowScrollBehavior extends ScrollBehavior {
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

final _scrollController = ScrollController();

class SimpleViewMode extends StatelessWidget {
  const SimpleViewMode({
    super.key,
    required this.sequence,
    required this.audioStateController,
    required this.albumMusicController,
  });

  final List<IndexedAudioSource> sequence;
  final AudioStateController audioStateController;
  final AlbumMusicController albumMusicController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 5.w),
      child: ScrollConfiguration(
        behavior: NoGlowScrollBehavior(),
        child: GlowingOverscrollIndicator(
          axisDirection: AxisDirection.down,
          color: HexColor('#8238be'),
          child: RawScrollbar(
            radius: Radius.circular(10.r),
            controller: _scrollController,
            thumbVisibility: true,
            timeToFade: const Duration(milliseconds: 500),
            thickness: 10,
            thumbColor: HexColor('#ac8bc9').withValues(alpha: 0.7),
            trackVisibility: false,
            child: ListView.builder(
                controller: _scrollController,
                itemCount: sequence.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      // albumMusicController.navigateToDetailMusicScreen(
                      //   index: index,
                      // );
                    },
                    child: AlbumMusicSimpleList(
                      index: index,
                      music: audioStateController.playlist[index],
                      audioStateController: audioStateController,
                      albumMusicController: albumMusicController,
                    ),
                  );
                }),
          ),
        ),
      ),
    );
  }
}
