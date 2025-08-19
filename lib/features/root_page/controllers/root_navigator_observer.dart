// Bisa ditaruh di file root_page.dart, di luar class RootPage
import 'package:cybeat_music_player/features/root_page/controllers/navigation_history_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import controller yang tadi dibuat

class RootNavigatorObserver extends NavigatorObserver {
  final NavigationHistoryController historyController = Get.find();

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    // Pastikan nama route tidak null sebelum ditambahkan
    if (route.settings.name != null) {
      historyController.addRoute(route.settings.name!);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    historyController.removeLastRoute();
  }
}
