import 'package:audio_service/audio_service.dart';
import 'package:cybeat_music_player/controller/home_album_grid_controller.dart';
import 'package:cybeat_music_player/screens/azlistview/effect_tap_music_modal.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

Future<dynamic> showMusicModalBottom(
    BuildContext context, MediaItem mediaItem, AudioPlayer audioPlayer) {
  Get.put(HomeAlbumGridController());

  return showMaterialModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    clipBehavior: Clip.antiAliasWithSaveLayer,
    builder: (context) => Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(
          Radius.circular(20),
        ),
      ),
      margin: const EdgeInsets.all(12),
      child: Column(
        // mainAxisSize: MainAxisSize.min - mencegah layar full
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              mediaItem.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(height: 10),
          // by default, ListTile has a padding of 16
          const Column(
            children: [
              EffectTapMusicModal(
                  child: ListTileBottomModal(title: 'Play now')),
              EffectTapMusicModal(
                  child: ListTileBottomModal(title: 'Add to playlist')),
              EffectTapMusicModal(child: ListTileBottomModal(title: 'Delete')),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    ),
  );
}

class ListTileBottomModal extends StatelessWidget {
  const ListTileBottomModal({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      minVerticalPadding: 5,
      title: Text(title),
      titleTextStyle: const TextStyle(
        color: Colors.black,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
      onTap: () {
        switch (title.toLowerCase()) {
          case 'play now':
          // play music
          case 'add to playlist':
          // add music to playlist
          case 'delete':
          // delete music
        }
        Get.back();
      },
    );
  }
}
