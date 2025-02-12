import 'package:cybeat_music_player/controller/home_album_grid_controller.dart';
import 'package:cybeat_music_player/controller/music_playlist_controller.dart';
import 'package:cybeat_music_player/screens/home_screen/list_album/four_cover_album.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';

class ListPlaylistContainer extends StatelessWidget {
  const ListPlaylistContainer({
    super.key,
    required this.index,
    required this.listPlaylist,
  });

  final int index;
  final List listPlaylist;

  @override
  Widget build(BuildContext context) {
    Get.find<HomeAlbumGridController>();
    final musicPlaylistController = Get.find<MusicPlaylistController>();
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: HexColor('#f1f1f1'),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Center(
              child: FourCoverAlbum(
                size: 100,
                type: 'playlist',
                playlist: listPlaylist[index],
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                listPlaylist[index].title,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black.withOpacity(0.8),
                  overflow: TextOverflow.ellipsis,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Row(
                children: [
                  listPlaylist[index].pin ==
                          'true'
                      ? Icon(
                          Icons.push_pin,
                          size: 16,
                          color: HexColor('#8238be'),
                        )
                      : Container(),
                  Text(
                    listPlaylist[index].author,
                    maxLines: 1,
                    style: TextStyle(
                      color: HexColor('#313031'),
                      overflow: TextOverflow.ellipsis,
                      fontSize: 12,
                    ),
                  ),
                ],
              )
            ],
          ),
          const Spacer(),
          Obx(
            () => IconButton(
              onPressed: () {
                if (musicPlaylistController.newAddedMusic.contains(
                  listPlaylist[index].uid,
                )) {
                  musicPlaylistController.tapRemoveMusicFromPlaylist(
                    listPlaylist[index].uid,
                  );
                } else {
                  musicPlaylistController.tapAddMusicToPlaylist(
                    listPlaylist[index].uid,
                  );
                }
              },
              icon: musicPlaylistController.newAddedMusic.contains(
                listPlaylist[index].uid,
              )
                  ? Icon(
                      Icons.check_circle,
                      color: HexColor('#8238be'),
                    )
                  : Icon(
                      Icons.circle_outlined,
                      color: Colors.black.withOpacity(0.8),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
