import 'package:cached_network_image/cached_network_image.dart';
import 'package:cybeat_music_player/controller/music_play/music_state_controller.dart';
import 'package:cybeat_music_player/controller/playlist_play_controller.dart';
import 'package:cybeat_music_player/providers/audio_state.dart';
import 'package:cybeat_music_player/screens/azlistview/music_screen.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:marquee/marquee.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

Future<dynamic> detailMusicModal(
  BuildContext context,
  AudioState audioState,
) {
  final playlistPlayController = Get.find<PlaylistPlayController>();
  final musicStateController = Get.find<MusicStateController>();
  return showMaterialModalBottomSheet(
    context: context,
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
                CachedNetworkImage(
                  imageUrl: musicStateController.cover.value,
                  height: 50,
                  width: 50,
                  maxHeightDiskCache: 200,
                  maxWidthDiskCache: 200,
                  filterQuality: FilterQuality.low,
                  placeholder: (context, url) => Image.asset(
                    'assets/images/placeholder_cover_music.png',
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.low,
                  ),
                  errorWidget: (context, url, error) {
                    return Image.asset(
                      'assets/images/cybeat_splash.png',
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.low,
                    );
                  },
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
                          musicStateController.title.value,
                          maxLines: 1,
                          minFontSize: 16,
                          maxFontSize: 16,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                          overflowReplacement: Marquee(
                            text: musicStateController.title.value,
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
                      const SizedBox(
                        height: 3,
                      ),
                      Text(
                        "${musicStateController.artist.value} • ${musicStateController.album.value}",
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
                title:
                    'Go to ${playlistPlayController.playlistType.value.toLowerCase()}',
                icon: Icons.mode_standby_outlined,
                changeColor: false,
                onTap: () {
                  Get.back();
                  if (playlistPlayController.isAzlistviewScreenActive.value) {
                    Get.back(
                    );
                  } else {
                    Get.back();
                    Get.to(
                      () => AzListMusicScreen(
                        audioState: audioState,
                      ),
                      transition: Transition.downToUp,
                      duration: const Duration(milliseconds: 300),
                      popGesture: false,
                      fullscreenDialog: true,
                      id: 1,
                    );
                  }
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
