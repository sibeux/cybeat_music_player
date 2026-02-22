import 'package:cached_network_image/cached_network_image.dart';
import 'package:cybeat_music_player/core/models/album.dart';
import 'package:flutter/material.dart';

class HomeListFourCover extends StatelessWidget {
  const HomeListFourCover({
    super.key,
    required this.size,
    required this.type,
    required this.album,
  });

  final double size;
  final String type;
  final Album album;

  @override
  Widget build(BuildContext context) {
    if (album.image['default_cover'] != null) {
      return CoverFullGrid(
        size: size,
        image: album.image['default_cover'].toString(),
      );
    } else {
      if (album.image['total_non_null_cover'].toString() != '4') {
        if (album.image['cover_1'] == null) {
          return CoverFullGrid(size: size, image: '');
        } else {
          final index = album.image['total_non_null_cover'].toString();
          return CoverFullGrid(
            size: size,
            image: album.image['cover_$index'].toString(),
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
                    imageUrl: album.image['cover_${index + 1}'].toString(),
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
      errorWidget: (context, url, error) {
        return Image.asset(
          'assets/images/cybeat_splash.png',
          fit: BoxFit.cover,
          filterQuality: FilterQuality.low,
        );
      },
    );
  }
}
