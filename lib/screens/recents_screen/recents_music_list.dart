import 'package:cached_network_image/cached_network_image.dart';
import 'package:cybeat_music_player/models/music.dart';
import 'package:cybeat_music_player/components/capitalize.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class RecentMusicList extends StatelessWidget {
  const RecentMusicList({
    super.key,
    required this.index,
    required this.music,
  });

  final Music music;
  final int index;

  @override
  Widget build(BuildContext context) {
    String colorTitle = "#313031";
    double marginList = 18;

    Widget indexIcon = Text(
      (index + 1).toString().padLeft(2, '0'),
      style: TextStyle(
          fontSize: 12,
          color: HexColor('#8d8c8c'),
          fontWeight: FontWeight.bold),
    );

    return SizedBox(
      height: 70,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                margin: EdgeInsets.only(
                  left: marginList,
                ),
                child: indexIcon,
              ),
              // cover image
              SizedBox(
                width: 40,
                height: 40,
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                  child: CachedNetworkImage(
                    imageUrl: music.cover.toString(),
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
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 250,
                      height: 30,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        capitalizeEachWord(music.title),
                        style: TextStyle(
                            fontSize: 16,
                            color: HexColor(colorTitle),
                            overflow: TextOverflow.ellipsis,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    SizedBox(
                      width: 250,
                      height: 20,
                      child: Row(
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            width: 10,
                            height: 30,
                            child: Icon(
                              Icons.audiotrack_outlined,
                              color: HexColor('#b4b5b4'),
                              size: 15,
                            ),
                          ),
                          const SizedBox(
                            width: 7,
                          ),
                          Expanded(
                              child: Container(
                            width: 30,
                            height: 30,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              style: TextStyle(
                                fontSize: 13,
                                color: HexColor('#b4b5b4'),
                                overflow: TextOverflow.ellipsis,
                                fontWeight: FontWeight.values[4],
                              ),
                              '${capitalizeEachWord(music.artist)} | ${capitalizeEachWord(music.album)}',
                            ),
                          )),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(
                width: 10,
              )
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            margin: const EdgeInsets.only(left: 18, right: 10),
            width: double.infinity,
            height: 1,
            color: HexColor('#e0e0e0').withValues(alpha: 0.7),
          ),
        ],
      ),
    );
  }
}
