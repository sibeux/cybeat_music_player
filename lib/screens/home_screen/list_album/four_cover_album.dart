import 'package:cached_network_image/cached_network_image.dart';
import 'package:cybeat_music_player/controller/home_album_grid_controller.dart';
import 'package:cybeat_music_player/models/playlist.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FourCoverAlbum extends StatelessWidget {
  const FourCoverAlbum({
    super.key,
    required this.size,
    required this.type,
    required this.playlist,
  });

  final double size;
  final String type;
  final Playlist playlist;

  @override
  Widget build(BuildContext context) {
    final homeAlbumGridController = Get.put(HomeAlbumGridController());

    List listCover(String uid, String type) {
      final List<dynamic> list = type.toLowerCase() == 'playlist'
          ? homeAlbumGridController.fourCoverPlaylist
          : homeAlbumGridController.fourCoverCategory;

      final data = list
          .where((element) => element['playlist_uid'] == uid)
          .map((e) => {
                'cover_1': e['cover_1'],
                'cover_2': e['cover_2'],
                'cover_3': e['cover_3'],
                'cover_4': e['cover_4'],
                'total_non_null_cover': e['total_non_null_cover']
              })
          .toList();

      /***
       * awalnya return langsung di atas, tapi karena ada error,
       * akhirnya dipisah. belum tau kenapa errornya
       */
      return data;
    }

    if (playlist.image != "") {
      return CoverFullGrid(size: size, image: playlist.image);
    } else {
      if (listCover(playlist.uid, playlist.type)[0]['total_non_null_cover'] !=
          '4') {
        if (listCover(playlist.uid, playlist.type)[0]['cover_1'] == null) {
          return CoverFullGrid(size: size, image: '');
        } else {
          final index =
              listCover(playlist.uid, playlist.type)[0]['total_non_null_cover'];
          return CoverFullGrid(
            size: size,
            image: listCover(playlist.uid, playlist.type)[0]['cover_$index'],
          );
        }
      } else {
        return SizedBox(
          height: size,
          width: size,
          child: CustomScrollView(
            physics: const NeverScrollableScrollPhysics(),
            slivers: [
              SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1, // Atur rasio item grid sesuai
                ),
                delegate: SliverChildBuilderDelegate(
                  childCount: 4,
                  (context, index) => CachedNetworkImage(
                    imageUrl: listCover(playlist.uid, playlist.type)[0]
                        ['cover_${index + 1}'],
                    fit: BoxFit.cover,
                    maxHeightDiskCache: 150,
                    maxWidthDiskCache: 150,
                    filterQuality: FilterQuality.low,
                    placeholder: (context, url) => Image.asset(
                      'assets/images/placeholder_cover_music.png',
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.low,
                    ),
                    errorWidget: (context, url, error) => Image.asset(
                      'assets/images/cybeat_splash.png',
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.low,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    }
  }
}

class CoverFullGrid extends StatelessWidget {
  const CoverFullGrid({
    super.key,
    required this.image,
    required this.size,
  });

  final String image;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: image,
      fit: BoxFit.cover,
      height: size,
      width: size,
      maxHeightDiskCache: 200,
      maxWidthDiskCache: 200,
      filterQuality: FilterQuality.low,
      placeholder: (context, url) => Image.asset(
        'assets/images/placeholder_cover_music.png',
        fit: BoxFit.cover,
        filterQuality: FilterQuality.low,
      ),
      errorWidget: (context, url, error) => Image.asset(
        'assets/images/cybeat_splash.png',
        fit: BoxFit.cover,
        filterQuality: FilterQuality.low,
      ),
    );
  }
}
