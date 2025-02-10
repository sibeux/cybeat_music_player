import 'package:cybeat_music_player/controller/music_playlist_controller.dart';
import 'package:cybeat_music_player/widgets/music_playlist_widget/list_playlist_container.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';

class MusicPlaylistScreen extends StatelessWidget {
  const MusicPlaylistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MusicPlaylistController musicPlaylistController =
        Get.put(MusicPlaylistController());
    return Scaffold(
      backgroundColor: HexColor('#fefffe'),
      appBar: AppBar(
        backgroundColor: HexColor('#fefffe'),
        surfaceTintColor: Colors.transparent,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Get.back();
          },
        ),
        centerTitle: true,
        title: const Text('Add to playlist'),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SizedBox(
          height: double.infinity,
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: Container(
                        width: 150,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                            color: Colors.black.withOpacity(0.8),
                            width: 1,
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            "New Playlist",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    TextFormField(
                      controller: musicPlaylistController.textController,
                      cursorColor: HexColor('#575757'),
                      textAlignVertical: TextAlignVertical.center,
                      onChanged: (value) {
                        musicPlaylistController.onChanged(value);
                      },
                      onTap: () {
                        musicPlaylistController.isKeybordFocus.value = true;
                      },
                      style:
                          TextStyle(color: HexColor('#575757'), fontSize: 12),
                      onTapOutside: (event) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                      decoration: InputDecoration(
                        filled: true,
                        isDense: true,
                        fillColor: HexColor('#f1f1f1'),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 7, horizontal: 7),
                        hintText: 'Find playlist',
                        hintStyle: TextStyle(
                          color: Colors.black.withOpacity(0.8),
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
                          color: Colors.black.withOpacity(1),
                        ),
                        suffixIcon:
                            Obx(() => musicPlaylistController.isTypingValue
                                ? GestureDetector(
                                    onTap: () {
                                      musicPlaylistController.textController
                                          .clear();
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
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        const Text(
                          'Saved in',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'Clear all',
                            style: TextStyle(
                              color: HexColor('#8238be'),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const ListPlaylistContainer(),
                    const SizedBox(
                      height: 10,
                    ),
                    const ListTile(
                      contentPadding:
                          EdgeInsets.zero, // menghilangkan padding kiri kanan
                      leading: Icon(
                        Icons.list,
                        color: Colors.black,
                      ),
                      title: Text(
                        'Recently added',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const ListPlaylistContainer(),
                    const ListPlaylistContainer(),
                    const ListPlaylistContainer(),
                    const ListPlaylistContainer(),
                  ],
                ),
              ),
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 100,
                    height: 50,
                    decoration: BoxDecoration(
                      color: HexColor('#8238be'),
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                        color: HexColor('#8238be'),
                        width: 1,
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        "Done",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  OutlineInputBorder outlineInputBorder() {
    return OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.transparent),
      borderRadius: BorderRadius.circular(5),
    );
  }
}
