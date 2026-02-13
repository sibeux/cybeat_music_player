import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthFormController extends GetxController {
  var isObscure = true.obs;
  var currentType = ''.obs;
  var formData = RxMap(
    {
      'emailLogin': {
        'text': '',
        'type': 'emailLogin',
        'controller': TextEditingController(),
      },
      'passwordLogin': {
        'text': '',
        'type': 'passwordLogin',
        'controller': TextEditingController(),
      }
    },
  );

  bool getIsDataLoginValid() {
    final emailValue = formData['emailLogin']!['text'].toString();
    return EmailValidator.validate(emailValue) &&
        emailValue.isNotEmpty &&
        formData['passwordLogin']!['text'].toString().isNotEmpty;
  }
}
