import 'package:cybeat_music_player/core/controllers/music_player_controller.dart';
import 'package:cybeat_music_player/features/home/bindings/home_binding.dart';
import 'package:cybeat_music_player/features/home/screens/home_screen.dart';
import 'package:cybeat_music_player/features/floating_bar/widgets/floating_playing_music.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';

class RootPageScreen extends StatelessWidget {
  const RootPageScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Menghilangkan splash screen
    FlutterNativeSplash.remove();
    final musicPlayerController = Get.find<MusicPlayerController>();
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
              return GetPageRoute(
                settings: settings,
                page: () => HomeScreen(),
                binding: HomeBinding(),
              );
            },
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Obx(
              () => musicPlayerController.isPlayingNow.value
                  ? Material(
                      child: FloatingPlayingMusic(),
                    )
                  : const SizedBox(),
            ),
          ),
        ],
      ),
    );
  }
}
