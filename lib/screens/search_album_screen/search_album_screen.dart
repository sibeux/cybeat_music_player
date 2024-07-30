import 'package:audio_service/audio_service.dart';
import 'package:cybeat_music_player/controller/music_state_controller.dart';
import 'package:cybeat_music_player/controller/search_album_controller.dart';
import 'package:cybeat_music_player/providers/audio_state.dart';
import 'package:cybeat_music_player/providers/music_state.dart';
import 'package:cybeat_music_player/screens/search_album_screen/search_album_list.dart';
import 'package:cybeat_music_player/widgets/floating_playing_music.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

class SearchAlbumScreen extends StatelessWidget {
  const SearchAlbumScreen({super.key, required this.audioState});

  final AudioState audioState;

  @override
  Widget build(BuildContext context) {
    SearchAlbumController searchAlbumController =
        Get.put(SearchAlbumController());
    PlayingStateController playingStateController = Get.find();

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
              FocusManager.instance.primaryFocus?.unfocus();
              searchAlbumController.isKeybordFocus.value
                  ? Future.delayed(const Duration(milliseconds: 200), () {
                      Get.back(
                        closeOverlays: true,
                      );
                    })
                  : Get.back(
                      closeOverlays: true,
                    );
            },
          ),
          titleSpacing: 0,
          title: TextFormField(
            controller: searchAlbumController.controller,
            cursorColor: HexColor('#575757'),
            textAlignVertical: TextAlignVertical.center,
            onChanged: (value) {
              searchAlbumController.onChanged(value);
            },
            onTap: () {
              searchAlbumController.isKeybordFocus.value = true;
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
          scrolledUnderElevation: 0,
          elevation: 0,
        ),
        body: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Obx(
                    () => searchAlbumController.isTypingValue
                        ? searchAlbumController.isSearch.value
                            ? searchAlbumController.filteredAlbum.isEmpty
                                ? albumEmpty(
                                    searchAlbumController.textValue.value)
                                : const SearchAlbumList()
                            : searchAlbumController.filteredAlbum.isEmpty
                                ? albumEmpty(
                                    searchAlbumController.textValue.value)
                                : const SearchAlbumList()
                        : initialChild(),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 1),
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 2,
                          offset:
                              const Offset(0, 1), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Divider(
                      color: Colors.grey.withOpacity(0.3),
                      thickness: 2,
                      height: 0,
                    ),
                  ),
                ],
              ),
            ),
            Obx(
              () => playingStateController.isPlaying.value
                  ? StreamBuilder<SequenceState?>(
                      stream: audioState.player.sequenceStateStream,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final currentItem = snapshot.data?.currentSource;
                          context.read<MusicState>().setCurrentMediaItem(
                              currentItem!.tag as MediaItem);

                          return FloatingPlayingMusic(
                            audioState: audioState,
                            currentItem: currentItem,
                          );
                        }
                        return const SizedBox();
                      },
                    )
                  : const SizedBox(),
            ),
          ],
        ));
  }

  Widget albumEmpty(String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Couldn\'t find',
              style: TextStyle(
                color: Colors.black.withOpacity(0.9),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              "\"$value\"",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black.withOpacity(0.9),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              'Try searching again using a different spelling or keyword.',
              style: TextStyle(
                color: Colors.black.withOpacity(0.7),
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget initialChild() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Search your album',
            style: TextStyle(
              color: Colors.black.withOpacity(0.9),
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Find everything you\'ve saved, followed, or created',
            style: TextStyle(
              color: Colors.black.withOpacity(0.7),
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 50),
        ],
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
