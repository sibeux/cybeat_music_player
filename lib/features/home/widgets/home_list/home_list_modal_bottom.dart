import 'package:cybeat_music_player/common/utils/toast.dart';
import 'package:cybeat_music_player/features/home/controllers/home_controller.dart';
import 'package:cybeat_music_player/core/models/playlist.dart';
import 'package:cybeat_music_player/features/home/widgets/home_list/home_list_four_cover.dart';
import 'package:cybeat_music_player/features/playlist/edit_playlist/screens/edit_playlist_screen.dart';
import 'package:cybeat_music_player/features/playlist/delete_playlist/widgets/modal_delete_playlist.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:marquee/marquee.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

Future<dynamic> homeListModalBottom(BuildContext context, Playlist playlist) {
  final homeAlbumGridController = Get.find<HomeController>();

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
            margin: const EdgeInsets.only(top: 10, bottom: 20),
            height: 5,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                HomeListFourCover(
                  size: 50,
                  type: playlist.type,
                  playlist: playlist,
                ),
                const SizedBox(width: 10),
                Flexible(
                  fit: FlexFit.tight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 25,
                        child: AutoSizeText(
                          playlist.title,
                          maxLines: 1,
                          minFontSize: 16,
                          maxFontSize: 16,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                          overflowReplacement: Marquee(
                            text: playlist.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            scrollAxis: Axis.horizontal,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            // spacing end of text
                            blankSpace: 30,
                            // second needed before slide again
                            pauseAfterRound: const Duration(seconds: 0),
                            // text gonna slide first time after this second
                            startAfter: const Duration(seconds: 2),
                            decelerationCurve: Curves.easeOut,
                            // speed of slide text
                            velocity: 35,
                            accelerationCurve: Curves.linear,
                          ),
                        ),
                      ),
                      // SizedBox(
                      //   child: Text(
                      //     playlist.title,
                      //     style: const TextStyle(
                      //       overflow: TextOverflow.ellipsis,
                      //       fontSize: 16,
                      //       fontWeight: FontWeight.bold,
                      //     ),
                      //   ),
                      // ),
                      const SizedBox(
                        height: 3,
                      ),
                      Text(
                        playlist.author,
                        style: const TextStyle(
                          overflow: TextOverflow.ellipsis,
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Divider(
            height: 1,
            thickness: 1,
          ),
          // const SizedBox(height: 20),
          // by default, ListTile has a padding of 16
          Column(
            children: [
              ListTileBottomModal(
                title: 'Listen to music ad-free',
                icon: Icons.diamond_outlined,
                changeColor: false,
                onTap: () {
                  showRemoveAlbumToast(
                      'Sorry, this feature is not available yet');
                },
              ),
              ListTileBottomModal(
                title: 'Edit ${playlist.type.toLowerCase()}',
                icon: Icons.edit_outlined,
                changeColor: false,
                onTap: playlist.editable == 'true'
                    ? () {
                        Get.back();
                        Get.to(
                          () => EditPlaylistScreen(
                            uid: playlist.uid,
                            playlistName: playlist.title,
                          ),
                          popGesture: false,
                          fullscreenDialog: true,
                        );
                      }
                    : () {
                        showRemoveAlbumToast(
                            'You have no permission to edit this ${playlist.type.toLowerCase()}');
                      },
              ),
              ListTileBottomModal(
                  title: 'Remove from Your Library',
                  icon: Icons.check_circle_rounded,
                  changeColor: true,
                  onTap: playlist.editable == 'true'
                      ? () {
                          Get.back();
                          showModalDeletePlaylist(
                            context,
                            playlist.title,
                            playlist.uid,
                            playlist.type,
                          );
                        }
                      : () {
                          showRemoveAlbumToast(
                              'You have no permission to delete this ${playlist.type.toLowerCase()}');
                        }),
              ListTileBottomModal(
                  title: 'Download',
                  icon: Icons.downloading_outlined,
                  changeColor: false,
                  onTap: () {
                    showRemoveAlbumToast(
                        'Sorry, this feature is not available yet');
                  }),
              ListTileBottomModal(
                title: playlist.pin == 'false'
                    ? 'Pin ${playlist.type.toLowerCase()}'
                    : 'Unpin ${playlist.type.toLowerCase()}',
                icon: playlist.pin == 'false'
                    ? Icons.push_pin_outlined
                    : Icons.push_pin_rounded,
                changeColor: playlist.pin == 'true' ? true : false,
                onTap: () {
                  Get.back();
                  if (playlist.pin == 'false') {
                    homeAlbumGridController.pinAlbum(playlist.uid);
                    playlist.setPin = 'true';
                  } else {
                    homeAlbumGridController.unpinAlbum(playlist.uid);
                    playlist.setPin = 'false';
                  }
                },
              ),
              ListTileBottomModal(
                title: 'Share',
                icon: Icons.share_outlined,
                changeColor: false,
                onTap: () {
                  showRemoveAlbumToast(
                      'Sorry, this feature is not available yet');
                },
              ),
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
    required this.icon,
    required this.title,
    required this.changeColor,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final bool changeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      minVerticalPadding: 5,
      leading: Icon(
        icon,
        color: changeColor ? HexColor('#ac8bc9') : Colors.black,
      ),
      title: Text(title),
      // trailing: const Icon(Icons.arrow_forward_ios),
      titleTextStyle: const TextStyle(
        color: Colors.black,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
      onTap: onTap,
    );
  }
}
