import 'package:cached_network_image/cached_network_image.dart';
import 'package:cybeat_music_player/controller/music_state_controller.dart';
import 'package:cybeat_music_player/controller/search_album_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';

class ScaleTapSearchAlbum extends StatefulWidget {
  const ScaleTapSearchAlbum({
    super.key,
    required this.index,
  });

  final int index;

  @override
  ScaleTapSearchAlbumState createState() => ScaleTapSearchAlbumState();
}

class ScaleTapSearchAlbumState extends State<ScaleTapSearchAlbum>
    with SingleTickerProviderStateMixin {
  static const clickAnimationDurationMillis = 100;
  double _scaleTransformValue = 1;

  PlaylistPlayController playlistPlayController = Get.find();
  SearchAlbumController searchAlbumController = Get.find();

  // needed for the "click" tap effect
  late final AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: clickAnimationDurationMillis),
      lowerBound: 0.0,
      upperBound: 0.05,
    )..addListener(() {
        setState(() => _scaleTransformValue = 1 - animationController.value);
      });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  void _shrinkButtonSize() {
    animationController.forward();
  }

  void _restoreButtonSize() {
    Future.delayed(
      const Duration(milliseconds: clickAnimationDurationMillis),
      () => animationController.reverse(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanDown: (details) {
        _shrinkButtonSize();
      },
      onPanCancel: () {
        // ini masih ada gunanya
        _restoreButtonSize();
      },
      onPanEnd: (_) {
        // ini masih ada gunanya
        _restoreButtonSize();
      },
      onTapCancel: _restoreButtonSize, // ini kemungkinan ada sih
      child: Transform.scale(
          scale: _scaleTransformValue,
          child: Container(
            margin: const EdgeInsets.only(bottom: 15),
            child: InkWell(
              // splashcolor adalah saat ditap aja
              splashColor: Colors.transparent,
              // highlightcolor adalah saat ditahan
              highlightColor: Colors.transparent,
              onTap: () {},
              child: SizedBox(
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
                              imageUrl: searchAlbumController
                                  .filteredAlbum[widget.index]!.image,
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
                                  searchAlbumController
                                      .filteredAlbum[widget.index]!.title,
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: HexColor(playlistPlayController
                                                  .playlistTitleValue ==
                                              searchAlbumController
                                                  .filteredAlbum[widget.index]!
                                                  .title
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
                                    if (searchAlbumController
                                            .filteredAlbum[widget.index]!.pin ==
                                        "true")
                                      Icon(
                                        Icons.push_pin,
                                        size: 16,
                                        color: HexColor('#8238be'),
                                      ),
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
                                        '${searchAlbumController.filteredAlbum[widget.index]!.type} ● ${searchAlbumController.filteredAlbum[widget.index]!.author}',
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
            ),
          )),
    );
  }
}
