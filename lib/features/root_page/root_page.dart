import 'package:cybeat_music_player/core/controllers/music_player_controller.dart';
import 'package:cybeat_music_player/features/album_music/screens/album_music_screen.dart';
import 'package:cybeat_music_player/common/widgets/floating_bar/floating_playing_music.dart';
import 'package:cybeat_music_player/features/home/bindings/home_binding.dart';
import 'package:cybeat_music_player/features/home/screens/home_screen.dart';
import 'package:cybeat_music_player/features/recent_music/screens/recents_music_screen.dart';
import 'package:cybeat_music_player/features/search_album/bindings/search_album_binding.dart';
import 'package:cybeat_music_player/features/search_album/screens/search_album_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';

class RootPage extends StatelessWidget {
  const RootPage({
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
          // BAGIAN 1: "ISI" YANG BERUBAH-UBAH
          Navigator(
            // ID ini PENTING untuk memberi tahu GetX navigator mana yang harus digunakan
            key: Get.nestedKey(1),
            initialRoute: '/home', // Rute awal untuk navigator nested ini
            onGenerateRoute: (settings) {
              // Logika untuk menentukan halaman mana yang akan ditampilkan.
              // Bisa dibilang, ini adalah anak route dari navigator bersarang.
              return onGenerateNestedRoute(settings);
            },
          ),
          // BAGIAN 2: "CANGKANG" YANG PERSISTEN
          // Floating player Anda akan selalu ada di atas halaman apa pun.
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

// Ini adalah anak route dari screen/navigator rootpage.
Route<dynamic>? onGenerateNestedRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/home':
      return GetPageRoute(
        settings: settings,
        page: () => HomeScreen(),
        binding: HomeBinding(),
        fullscreenDialog: true,
        popGesture: false,
      );
    case '/album_music':
      return GetPageRoute(
        settings: settings,
        page: () => AlbumMusicScreen(),
        transition: Transition.leftToRightWithFade,
        transitionDuration: const Duration(milliseconds: 300),
        fullscreenDialog: true,
        popGesture: false,
      );
    case '/recents':
      return GetPageRoute(
        settings: settings,
        page: () => RecentsMusicScreen(),
        transition: Transition.native,
        transitionDuration: const Duration(milliseconds: 300),
        fullscreenDialog: true,
        popGesture: false,
      );
    case '/search_album':
      return GetPageRoute(
        settings: settings,
        page: () => SearchAlbumScreen(),
        binding: SearchAlbumBinding(),
        transition: Transition.cupertino,
        fullscreenDialog: true,
        popGesture: false,
      );
    default:
      // Halaman default jika rute tidak ditemukan
      return GetPageRoute(
          page: () => const Center(child: Text("Page not found")));
  }
}

