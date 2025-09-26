import 'package:audio_service/audio_service.dart';
import 'package:cybeat_music_player/common/utils/capitalize.dart';
import 'package:cybeat_music_player/features/playlist/add_music_to_playlist/controllers/add_music_to_playlist_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';

class AddAllMusicListile extends StatelessWidget {
  const AddAllMusicListile(
      {super.key,
      required this.mediaItem,
      required this.addMusicToPlaylistController});

  final MediaItem mediaItem;
  final AddMusicToPlaylistController addMusicToPlaylistController;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        addMusicToPlaylistController.toggleSelectAll(
            isBulkSelect: false, idMusic: mediaItem.id);
      },
      child: SizedBox(
        height: 60.h,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.h,
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(left: 10.w),
                  child: Text(
                    mediaItem.id.toString().padLeft(2, '0'),
                    style: TextStyle(
                      fontSize: 12,
                      color: HexColor('#8d8c8c'),
                      fontWeight: FontWeight.normal,
                    ),
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
                        Text(
                          capitalizeEachWord(mediaItem.title),
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: HexColor("#313031"),
                            overflow: TextOverflow.ellipsis,
                            fontWeight: FontWeight.normal,
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
                                  capitalizeEachWord(mediaItem.artist!),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                Obx(() => IconButton(
                      icon: addMusicToPlaylistController.addAllMusicId
                              .contains(mediaItem.id)
                          ? Icon(
                              Icons.check_circle,
                              color: HexColor('#8238be'),
                              size: 30.sp,
                            )
                          : Icon(
                              Icons.circle,
                              color: Colors.grey.withValues(alpha: 0.4),
                              size: 30.sp,
                            ),
                      onPressed: () {
                        addMusicToPlaylistController.toggleSelectAll(
                            isBulkSelect: false, idMusic: mediaItem.id);
                      },
                    )),
                SizedBox(
                  width: 5.w,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
