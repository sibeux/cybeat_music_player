import 'package:cybeat_music_player/controller/music_state_controller.dart';
import 'package:cybeat_music_player/models/playlist.dart';
import 'package:cybeat_music_player/providers/audio_state.dart';
import 'package:cybeat_music_player/providers/music_state.dart';
import 'package:cybeat_music_player/screens/azlistview/music_screen.dart';
import 'package:cybeat_music_player/screens/home_screen/list_album/grid_playlist_album.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';

class ScaleTapSearchAlbum extends StatefulWidget {
  const ScaleTapSearchAlbum({
    super.key,
    required this.audioState,
    required this.playlist,
  });

  final Playlist playlist;
  final AudioState audioState;

  @override
  ScaleTapSearchAlbumState createState() => ScaleTapSearchAlbumState();
}

class ScaleTapSearchAlbumState extends State<ScaleTapSearchAlbum>
    with SingleTickerProviderStateMixin {
  static const clickAnimationDurationMillis = 100;
  double _scaleTransformValue = 1;

  PlaylistPlayController playlistPlayController = Get.find();
  PlayingStateController playingStateController = Get.find();

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
    final audioState = widget.audioState;
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
              onTap: () {
                // untuk menghilangkan keyboard
                FocusManager.instance.primaryFocus?.unfocus();

                if (playlistPlayController.playlistUidValue !=
                        widget.playlist.uid ||
                    playlistPlayController.playlistUidValue == "") {
                  audioState.clear();
                  playingStateController.pause();
                  context.read<MusicState>().clear();
                  audioState.init(widget.playlist);
                  playlistPlayController.onPlaylist(widget.playlist);
                }

                Get.to(
                  () => AzListMusicScreen(
                    audioState: audioState,
                  ),
                  transition: Transition.leftToRightWithFade,
                  duration: const Duration(milliseconds: 300),
                );
              },
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
                            child:
                                FourCoverAlbum(
                                    size: 60,
                                    type: widget.playlist.type, playlist: widget.playlist,
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
                                child: Obx(() => Text(
                                      widget.playlist.title,
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: HexColor(playlistPlayController
                                                      .playlistTitleValue ==
                                                  widget.playlist.title
                                              ? '#8238be'
                                              : '#313031'),
                                          overflow: TextOverflow.ellipsis,
                                          fontWeight: FontWeight.w500),
                                    )),
                              ),
                              SizedBox(
                                width: double.infinity,
                                height: 20,
                                child: Row(
                                  children: [
                                    if (widget.playlist.pin == "true")
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
                                        '${widget.playlist.type} • ${widget.playlist.author}',
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