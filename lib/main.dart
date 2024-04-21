import 'package:cybeat_music_player/providers/audio_state.dart';
import 'package:cybeat_music_player/providers/music_state.dart';
import 'package:cybeat_music_player/providers/playing_state.dart';
import 'package:cybeat_music_player/screens/music_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
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
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        showPerformanceOverlay: false,
        home: MusicScreen(),
      ),
    );
  }
}
