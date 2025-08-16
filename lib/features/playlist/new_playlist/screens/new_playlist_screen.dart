import 'package:cybeat_music_player/controller/crud_playlist.dart';
import 'package:cybeat_music_player/features/home/controllers/home_controller.dart';
import 'package:cybeat_music_player/features/playlist/new_playlist/widgets/scale_tap_button_new.dart';
// Di-as karena ada duplikasi function.
import 'package:cybeat_music_player/widgets/new_playlist_widget/text_button.dart'
    as text_button;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NewPlaylistScreen extends StatefulWidget {
  const NewPlaylistScreen({super.key});

  @override
  State<NewPlaylistScreen> createState() => _NewPlaylistScreenState();
}

class _NewPlaylistScreenState extends State<NewPlaylistScreen> {
  final FocusNode _focusNode = FocusNode();
  final textController = TextEditingController();

  final crudPlaylistController = Get.put(CrudPlaylistController());

  @override
  void initState() {
    super.initState();
    final homeAlbumGridController = Get.find<HomeController>();
    textController.text =
        'New Playlist #${homeAlbumGridController.playlistCreatedList.length + 1}';
    // Set nama playlist ke controller.
    crudPlaylistController.onChange(textController.text);
    // Biar auto select text.
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
            colors: [Colors.white, Colors.grey.withValues(alpha: 0.8)],
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
                  color: Colors.black.withValues(alpha: 0.8),
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
                        selectionColor: Colors.yellow.withValues(alpha: 0.4),
                        selectionHandleColor:
                            Colors.blue.withValues(alpha: 0.5),
                      ),
                    ),
                    child: TextField(
                      controller: textController,
                      autofocus: true,
                      focusNode: _focusNode,
                      onChanged: (value) {
                        crudPlaylistController.onChange(value);
                      },
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.black.withValues(alpha: 0.7),
                      ),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.only(bottom: 0),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black.withValues(alpha: 0.7),
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
                      child: text_button.TextButton(
                        title: 'Cancel',
                        textController: textController,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Obx(
                      () => crudPlaylistController.namePlaylist.value.isEmpty
                          ? AbsorbPointer(
                              child: ScaleTapButtonNewPlaylist(
                                child: text_button.TextButton(
                                  title: 'Create',
                                  isDisable: true,
                                  textController: textController,
                                ),
                              ),
                            )
                          : ScaleTapButtonNewPlaylist(
                              child: text_button.TextButton(
                                title: 'Create',
                                textController: textController,
                              ),
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
