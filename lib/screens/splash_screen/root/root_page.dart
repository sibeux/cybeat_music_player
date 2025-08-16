import 'package:cybeat_music_player/controller/music_play/playing_state_controller.dart';
import 'package:cybeat_music_player/core/controllers/audio_state_provider.dart';
import 'package:cybeat_music_player/screens/home_screen/home_screen.dart';
import 'package:cybeat_music_player/widgets/floating_playing_music.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    // Handler untuk tombol back fisik,
    // agar tidak close app.
    return PopScope(
      canPop: false, // Mencegah pop default
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          // Cek apakah ada rute yang bisa di-pop di navigator bersarang
          final navigatorState = Get.nestedKey(1)?.currentState;
          if (navigatorState != null && navigatorState.canPop()) {
            // Jika bisa pop, lakukan pop pada navigator bersarang
            navigatorState.pop();
          } else {
            // Jika tidak ada yang bisa di-pop, pop navigator utama
            SystemNavigator.pop();
          }
        } // Jika tidak ada yang bisa di-pop, biarkan sistem menangani back
      },
      child: Stack(
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
                  ? Material(
                      child: FloatingPlayingMusic(
                        audioState: audioState,
                      ),
                    )
                  : const SizedBox(),
            ),
          ),
        ],
      ),
    );
  }
}
