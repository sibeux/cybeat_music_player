import 'package:cached_network_image/cached_network_image.dart';
import 'package:cybeat_music_player/models/playlist.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

Future<dynamic> showAlbumModalBottom(BuildContext context, Playlist playlist) {
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
                      imageUrl: playlist.image,
                      fit: BoxFit.cover,
                      width: 50,
                      height: 50,
                      maxHeightDiskCache: 150,
                      maxWidthDiskCache: 150,
                      filterQuality: FilterQuality.low,
                      placeholder: (context, url) => Image.asset(
                        'assets/images/placeholder_cover_music.png',
                        fit: BoxFit.cover,
                      ),
                      errorWidget: (context, url, error) => Image.asset(
                        'assets/images/placeholder_cover_music.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      fit: FlexFit.tight,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            child: Text(
                              playlist.title,
                              style: const TextStyle(
                                overflow: TextOverflow.ellipsis,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 3,
                          ),
                          const Text(
                            'Nasrul Wahabi',
                            style: TextStyle(
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
                  const ListTileBottomModal(
                    title: 'Listen to music ad-free',
                    icon: Icons.diamond_outlined,
                    changeColor: false,
                  ),
                  const ListTileBottomModal(
                    title: 'Remove from Your Library',
                    icon: Icons.check_circle_rounded,
                    changeColor: true,
                  ),
                  const ListTileBottomModal(
                    title: 'Download',
                    icon: Icons.downloading_outlined,
                    changeColor: false,
                  ),
                  ListTileBottomModal(
                    title: playlist.pin == 'false'
                        ? 'Pin album'
                        : 'Unpin album',
                    icon: playlist.pin == 'false'
                        ? Icons.push_pin_outlined
                        : Icons.push_pin_rounded,
                    changeColor: playlist.pin == 'true' ? true : false,
                  ),
                  const ListTileBottomModal(
                    title: 'Share',
                    icon: Icons.share_outlined,
                    changeColor: false,
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
  });

  final IconData icon;
  final String title;
  final bool changeColor;

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
      onTap: () {},
    );
  }
}