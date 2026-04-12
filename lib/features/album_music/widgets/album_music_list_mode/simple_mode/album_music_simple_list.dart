import 'package:audio_service/audio_service.dart';
import 'package:cybeat_music_player/common/utils/capitalize.dart';
import 'package:cybeat_music_player/core/controllers/audio_state_controller.dart';
import 'package:cybeat_music_player/core/controllers/music_download_controller.dart';
import 'package:cybeat_music_player/core/controllers/music_player_controller.dart';
import 'package:cybeat_music_player/core/models/music.dart';
import 'package:cybeat_music_player/features/album_music/controllers/album_music_controller.dart';
import 'package:cybeat_music_player/features/album_music/widgets/album_music_widget_musiclist/album_music_index_number_list.dart';
import 'package:cybeat_music_player/features/album_music/widgets/album_music_widget_musiclist/album_music_modal.dart';
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
      id: music.musicId.toString(),
      title: music.title,
      album: music.album,
      artUri: Uri.parse(music.cover),
      artist: music.artist,
      extras: music.extras,
    );
    final musikDimainkan =
        Get.find<MusicPlayerController>().getCurrentMediaItem;
    final musicDownloadController = Get.find<MusicDownloadController>();

    Widget indexIcon = Obx(
      () => Text(
        mediaItem.extras!['index'].toString().padLeft(2, '0'),
        style: TextStyle(
          fontSize: 12.sp,
          color: Get.find<MusicPlayerController>()
                      .getCurrentMediaItem
                      ?.extras!['music_id'] ==
                  mediaItem.id
              ? HexColor('#8238be')
              : HexColor("#8d8c8c"),
          fontWeight: Get.find<MusicPlayerController>()
                      .getCurrentMediaItem
                      ?.extras!['music_id'] ==
                  mediaItem.id
              ? FontWeight.bold
              : FontWeight.normal,
        ),
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
              Obx(
                () => AlbumMusicIndexNumberList(
                  marginList: Get.find<MusicPlayerController>()
                              .getCurrentMediaItem
                              ?.extras!['music_id'] ==
                          mediaItem.id
                      ? 10
                      : 18,
                  musicDownloadController: musicDownloadController,
                  mediaItem: mediaItem,
                  indexIcon: indexIcon,
                  musikDimainkan: musikDimainkan,
                ),
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
                      Obx(
                        () => Text(
                          capitalizeEachWord(mediaItem.title),
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Get.find<MusicPlayerController>()
                                        .getCurrentMediaItem
                                        ?.extras!['music_id'] ==
                                    mediaItem.id
                                ? HexColor('#8238be')
                                : HexColor("#313031"),
                            overflow: TextOverflow.ellipsis,
                            fontWeight: Get.find<MusicPlayerController>()
                                        .getCurrentMediaItem
                                        ?.extras!['music_id'] ==
                                    mediaItem.id
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
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
