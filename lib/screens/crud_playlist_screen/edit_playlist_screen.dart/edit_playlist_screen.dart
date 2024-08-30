import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

final FocusNode _focusNode = FocusNode();
final textController = TextEditingController();

class EditPlaylistScreen extends StatelessWidget {
  const EditPlaylistScreen({super.key, required this.playlistName});

  final String playlistName;

  @override
  Widget build(BuildContext context) {
    textController.text = playlistName;
    var tapIndex = 0;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Get.back();
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
          GestureDetector(
            onTap: () {},
            child: Container(
              // default margin dari IconButton ke kanan adalah 24
              // makanya leading gak perlu dikasih margin
              margin: const EdgeInsets.only(right: 24),
              child: Text(
                'Save',
                style: TextStyle(
                  color: Colors.black.withOpacity(0.6),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
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
                color: Colors.black.withOpacity(0.8),
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
                    selectionColor: Colors.yellow.withOpacity(0.4),
                    selectionHandleColor: Colors.blue.withOpacity(0.5),
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
                    } else {
                      
                    }
                  },
                  controller: textController,
                  focusNode: _focusNode,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.black.withOpacity(0.7),
                  ),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.only(bottom: 0),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors.black
                              .withOpacity(0.7)), // Color when focused
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
