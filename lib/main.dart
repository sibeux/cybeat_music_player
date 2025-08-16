import 'dart:async';
import 'dart:ui';

import 'package:cybeat_music_player/features/home/controllers/home_filter_album_controller.dart';
import 'package:cybeat_music_player/features/home/controllers/home_controller.dart';
import 'package:cybeat_music_player/controller/music_play/music_state_controller.dart';
import 'package:cybeat_music_player/core/controllers/music_player_controller.dart';
import 'package:cybeat_music_player/features/detail_music/bindings/detail_music_binding.dart';
import 'package:cybeat_music_player/features/detail_music/screens/detail_music_screen.dart';
import 'package:cybeat_music_player/features/root_page/controllers/root_page_controller.dart';
import 'package:cybeat_music_player/firebase_options.dart';
import 'package:cybeat_music_player/core/controllers/audio_state_controller.dart';
import 'package:cybeat_music_player/core/controllers/music_state_provider.dart';
import 'package:cybeat_music_player/features/home/screens/home_screen.dart';
import 'package:cybeat_music_player/features/root_page/screens/root_page_screen.dart';
import 'package:cybeat_music_player/screens/recents_screen/recents_screen.dart';
import 'package:cybeat_music_player/screens/splash_screen/splash_home_screen.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cybeat_music_player/controller/music_download_controller.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:cybeat_music_player/controller/playlist_play_controller.dart';
import 'package:cybeat_music_player/controller/music_play/read_codec_controller.dart';
import 'package:provider/provider.dart';
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

  // Inisiasi controller
  // Harus dipanggil sebelum splash hilang karena di home screen dipakai.
  Get.put(MusicStateController());
  Get.put(PlaylistPlayController());
  Get.put(MusicDownloadController());
  Get.put(ReadCodecController());

  runApp(MyApp());
}

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Gunakan Get.put() untuk controller yang harus langsung ada
    // dan hidup selamanya selama aplikasi berjalan.
    // Anda bisa mendaftarkan semua service/controller global di sini
    // Get.put(AuthService());
    // Get.put(ApiService());
    Get.put(AudioStateController());
    Get.put(MusicPlayerController());
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
              GetPage(
                name: '/',
                page: () => RootPageScreen(),
              ),
              GetPage(
                name: '/home',
                page: () => HomeScreen(),
              ),
              GetPage(
                name: '/detail',
                page: () {
                  return DetailMusicScreen(
                      player: player, audioState: audioState);
                },
                binding: DetailMusicBinding(),
              ),
              GetPage(
                name: '/recents',
                page: () => RecentsScreen(audioState: audioState),
              ),
              // GetPage(
              //   name: '/cybeat/category/:id',
              //   page: () => SplashLinkMusicScreen(
              //       path: 'category', uid: Get.parameters['id'] ?? ''),
              // ),
              // GetPage(
              //   name: '/cybeat/album/:id',
              //   page: () => SplashLinkMusicScreen(
              //       path: 'album', uid: Get.parameters['id'] ?? ''),
              // ),
            ],
          ),
        );
      },
    );
  }
}
