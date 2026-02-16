import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hexcolor/hexcolor.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Membuat status bar menjadi transparan agar warna background terlihat penuh
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Untuk Android
      statusBarIconBrightness: Brightness.light, // Ikon putih (karena bg gelap)
    ));
    // Remove the native splash screen
    FlutterNativeSplash.remove();
    return Scaffold(
      // Properti ini opsional jika tidak pakai AppBar,
      // tapi berguna untuk memastikan konten benar-benar full.
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: HexColor("#282d46"),
      body: Center(
        child: Image.asset(
          'assets/images/cybeat_splash.png',
          width: 150.w,
          height: 150.h,
        ),
      ),
    );
  }
}
