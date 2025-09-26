import 'package:cybeat_music_player/features/playlist/add_music_to_playlist/controllers/add_music_to_playlist_controller.dart';
import 'package:cybeat_music_player/features/playlist/add_music_to_playlist/widgets/add_all_music/add_all_music_add_modal.dart';
import 'package:cybeat_music_player/features/playlist/add_music_to_playlist/widgets/add_all_music/add_all_music_button_effect_tap.dart';
import 'package:cybeat_music_player/features/playlist/add_music_to_playlist/widgets/add_all_music/add_all_music_listile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';

class AddAllMusicToPlaylistScreen extends StatelessWidget {
  const AddAllMusicToPlaylistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AddMusicToPlaylistController addMusicToPlaylistController =
        Get.find<AddMusicToPlaylistController>();
    return Scaffold(
      backgroundColor: HexColor('#fefffe'),
      appBar: AppBar(
        backgroundColor: HexColor('#fefffe'),
        scrolledUnderElevation: 0.0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          tooltip: 'Back',
          onPressed: () {
            // On pressed ini berlaku saat icon back button diklik.
            // Tidak berlaku saat nav back button diklik.
            Get.back();
          },
        ),
        centerTitle: true,
        toolbarHeight: 60.h,
        title: Obx(() => Text(
              "${addMusicToPlaylistController.addAllMusicId.length} items selected",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: HexColor('#1e0b2b'),
                fontSize: 18.sp,
              ),
            )),
        actionsPadding: EdgeInsets.only(right: 5.w),
        actions: [
          IconButton(
            onPressed: () {
              addMusicToPlaylistController.toggleSelectAll(isBulkSelect: true);
            },
            icon: Obx(
              () => addMusicToPlaylistController.isSelectAll.value
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
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: addMusicToPlaylistController.currentQueue.length,
              itemBuilder: (context, index) {
                return AddAllMusicListile(
                  mediaItem: addMusicToPlaylistController.currentQueue[index],
                  addMusicToPlaylistController: addMusicToPlaylistController,
                );
              },
            ),
          ),
          Container(
            height: 10.h,
            color: HexColor('#fefffe'),
          ),
          Divider(
            color: Colors.grey.withValues(alpha: 0.4),
            height: 0.5.h,
            thickness: 0.5.h,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
            color: HexColor('#fefffe'),
            child: Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    AbsorbPointer(
                      absorbing:
                          addMusicToPlaylistController.addAllMusicId.isEmpty,
                      child: AddAllMusicButtonEffectTap(
                        onTap: () {
                          addAllMusicAddModal(
                              context, addMusicToPlaylistController);
                        },
                        child: Icon(
                          Icons.add_to_photos_outlined,
                          color: addMusicToPlaylistController
                                  .addAllMusicId.isNotEmpty
                              ? HexColor('#000000').withValues(alpha: 0.5)
                              : HexColor('#e1e1e1'),
                          size: 25.sp,
                        ),
                      ),
                    ),
                  ],
                )),
          )
        ],
      ),
    );
  }
}
