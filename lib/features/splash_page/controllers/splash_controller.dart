import 'package:cybeat_music_player/common/utils/colorize_terminal.dart';
import 'package:cybeat_music_player/core/services/auth_service.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    checkAuthentication();
  }

  Future<void> checkAuthentication() async {
    logInfo('Checking JWT token for authentication...');
    try {
      await _authService.checkJwtToken();
    } catch (e) {
      // Log error but continue to navigate to root
      logError('Error during JWT check: $e');
    } finally {
      isLoading.value = false;
      Get.offAllNamed('/home', id: 1);
    }
  }
}
