import 'package:cybeat_music_player/features/album_music/controllers/album_music_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';

class AlbumMusicSearchBar extends StatelessWidget {
  const AlbumMusicSearchBar({
    super.key,
    required this.albumMusicController,
  });

  final AlbumMusicController albumMusicController;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      // backgroundColor: Colors.transparent,
      backgroundColor: HexColor('#fefffe'),
      surfaceTintColor: Colors.transparent,
      pinned: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded),
        onPressed: () {
          albumMusicController.backButtonSearchTapped();
        },
      ),
      titleSpacing: 0,
      actions: [
        SizedBox(
          width: 20.w,
        )
      ],
      title: TextFormField(
        controller: albumMusicController.textController,
        cursorColor: HexColor('#575757'),
        textAlignVertical: TextAlignVertical.center,
        onChanged: (value) {
          albumMusicController.onChanged(value);
        },
        onTap: () {
          albumMusicController.isKeybordFocus.value = true;
        },
        style: TextStyle(color: HexColor('#575757'), fontSize: 12.sp),
        decoration: InputDecoration(
          filled: true,
          isDense: true,
          fillColor: HexColor('#f1f1f1'),
          contentPadding: EdgeInsets.symmetric(vertical: 7.h, horizontal: 7.w),
          hintText: 'Search Your Music',
          hintStyle: TextStyle(color: HexColor('#909191'), fontSize: 12.sp),
          suffixIconConstraints: const BoxConstraints(
            minWidth: 30,
            minHeight: 20,
          ),
          suffixIcon: Obx(
            () => albumMusicController.isTyping.value
                ? GestureDetector(
                    onTap: () {
                      albumMusicController.textController.clear();
                      albumMusicController.onChanged('');
                    },
                    child: Icon(
                      Icons.close,
                      color: HexColor('#575757'),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          enabledBorder: outlineInputBorder(),
          focusedBorder: outlineInputBorder(),
        ),
      ),
    );
  }
}

OutlineInputBorder outlineInputBorder() {
  return OutlineInputBorder(
    borderSide: const BorderSide(color: Colors.transparent),
    borderRadius: BorderRadius.circular(5.r),
  );
}
