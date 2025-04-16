import 'package:cybeat_music_player/controller/music_play/playing_state_controller.dart';
import 'package:cybeat_music_player/providers/audio_state.dart';
import 'package:cybeat_music_player/screens/home_screen/home_screen.dart';
import 'package:cybeat_music_player/widgets/floating_playing_music.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RootPage extends StatelessWidget {
  const RootPage({
    super.key,
    required this.audioState,
  });

  final AudioState audioState;

  @override
  Widget build(BuildContext context) {
    final playingStateController = Get.put(PlayingStateController());
    return Stack(
      children: [
        Navigator(
          key: Get.nestedKey(1),
          onGenerateRoute: (settings) {
            return MaterialPageRoute(
              builder: (_) => HomeScreen(audioState: audioState),
            );
          },
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Obx(
            () => playingStateController.isPlaying.value
                // pakai {Material} agar tidak ada-
                // yellow underline di text {FloatingPlayingMusic}.
                ? Material(
                    child: FloatingPlayingMusic(
                      audioState: audioState,
                    ),
                  )
                : const SizedBox(),
          ),
        ),
      ],
    );
  }
}
