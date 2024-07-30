import 'package:cybeat_music_player/controller/search_album_controller.dart';
import 'package:cybeat_music_player/screens/search_album_screen/scale_tap_search_album.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchAlbumList extends StatelessWidget {
  const SearchAlbumList({super.key});

  @override
  Widget build(BuildContext context) {
    SearchAlbumController searchAlbumController = Get.find();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        itemCount: searchAlbumController.filteredAlbum.length + 1,
        itemBuilder: (context, indeks) {
          final index = indeks - 1;
          return indeks == 0
              ? const SizedBox(
                  height: 20,
                )
              : ScaleTapSearchAlbum(index: index,);
        },
      ),
    );
  }
}
