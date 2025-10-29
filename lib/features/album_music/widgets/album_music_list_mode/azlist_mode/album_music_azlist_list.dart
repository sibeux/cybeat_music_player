import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cybeat_music_player/core/controllers/music_download_controller.dart';
import 'package:cybeat_music_player/core/controllers/audio_state_controller.dart';
import 'package:cybeat_music_player/common/utils/capitalize.dart';
import 'package:cybeat_music_player/core/controllers/music_player_controller.dart';
import 'package:cybeat_music_player/core/models/music.dart';
import 'package:cybeat_music_player/features/album_music/widgets/album_music_index_number_list.dart';
import 'package:cybeat_music_player/features/album_music/widgets/album_music_modal.dart';
import 'package:cybeat_music_player/common/widgets/spectrum_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:just_audio/just_audio.dart';

class AlbumMusicAzlistList extends StatelessWidget {
  const AlbumMusicAzlistList({
    super.key,
    required this.music,
    required this.audioPlayer,
    required this.index,
    required this.audioState,
  });
  final Music music;
  final AudioPlayer audioPlayer;
  final int index;
  final AudioStateController audioState;

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
    final musicDownloadController = Get.find<MusicDownloadController>();

    Widget indexIcon = Text(
      mediaItem.extras!['index'].toString().padLeft(2, '0'),
      style: TextStyle(
        fontSize: 12,
        color: HexColor('#8d8c8c'),
        fontWeight: FontWeight.bold,
      ),
    );

    return SizedBox(
      height: 70.h,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Obx(() => AlbumMusicIndexNumberList(
                    marginList: Get.find<MusicPlayerController>()
                                .getCurrentMediaItem
                                ?.extras!['music_id'] ==
                            mediaItem.id
                        ? 12
                        : 18,
                    musicDownloadController: musicDownloadController,
                    mediaItem: mediaItem,
                    indexIcon: Get.find<MusicPlayerController>()
                                .getCurrentMediaItem
                                ?.extras!['music_id'] ==
                            mediaItem.id
                        ? const SpectrumAnimation()
                        : indexIcon,
                    musikDimainkan:
                        Get.find<MusicPlayerController>().getCurrentMediaItem,
                  )),
              // cover image
              Container(
                width: 45.w,
                height: 45.h,
                margin: const EdgeInsets.only(right: 5),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 40.w,
                      height: 40.h,
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(5.r)),
                        child: CachedNetworkImage(
                          imageUrl: mediaItem.artUri.toString(),
                          fit: BoxFit.cover,
                          maxHeightDiskCache: 150,
                          maxWidthDiskCache: 150,
                          filterQuality: FilterQuality.low,
                          placeholder: (context, url) => Image.asset(
                            'assets/images/placeholder_cover_music.png',
                            fit: BoxFit.cover,
                          ),
                          errorWidget: (context, url, error) => Image.asset(
                            'assets/images/placeholder_cover_music.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    if (mediaItem.extras?['is_lossless'])
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Image.asset(
                          mediaItem.extras?['metadata']['codec_name'] == 'alac'
                              ? 'assets/images/badge-alac.png'
                              : double.parse(mediaItem.extras?['metadata']
                                              ['sample_rate'])
                                          .toInt() >=
                                      96
                                  ? 'assets/images/badge-en-hires.png'
                                  : 'assets/images/badge-en-lossless.png',
                          fit: BoxFit.cover,
                          width: 30.w,
                          height: 30.h,
                        ),
                      )
                  ],
                ),
              ),
              SizedBox(
                width: 2.w,
              ),
              Expanded(
                child: SizedBox(
                  height: 45.h,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(() => Text(
                            capitalizeEachWord(mediaItem.title),
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: HexColor(Get.find<MusicPlayerController>()
                                          .getCurrentMediaItem
                                          ?.extras!['music_id'] ==
                                      mediaItem.id
                                  ? '#8238be'
                                  : "#313031"),
                              overflow: TextOverflow.ellipsis,
                              fontWeight: FontWeight.bold,
                            ),
                          )),
                      Row(
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            child: Icon(
                              Icons.audiotrack_outlined,
                              color: HexColor('#b4b5b4'),
                              size: 15.sp,
                            ),
                          ),
                          Expanded(
                            child: Container(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: HexColor('#b4b5b4'),
                                  overflow: TextOverflow.ellipsis,
                                  fontWeight: FontWeight.values[4],
                                ),
                                '${capitalizeEachWord(mediaItem.artist!)} | ${capitalizeEachWord(mediaItem.album!)}',
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
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
                    audioPlayer,
                    index,
                    audioState,
                  );
                },
              ),
              SizedBox(
                width: 15.w,
              ),
            ],
          ),
          SizedBox(
            height: 10.h,
          ),
          Container(
            margin: EdgeInsets.only(left: 18.w, right: 10.w),
            width: double.infinity,
            height: 1.h,
            color: HexColor('#e0e0e0').withValues(alpha: 0.7),
          ),
        ],
      ),
    );
  }
}
