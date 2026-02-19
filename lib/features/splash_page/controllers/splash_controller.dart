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
      if (_authService.isAuthenticated) {
        logSuccess('Current JWT Access token is valid. User is authenticated.');
      } else {
        logWarning('Access token expired. Attempting to refresh...');
        await _authService.refreshJwtToken();
      }
    } catch (e) {
      // Log error but continue to navigate to root
      logError('Error during JWT check: $e');
    } finally {
      // * FIX [CYBEAT-ERR-001]: Use microtask to prevent "setState() called during build" error
      Future.microtask(() {
        Get.offAndToNamed('/home', id: 1);
        // Force delete SplashController as automatic disposal in nested nav can be unreliable
        Get.delete<SplashController>();
        isLoading.value = false;
      });
    }
  }
}
