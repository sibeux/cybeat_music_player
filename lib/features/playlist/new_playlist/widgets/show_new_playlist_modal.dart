import 'package:cybeat_music_player/features/playlist/new_playlist/screens/new_playlist_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

Future<dynamic> showNewPlaylistModal(BuildContext context) {
  return showMaterialModalBottomSheet(
    context: context,
    // Pakai {useRootNavigator: true} agar modal bottom sheet tidak terhalangi-
    // oleh FloatingPlayingMusic dari root_page.dart
    useRootNavigator: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(20),
      ),
    ),
    clipBehavior: Clip.antiAliasWithSaveLayer,
    builder: (context) => Container(
      color: Colors.white,
      child: Column(
        // mainAxisSize: MainAxisSize.min - mencegah layar full
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 15, bottom: 10),
            height: 5,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 10),
          // const SizedBox(height: 20),
          // by default, ListTile has a padding of 16
          const Column(
            children: [
              ListTileBottomModal(
                title: 'Playlist',
              ),
              SizedBox(height: 20),
            ],
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
      leading: const Icon(
        Icons.my_library_music_outlined,
        color: Colors.black,
      ),
      title: Text(title),
      subtitle: const Text(
        "Build a playlist with songs",
        style: TextStyle(fontSize: 12),
      ),
      titleTextStyle: const TextStyle(
        color: Colors.black,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
      onTap: () {
        Get.back();
        Get.to(
          () => const NewPlaylistScreen(),
          popGesture: false,
          fullscreenDialog: true,
        );
      },
    );
  }
}
