import 'package:cybeat_music_player/features/playlist/add_music_to_playlist/controllers/add_music_to_playlist_controller.dart';
import 'package:cybeat_music_player/features/playlist/add_music_to_playlist/widgets/add_all_music/add_all_music_add_modal_effect_tap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

final _scrollController = ScrollController();

Future<dynamic> addAllMusicAddModal(
  BuildContext context,
  AddMusicToPlaylistController addMusicToPlaylistController,
) {
  return showMaterialModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    clipBehavior: Clip.antiAliasWithSaveLayer,
    builder: (context) => Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(
          Radius.circular(20.r),
        ),
      ),
      margin: const EdgeInsets.all(12),
      child: Column(
        // mainAxisSize: MainAxisSize.min - mencegah layar full
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 20.h,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Text(
              'Add to playlist',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          // by default, ListTile has a padding of 16
          RawScrollbar(
            radius: Radius.circular(10.r),
            controller: _scrollController,
            padding: const EdgeInsets.only(top: 55),
            thumbVisibility: true,
            trackVisibility: true,
            thickness: 5,
            thumbColor: HexColor('#ac8bc9').withValues(alpha: 0.7),
            child: ListView.builder(
              // Penggunaan shrinkWrap: true
              shrinkWrap: true,
              /**
               * ListView.builder perlu tinggi eksplisit, seperti expanded atau dari height parent (container/sizedbox).
               * Tapi, jika data cuma 50-100, maka bisa pakai shrinkWrap: true.
               * Kenapa? Karena ListView akan mengambil tinggi sesuai dengan item yang ada.
               * Jadi, modal bisa menyesuaikan tinggi dari listview.builder.
               */
              controller: _scrollController,
              itemCount:
                  addMusicToPlaylistController.playlistCreatedList.length,
              itemBuilder: (context, index) {
                return AddAllMusicAddModalEffectTap(
                  child: ListTileBottomModal(
                    title: addMusicToPlaylistController
                        .playlistCreatedList[index].title,
                    onTap: () {
                      Get.back();
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}

class ListTileBottomModal extends StatelessWidget {
  const ListTileBottomModal({
    super.key,
    required this.title,
    required this.onTap,
  });

  final String title;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 0.h),
      minVerticalPadding: 5,
      title: Text(title),
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 14.sp,
        fontWeight: FontWeight.bold,
      ),
      onTap: onTap,
    );
  }
}
