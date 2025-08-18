import 'package:cybeat_music_player/features/playlist/add_music_to_playlist/controllers/add_music_to_playlist_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';

TextFormField searchBar(AddMusicToPlaylistController musicPlaylistController,
    {required bool needHint}) {
  return TextFormField(
    controller: musicPlaylistController.textController,
    cursorColor: HexColor('#575757'),
    autofocus: !needHint,
    textAlignVertical: TextAlignVertical.center,
    onChanged: (value) {
      musicPlaylistController.onChanged(value);
    },
    onTap: () {
      musicPlaylistController.isKeybordFocus.value = true;
    },
    style: TextStyle(color: HexColor('#575757'), fontSize: 12),
    onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
    decoration: InputDecoration(
      filled: true,
      isDense: true,
      fillColor: HexColor('#f1f1f1'),
      contentPadding: const EdgeInsets.symmetric(vertical: 7, horizontal: 7),
      hintText: needHint ? 'Find playlist' : '',
      hintStyle: TextStyle(
        color: Colors.black.withValues(alpha: 0.8),
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
      // * agar textfield tidak terlalu lebar/tinggi, maka dibuat constraints
      prefixIconConstraints: const BoxConstraints(
        minWidth: 30,
        minHeight: 35,
      ),
      suffixIconConstraints: const BoxConstraints(
        minWidth: 30,
        minHeight: 35,
      ),
      prefixIcon: Icon(
        Icons.search,
        color: Colors.black.withValues(alpha: 01),
      ),
      suffixIcon: Obx(() => musicPlaylistController.isTypingValue
          ? GestureDetector(
              onTap: () {
                musicPlaylistController.textController.clear();
                musicPlaylistController.onChanged('');
              },
              child: Icon(
                Icons.close,
                color: HexColor('#575757'),
              ),
            )
          : const SizedBox.shrink()),
      enabledBorder: outlineInputBorder(),
      focusedBorder: outlineInputBorder(),
    ),
  );
}

OutlineInputBorder outlineInputBorder() {
  return OutlineInputBorder(
    borderSide: const BorderSide(color: Colors.transparent),
    borderRadius: BorderRadius.circular(5),
  );
}
