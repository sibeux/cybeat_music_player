import 'package:cybeat_music_player/core/controllers/music_player_controller.dart';
import 'package:cybeat_music_player/features/album_music/bindings/album_music_binding.dart';
import 'package:cybeat_music_player/common/widgets/floating_bar/floating_playing_music.dart';
import 'package:cybeat_music_player/features/album_music/screens/album_music_screen_search.dart';
import 'package:cybeat_music_player/features/home/bindings/home_binding.dart';
import 'package:cybeat_music_player/features/home/screens/home_screen.dart';
import 'package:cybeat_music_player/features/root_page/widgets/root_navigation_drawer.dart';
import 'package:cybeat_music_player/features/recent_music/screens/recents_music_screen.dart';
import 'package:cybeat_music_player/features/root_page/controllers/navigation_history_controller.dart';
import 'package:cybeat_music_player/features/root_page/controllers/root_navigator_observer.dart';
import 'package:cybeat_music_player/features/search_album/bindings/search_album_binding.dart';
import 'package:cybeat_music_player/features/search_album/screens/search_album_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class RootPage extends StatelessWidget {
  const RootPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final musicPlayerController = Get.find<MusicPlayerController>();

    // Daftarkan controller agar bisa di-find oleh Observer
    final historyController = Get.put(NavigationHistoryController());

    return Scaffold(
      drawerBarrierDismissible: true,
      drawer: RootNavigationDrawer(),
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, result) {
          if (didPop) return;
          // LOGIKA BARU: Cek panjang riwayat, BUKAN canPop()
          // Jika riwayat lebih dari 1, berarti kita bisa kembali.
          if (historyController.routeHistory.length > 1) {
            Get.nestedKey(1)?.currentState?.pop();
          } else {
            // Jika hanya ada 1 (atau 0), kita di halaman home. Minimize aplikasi.
            // MoveToBackground.moveTaskToBack();
            SystemNavigator.pop();
          }
        },
        child: Stack(
          children: [
            Navigator(
              key: Get.nestedKey(1),
              initialRoute: '/home',
              // Tambahkan observer ke navigator
              observers: [RootNavigatorObserver()],
              onGenerateRoute: (settings) {
                return onGenerateNestedRoute(settings);
              },
            ),
            // "CANGKANG" YANG PERSISTEN
            // Floating player Anda akan selalu ada di atas halaman apa pun.
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Obx(
                () => musicPlayerController.isMusicActiveNow.value
                    ? Material(
                        child: FloatingPlayingMusic(),
                      )
                    : const SizedBox(),
              ),
            ),
          ],
        ),
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
        fullscreenDialog: false,
        popGesture: false,
      );
    case '/album_music':
      return GetPageRoute(
        settings: settings,
        page: () => AlbumMusicScreenSearch(),
        binding: AlbumMusicBinding(),
        transition: Transition.leftToRightWithFade,
        transitionDuration: const Duration(milliseconds: 300),
        fullscreenDialog: true,
        popGesture: false,
      );
    case '/recents':
      return GetPageRoute(
        settings: settings,
        page: () => RecentsMusicScreen(),
        transition: Transition.rightToLeftWithFade,
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
