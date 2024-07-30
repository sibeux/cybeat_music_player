import 'package:cached_network_image/cached_network_image.dart';
import 'package:cybeat_music_player/controller/music_state_controller.dart';
import 'package:cybeat_music_player/controller/search_album_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';

class SearchAlbumList extends StatelessWidget {
  const SearchAlbumList({super.key});

  @override
  Widget build(BuildContext context) {
    PlaylistPlayController playlistPlayController = Get.find();
    SearchAlbumController searchAlbumController = Get.find();

    return ListView.builder(
      itemCount: searchAlbumController.filteredAlbum.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            margin: const EdgeInsets.only(top: 15, bottom: 3),
            height: 60,
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    // cover image
                    Container(
                      width: 60,
                      height: 60,
                      margin: const EdgeInsets.only(right: 5),
                      child: ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(3)),
                        child: CachedNetworkImage(
                          imageUrl:
                              searchAlbumController.filteredAlbum[index].image,
                          fit: BoxFit.cover,
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
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: double.infinity,
                            height: 30,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              searchAlbumController.filteredAlbum[index].title,
                              style: TextStyle(
                                  fontSize: 14,
                                  color: HexColor(playlistPlayController
                                              .playlistTitleValue ==
                                          searchAlbumController
                                              .filteredAlbum[index].title
                                      ? '#8238be'
                                      : '#313031'),
                                  overflow: TextOverflow.ellipsis,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            height: 20,
                            child: Row(
                              children: [
                                Expanded(
                                    child: Container(
                                  width: 30,
                                  height: 30,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: HexColor('#b4b5b4'),
                                      overflow: TextOverflow.ellipsis,
                                      fontWeight: FontWeight.values[4],
                                    ),
                                    '${searchAlbumController.filteredAlbum[index].type} ● ${searchAlbumController.filteredAlbum[index].author}',
                                  ),
                                )),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
