import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MusicPlaylistController extends GetxController{
  var isTyping = false.obs;
  var textController = TextEditingController();
  var isKeybordFocus = false.obs;
  var textValue = ''.obs;

  void onChanged(String value) {
    isTyping.value = value.isNotEmpty;
    textValue.value = value;
    isKeybordFocus.value = true;
    update();
  }

  bool get isTypingValue => isTyping.value;
}