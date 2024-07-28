import 'package:cybeat_music_player/controller/search_album_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';

class SearchAlbumScreen extends StatelessWidget {
  const SearchAlbumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SearchAlbumController searchAlbumController =
        Get.put(SearchAlbumController());

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: HexColor('#575757'),
          ),
          tooltip: 'Back',
          onPressed: () {
            Get.back();
          },
        ),
        titleSpacing: 0,
        title: TextFormField(
          controller: searchAlbumController.controller,
          textAlignVertical: TextAlignVertical.center,
          onChanged: (value) {
            searchAlbumController.onChanged(value);
          },
          style: TextStyle(color: HexColor('#575757'), fontSize: 12),
          decoration: InputDecoration(
            filled: true,
            isDense: true,
            fillColor: HexColor('#f1f1f1'),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 7, horizontal: 7),
            hintText: 'Search Your Library',
            hintStyle: TextStyle(color: HexColor('#909191'), fontSize: 12),
            suffixIconConstraints: const BoxConstraints(
              minWidth: 30,
              minHeight: 20,
            ),
            suffixIcon: Obx(() => searchAlbumController.isTypingValue
                ? GestureDetector(
                  onTap: () {
                    searchAlbumController.controller.clear();
                    searchAlbumController.onChanged('');
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
        ),
        actions: const [
          SizedBox(
            width: 20,
          )
        ],
        toolbarHeight: 100,
      ),
      body: Obx(
        () => searchAlbumController.isTypingValue
            ? Center(child: Text(searchAlbumController.getTextValue))
            : initialChild(),
      ),
    );
  }

  Widget initialChild() {
    return const Center(
      child: Text('Search Album Screen'),
    );
  }

  OutlineInputBorder outlineInputBorder() {
    return OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.transparent),
      borderRadius: BorderRadius.circular(5),
    );
  }
}
