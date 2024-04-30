import 'package:cybeat_music_player/providers/audio_state.dart';
import 'package:cybeat_music_player/providers/music_state.dart';
import 'package:cybeat_music_player/providers/playing_state.dart';
import 'package:cybeat_music_player/screens/music_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  WidgetsFlutterBinding.ensureInitialized();
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
        ChangeNotifierProvider(lazy: false, create: (_) => AudioState()),
        ChangeNotifierProvider(create: (_) => PlayingState()),
        ChangeNotifierProvider(create: (_) => MusicState()),
      ],
      child: MaterialApp(
        title: 'Okejek',
        builder: (context, child){
          // create multiple builders
          child = FToastBuilder()(context, child);
          return child;
        },
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        showPerformanceOverlay: false,
        home: const MusicScreen(),
      ),
    );
  }
}
