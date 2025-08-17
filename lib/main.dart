import 'dart:async';
import 'dart:ui';

import 'package:cybeat_music_player/core/controllers/music_player_controller.dart';
import 'package:cybeat_music_player/core/services/album_service.dart';
import 'package:cybeat_music_player/features/detail_music/bindings/detail_music_binding.dart';
import 'package:cybeat_music_player/features/detail_music/screens/detail_music_screen.dart';
import 'package:cybeat_music_player/features/playlist/add_music_to_playlist/bindings/add_music_to_playlist_binding.dart';
import 'package:cybeat_music_player/features/playlist/add_music_to_playlist/screens/add_music_to_playlist_screen.dart';
import 'package:cybeat_music_player/features/playlist/edit_playlist/bindings/edit_playlist_binding.dart';
import 'package:cybeat_music_player/features/playlist/edit_playlist/screens/edit_playlist_screen.dart';
import 'package:cybeat_music_player/features/playlist/new_playlist/bindings/new_playlist_binding.dart';
import 'package:cybeat_music_player/features/playlist/new_playlist/screens/new_playlist_screen.dart';
import 'package:cybeat_music_player/firebase_options.dart';
import 'package:cybeat_music_player/core/controllers/audio_state_controller.dart';
import 'package:cybeat_music_player/features/root_page/root_page.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cybeat_music_player/core/controllers/music_download_controller.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  // 1. Pastikan semua binding framework siap
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // 2. Inisialisasi Firebase
  await Firebase.initializeApp(
    // Untuk mendapatkan firebase options, jalankan perintah:
    // flutterfire configure
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 3. Atur handler error
  // Menangkap error dari Flutter framework (error saat build widget, dll.)
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
  };

  // Menangkap error yang tidak ditangani oleh Flutter (error async, di luar build method)
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true; // Menandakan bahwa error sudah ditangani
  };

  // TAMBAHKAN INI untuk memaksa pengiriman data di mode debug
  if (kDebugMode) {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  }

  // Tampilkan splash screen sampai app siap
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Inisialisasi Just Audio Background
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
    androidNotificationIcon: 'mipmap/ic_launcher',
    androidShowNotificationBadge: true,
  );

  // Konfigurasi Status Bar dan Navigation Bar
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.white,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  // Aplikasi hanya berjalan dalam mode portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(MyApp());
}

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Gunakan Get.put() untuk controller yang harus langsung ada
    // dan hidup selamanya selama aplikasi berjalan.
    // Daftarkan service sebagai singleton
    Get.put(AlbumService());

    /// Service seperti PlaylistService sering disebut sebagai 'singleton'.
    /// Artinya, hanya ada satu instance dari service tersebut yang hidup selama aplikasi berjalan.
    /// - Sumber Kebenaran Tunggal (Single Source of Truth)
    /// - Siklus Hidup (Lifecycle) yang Panjang
    /// - Efisiensi
    ///
    // Anda bisa mendaftarkan semua service/controller global di sini
    Get.put(MusicPlayerController());
    Get.put(AudioStateController());
    Get.put(MusicDownloadController());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(393, 804), // ukuran HP kamu
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return RefreshConfiguration(
          footerTriggerDistance: 15.h,
          headerTriggerDistance: 50.h,
          dragSpeedRatio: 0.91,
          headerBuilder: () => const MaterialClassicHeader(),
          footerBuilder: () => const ClassicFooter(),
          enableLoadingWhenNoData: false,
          enableRefreshVibrate: false,
          enableLoadMoreVibrate: false,
          shouldFooterFollowWhenNotFull: (state) {
            // If you want load more with noMoreData state ,may be you should return false
            return false;
          },
          child: GetMaterialApp(
            title: 'Okejek',
            builder: (context, child) {
              // create multiple builders
              child = FToastBuilder()(context, child);
              return child;
            },
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            showPerformanceOverlay: false,
            initialRoute: '/',
            initialBinding: InitialBinding(),
            getPages: [
              // Rute utama aplikasi sekarang adalah RootPage
              GetPage(
                name: '/',
                page: () => RootPage(),
              ),
              // Halaman yang butuh layar penuh (tanpa floating button player)
              // tetap berada di sini. Contoh: Halaman detail lagu, new playlist, dll.
              GetPage(
                name: '/detail',
                page: () => DetailMusicScreen(),
                binding: DetailMusicBinding(),
                transition: Transition.downToUp,
                transitionDuration: const Duration(milliseconds: 300),
                popGesture: false,
                fullscreenDialog: true,
              ),
              GetPage(
                name: '/add_music_to_playlist',
                page: () => AddMusicToPlaylistScreen(),
                transition: Transition.downToUp,
                binding: AddMusicToPlaylistBinding(),
                fullscreenDialog: true,
                popGesture: false,
              ),
              GetPage(
                name: '/new_playlist',
                page: () => NewPlaylistScreen(),
                binding: NewPlaylistBinding(),
                transition: Transition.downToUp,
                fullscreenDialog: true,
                popGesture: false,
              ),
              GetPage(
                name: '/edit_playlist',
                page: () => EditPlaylistScreen(),
                binding: EditPlaylistBinding(),
                transition: Transition.downToUp,
                fullscreenDialog: true,
                popGesture: false,
              ),
            ],
          ),
        );
      },
    );
  }
}
