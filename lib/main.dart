import 'package:cybeat_music_player/providers/audio_state.dart';
import 'package:cybeat_music_player/providers/music_state.dart';
import 'package:cybeat_music_player/screens/splash_screen/splash_link_music_screen.dart';
import 'package:cybeat_music_player/screens/splash_screen/splash_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
    androidNotificationIcon: 'mipmap/ic_launcher',
    androidShowNotificationBadge: true,
  );

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.white,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  // WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((fn) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(lazy: true, create: (_) => AudioState()),
        ChangeNotifierProvider(create: (_) => MusicState()),
        // ChangeNotifierProvider(create: (_) => PlaylistState()),
      ],
      child: RefreshConfiguration(
        footerTriggerDistance: 15,
        headerTriggerDistance: 50,
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
          getPages: [
            GetPage(
              name: '/',
              page: () => const SplashHomeScreen(
                path: '/',
              ),
            ),
            GetPage(
              name: '/cybeat/category/:id',
              page: () => SplashLinkMusicScreen(
                  path: 'category', uid: Get.parameters['id'] ?? ''),
            ),
            GetPage(
              name: '/cybeat/album/:id',
              page: () => SplashLinkMusicScreen(
                  path: 'album', uid: Get.parameters['id'] ?? ''),
            ),
          ],
        ),
      ),
    );
  }
}
