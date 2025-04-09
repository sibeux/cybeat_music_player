import 'package:cached_network_image/cached_network_image.dart';
import 'package:cybeat_music_player/controller/crud_playlist.dart';
import 'package:cybeat_music_player/controller/search_album_controller.dart';
import 'package:cybeat_music_player/screens/crud_playlist_screen/edit_playlist_screen.dart/show_discard_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';

final searchAlbumController = Get.put(SearchAlbumController());
final FocusNode _focusNode = FocusNode();
final textController = searchAlbumController.controller;

class EditPlaylistScreen extends StatelessWidget {
  const EditPlaylistScreen(
      {super.key, required this.playlistName, required this.uid});

  final String playlistName, uid;

  @override
  Widget build(BuildContext context) {
    var tapIndex = 0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      textController.text = playlistName;
      tapIndex = 0;
      searchAlbumController.textValue.value = textController.text;
    });

    return Scaffold(
      backgroundColor: HexColor('#fefffe'),
      appBar: AppBar(
        backgroundColor: HexColor('#fefffe'),
        toolbarHeight: 80,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            if (searchAlbumController.textValue.value.toLowerCase() !=
                playlistName.toLowerCase()) {
              showModalDiscardDialog(context);
            } else {
              Get.back();
            }
          },
        ),
        title: const Text(
          'Edit Playlist',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Obx(
            () => searchAlbumController.isTypingValue &&
                    searchAlbumController.textValue.value.toLowerCase() !=
                        playlistName.toLowerCase()
                ? saveButton(
                    color: HexColor('#8238be'),
                    onTap: () {
                      Get.back();
                      updatePlaylist(
                        uid,
                        searchAlbumController.textValue.value,
                      );
                    },
                  )
                : saveButton(
                    color: Colors.black.withValues(alpha: 0.4),
                    onTap: () {},
                  ),
          )
        ],
      ),
      body: Column(
        children: [
          Center(
            child: CachedNetworkImage(
              imageUrl: '',
              fit: BoxFit.cover,
              height: 200,
              width: 200,
              maxHeightDiskCache: 500,
              maxWidthDiskCache: 500,
              filterQuality: FilterQuality.low,
              placeholder: (context, url) => Image.asset(
                'assets/images/placeholder_cover_music.png',
                fit: BoxFit.cover,
                filterQuality: FilterQuality.low,
              ),
              errorWidget: (context, url, error) => Image.asset(
                'assets/images/placeholder_cover_music.png',
                fit: BoxFit.cover,
                filterQuality: FilterQuality.low,
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          GestureDetector(
            child: Text(
              'Change Image',
              style: TextStyle(
                color: Colors.black.withValues(alpha: 0.8),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(
            height: 35,
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Theme(
                data: ThemeData(
                  textSelectionTheme: TextSelectionThemeData(
                    cursorColor: Colors.blue, // Cursor color
                    selectionColor: Colors.yellow.withValues(alpha: 0.4),
                    selectionHandleColor: Colors.blue.withValues(alpha: 0.5),
                  ),
                ),
                child: TextField(
                  onTap: () {
                    if (tapIndex == 0) {
                      textController.selection = TextSelection(
                        baseOffset: 0,
                        extentOffset: textController.text.length,
                      );
                      tapIndex++;
                    } else {}
                  },
                  onChanged: (value) {
                    searchAlbumController.onTyping(value);
                    searchAlbumController.textValue.value = value;
                  },
                  controller: textController,
                  focusNode: _focusNode,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.black.withValues(alpha: 0.7),
                  ),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.only(bottom: 0),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors.black
                              .withValues(alpha: 0.7)), // Color when focused
                    ),
                    hintText: 'Playlist Name',
                    hintStyle: TextStyle(
                        color: Colors.black.withValues(alpha: 0.4),
                        fontSize: 40),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  GestureDetector saveButton({
    required Color color,
    required void Function() onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // default margin dari IconButton ke kanan adalah 24
        // makanya leading gak perlu dikasih margin
        margin: const EdgeInsets.only(right: 24),
        child: Text(
          'Save',
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
