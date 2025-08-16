import 'package:cybeat_music_player/features/playlist/add_music_to_playlist/controllers/add_music_to_playlist_controller.dart';
import 'package:cybeat_music_player/core/controllers/audio_state_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';

class ButtonDone extends StatelessWidget {
  const ButtonDone({
    super.key,
    required this.musicPlaylistController,
    required this.idMusic,
  });

  final AddMusicToPlaylistController musicPlaylistController;
  final String idMusic;

  @override
  Widget build(BuildContext context) {
    final audioState = Get.find<AudioStateController>();
    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: Center(
        child: GestureDetector(
          onTap: () {
            musicPlaylistController.updateMusicOnPlaylist(
              idMusic: idMusic,
              audioState: audioState,
            );
          },
          child: Container(
            width: 100,
            height: 50,
            decoration: BoxDecoration(
              color: HexColor('#8238be'),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                color: HexColor('#8238be'),
                width: 1,
              ),
            ),
            child: Obx(
              () => Center(
                child:
                    musicPlaylistController.isLoadingUpdateMusicOnPlaylist.value
                        ? const SizedBox(
                            width: 30,
                            height: 30,
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            "Done",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
