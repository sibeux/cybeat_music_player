import 'package:cybeat_music_player/controller/crud_playlist.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';

class TextButton extends StatelessWidget {
  const TextButton({
    super.key,
    required this.title,
    required this.textController,
    this.isDisable = false,
  });

  final String title;
  final TextEditingController textController;
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
          addNewPlaylist(textController.text);
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
