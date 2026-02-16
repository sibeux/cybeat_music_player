import 'package:cybeat_music_player/common/utils/color_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hexcolor/hexcolor.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Remove the native splash screen
    FlutterNativeSplash.remove();
    return Scaffold(
      backgroundColor: HexColor("#282d46"),
      body: Center(
        child: Image.asset(
          'assets/images/cybeat_splash.png',
          width: 150,
          height: 150,
        ),
      ),
    );
  }
}
