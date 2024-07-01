import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class GeneralSplashScreen extends StatelessWidget {
  const GeneralSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor('#282d46'),
      body: Center(
        child: Image.asset('assets/images/cybeat_splash.png'),
      ),
    );
  }
}