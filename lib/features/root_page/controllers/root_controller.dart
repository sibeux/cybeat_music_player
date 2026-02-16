import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RootController extends GetxController {
  void clickLogin(BuildContext context) async {
    Navigator.of(context).pop();
    await Future.delayed(const Duration(milliseconds: 200));
    Get.toNamed("/email_check");
  }
}
