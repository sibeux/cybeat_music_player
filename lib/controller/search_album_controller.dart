import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchAlbumController extends GetxController {
  final controller = TextEditingController();
  var isTyping = false.obs;
  var textValue = ''.obs;
  var isKeybordFocus = false.obs;

  void onChanged(String value) {
    isTyping.value = value.isNotEmpty;
    textValue.value = value;
    isKeybordFocus.value = true;
    update();
  }

  get getTextValue => textValue.value;

  get isTypingValue => isTyping.value;
}