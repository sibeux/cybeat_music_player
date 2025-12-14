import 'package:audio_service/audio_service.dart';
import 'package:cybeat_music_player/core/controllers/music_download_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class AlbumMusicIndexNumberList extends StatelessWidget {
  const AlbumMusicIndexNumberList({
    super.key,
    required this.marginList,
    required this.musicDownloadController,
    required this.mediaItem,
    required this.indexIcon,
    required this.musikDimainkan,
  });

  final double marginList;
  final MusicDownloadController musicDownloadController;
  final MediaItem mediaItem;
  final Widget indexIcon;
  final MediaItem? musikDimainkan;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40.w,
      height: 40.h,
      alignment: Alignment.center,
      margin: EdgeInsets.only(
        left: marginList.w,
      ),
      child: Obx(
        () => musicDownloadController
                    .dataProgressDownload[mediaItem.extras!['music_id']] !=
                null
            ? musicDownloadController.dataProgressDownload[
                        mediaItem.extras!['music_id']]!['progress'] ==
                    0.0
                ? indexIcon
                : Transform.scale(
                    scale: 0.8,
                    child: CircularPercentIndicator(
                      radius: 20.r,
                      lineWidth: 2.w,
                      percent: musicDownloadController.dataProgressDownload[
                          mediaItem.extras!['music_id']]!['progress'],
                      center: Text(
                        '${(musicDownloadController.dataProgressDownload[mediaItem.extras!['music_id']]!['progress'] * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: HexColor('#8238be'),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      progressColor: HexColor('#8238be'),
                      backgroundColor: HexColor('#8d8c8c'),
                    ),
                  )
            : mediaItem.extras?['is_downloaded'] == true &&
                    musikDimainkan?.id != mediaItem.id
                ? Icon(
                    Icons.download_done_rounded,
                    color: Colors.green,
                    size: 20.sp,
                  )
                : indexIcon,
      ),
    );
  }
}
