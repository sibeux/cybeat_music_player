import 'package:cybeat_music_player/features/playlist/new_playlist/controllers/new_playlist_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';

class NewPlaylistTextButton extends StatelessWidget {
  const NewPlaylistTextButton({
    super.key,
    required this.title,
    required this.textController,
    required this.newPlaylistController,
    this.isDisable = false,
  });

  final String title;
  final TextEditingController textController;
  final NewPlaylistController newPlaylistController;
  final bool isDisable;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        if (title == 'Cancel') {
          Get.back();
        } else {
          // create playlist
          newPlaylistController.addNewPlaylist(textController.text);
          Get.back();
        }
      },
      child: Container(
        width: 120,
        height: 50,
        decoration: BoxDecoration(
          color: title == 'Cancel'
              ? Colors.black.withValues(alpha: 0)
              : isDisable
                  ? Colors.grey
                  : HexColor('#ac8bc9'),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: title == 'Cancel'
                ? Colors.black.withValues(alpha: 0.6)
                : isDisable
                    ? Colors.grey
                    : HexColor('#ac8bc9'),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: title == 'Cancel'
                  ? Colors.black.withValues(alpha: 0.6)
                  : Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
