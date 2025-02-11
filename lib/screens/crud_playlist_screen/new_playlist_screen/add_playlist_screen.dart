import 'package:cybeat_music_player/controller/crud_playlist.dart';
import 'package:cybeat_music_player/screens/crud_playlist_screen/new_playlist_screen/scale_tap_button_new.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';

class AddPlaylistScreen extends StatefulWidget {
  const AddPlaylistScreen({super.key});

  @override
  State<AddPlaylistScreen> createState() => _AddPlaylistScreenState();
}

class _AddPlaylistScreenState extends State<AddPlaylistScreen> {
  final FocusNode _focusNode = FocusNode();
  final textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    textController.text = 'New Playlist';
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        textController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: textController.text.length,
        );
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey.withOpacity(0.8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Give your playlist a name',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 25),
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
                      controller: textController,
                      autofocus: true,
                      focusNode: _focusNode,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.black.withOpacity(0.7),
                      ),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.only(bottom: 0),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black.withOpacity(0.7),
                          ), // Color when focused
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 35),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ScaleTapButtonNewPlaylist(
                      child: TextButton(
                        title: 'Cancel',
                        textController: textController,
                      ),
                    ),
                    const SizedBox(width: 20),
                    ScaleTapButtonNewPlaylist(
                      child: TextButton(
                        title: 'Create',
                        textController: textController,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class TextButton extends StatelessWidget {
  const TextButton({
    super.key,
    required this.title,
    required this.textController,
  });

  final String title;
  final TextEditingController textController;

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
              ? Colors.black.withOpacity(0)
              : HexColor('#ac8bc9'),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: title == 'Cancel'
                ? Colors.black.withOpacity(0.6)
                : HexColor('#ac8bc9'),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: title == 'Cancel'
                  ? Colors.black.withOpacity(0.6)
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
