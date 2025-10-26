import 'package:audio_service/audio_service.dart';
import 'package:cybeat_music_player/common/utils/capitalize.dart';
import 'package:cybeat_music_player/core/controllers/audio_state_controller.dart';
import 'package:cybeat_music_player/core/controllers/music_download_controller.dart';
import 'package:cybeat_music_player/core/controllers/music_player_controller.dart';
import 'package:cybeat_music_player/core/models/music.dart';
import 'package:cybeat_music_player/features/album_music/controllers/album_music_controller.dart';
import 'package:cybeat_music_player/features/album_music/widgets/album_music_index_number_list.dart';
import 'package:cybeat_music_player/features/album_music/widgets/album_music_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';

class AlbumMusicSimpleList extends StatelessWidget {
  const AlbumMusicSimpleList({
    super.key,
    required this.music,
    required this.audioStateController,
    required this.albumMusicController,
    required this.index,
  });
  final AudioStateController audioStateController;
  final AlbumMusicController albumMusicController;
  final Music music;
  final int index;

  @override
  Widget build(BuildContext context) {
    final mediaItem = MediaItem(
      id: music.musicId,
      title: music.title,
      album: music.album,
      artUri: Uri.parse(music.cover),
      artist: music.artist,
      extras: music.extras,
    );
    final musikDimainkan =
        Get.find<MusicPlayerController>().getCurrentMediaItem;
    final musicDownloadController = Get.find<MusicDownloadController>();
    String colorTitle = "#313031";
    String colorIndex = "#8d8c8c";
    double marginList = 18;
    FontWeight fontWeightTitleIndex = FontWeight.normal;

    if (musikDimainkan?.extras!['music_id'] == mediaItem.extras!['music_id']) {
      colorTitle = '#8238be';
      colorIndex = '#8238be';
      marginList = 10;
      fontWeightTitleIndex = FontWeight.bold;
    }

    // Perbedaa dari azlist: ini diletakkan setelah if,
    // karena yang diubah di sini adalah style, bukan value widget-nya.
    Widget indexIcon = Text(
      mediaItem.id.toString().padLeft(2, '0'),
      style: TextStyle(
        fontSize: 12.sp,
        color: HexColor(colorIndex),
        fontWeight: fontWeightTitleIndex,
      ),
    );

    return SizedBox(
      height: 60.h,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              AlbumMusicIndexNumberList(
                marginList: marginList,
                musicDownloadController: musicDownloadController,
                mediaItem: mediaItem,
                indexIcon: indexIcon,
                musikDimainkan: musikDimainkan,
              ),
              SizedBox(
                width: 2.w,
              ),
              Expanded(
                child: SizedBox(
                  height: 40.h,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        capitalizeEachWord(mediaItem.title),
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: HexColor(colorTitle),
                          overflow: TextOverflow.ellipsis,
                          fontWeight: fontWeightTitleIndex,
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: HexColor('#b4b5b4'),
                                  overflow: TextOverflow.ellipsis,
                                  fontWeight: FontWeight.values[3],
                                ),
                                '${capitalizeEachWord(mediaItem.artist!)} | ${capitalizeEachWord(mediaItem.album!)}',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 5.w,
              ),
              IconButton(
                highlightColor: Colors.black.withValues(alpha: 0.02),
                icon: Icon(
                  Icons.more_vert_sharp,
                  size: 30.sp,
                  color: HexColor('#b5b5b4'),
                ),
                onPressed: () {
                  albumMusicModal(
                    context,
                    mediaItem,
                    audioStateController.activePlayer.value!,
                    index,
                    audioStateController,
                  );
                },
              ),
              SizedBox(
                width: 10.w,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
