import 'package:cybeat_music_player/controller/filter_album_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';

class FilterPlaylistAlbum extends StatelessWidget {
  const FilterPlaylistAlbum({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    final filterAlbumController = Get.find<FilterAlbumController>();
    return text.toLowerCase() == 'cancel'
        ? Container(
            height: 35,
            width: 35,
            decoration: BoxDecoration(
              color: HexColor('#ac8bc9'),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(
              Icons.cancel,
              color: Colors.white,
              size: 32,
            ),
          )
        : Obx(
            () => Container(
              alignment: Alignment.center,
              width: 80,
              height: 35,
              decoration: BoxDecoration(
                color: filterAlbumController.getSelectedFilter.toString() ==
                        text.toLowerCase()
                    ? HexColor('#ac8bc9')
                    : filterAlbumController.getSelectedFilter.toString() == ''
                        ? Colors.grey
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  color: filterAlbumController.getSelectedFilter.toString() ==
                          text.toLowerCase()
                      ? HexColor('#fefffe')
                      : filterAlbumController.getSelectedFilter.toString() == ''
                          ? HexColor('#fefffe')
                          : Colors.transparent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
  }
}
