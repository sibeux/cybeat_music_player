// file: navigation_history_controller.dart
import 'package:cybeat_music_player/common/utils/colorize_terminal.dart';
import 'package:get/get.dart';

class NavigationHistoryController extends GetxController {
  // .obs membuat list ini reaktif, walaupun tidak wajib untuk kasus ini
  final routeHistory = <String>[].obs;

  void addRoute(String routeName) {
    routeHistory.add(routeName);
    logInfo('Route Ditambahkan: $routeName | Riwayat: $routeHistory');
  }

  void removeLastRoute() {
    if (routeHistory.isNotEmpty) {
      routeHistory.removeLast();
      logInfo('Route Dihapus | Riwayat: $routeHistory');
    }
  }
}
