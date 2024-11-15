import 'package:get/get.dart';

class PlayingStateController extends GetxController {
  var isPlaying = false.obs;

  void play() {
    isPlaying.value = true;
  }

  void pause() {
    isPlaying.value = false;
  }
}
