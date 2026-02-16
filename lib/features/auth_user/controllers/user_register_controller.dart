import 'dart:async';

import 'package:cybeat_music_player/common/utils/colorize_terminal.dart';
import 'package:cybeat_music_player/common/utils/toast.dart';
import 'package:cybeat_music_player/features/auth_user/interfaces/auth_form_controller_contract.dart';
import 'package:cybeat_music_player/features/auth_user/repositories/register_repository.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserRegisterController extends AuthFormControllerContract {
  final RegisterRepository _authRepo = RegisterRepository();

  var isLoading = false.obs;
  var isEmailRegistered = false.obs;
  var isRedirecting = false.obs;
  var isObscure = true.obs;

  final _currentType = ''.obs;

  final _formData = RxMap<String, Object?>(
    // Pakai Object? untuk memungkinkan assign dynamic value + tidak terjadi error.
    {
      'emailRegister': {
        'text': '',
        'type': 'emailRegister',
        'controller': TextEditingController(),
      },
      'nameRegister': {
        'text': '',
        'type': 'nameRegister',
        'controller': TextEditingController(),
      },
      'passwordRegister': {
        'text': '',
        'type': 'passwordRegister',
        'controller': TextEditingController(),
      },
    },
  );

  @override
  void onInit() {
    super.onInit();
    isLoading.value = false;
    isEmailRegistered.value = false;
    isRedirecting.value = false;
  }

  @override
  RxString get currentType => _currentType;

  @override
  RxMap get formData => _formData;

  @override
  bool get isObscureValue => isObscure.value;

  @override
  void onClearController(String type) {
    final currentController =
        formData[type]?['controller'] as TextEditingController;
    currentController.clear();
    formData[type] = {
      'text': '',
      'type': type,
      'controller': currentController,
    };
    update();
  }

  @override
  void onChanged(String value, String type) {
    final currentController = formData[type]?['controller'];
    // Memperbarui referensi map
    formData[type] = {
      'text': value,
      'type': type,
      'controller': currentController!,
    };
    update();
  }

  @override
  void onTap(String type, bool isFocus) {
    final currentController = formData[type]?['controller'];
    final currentText = formData[type]?['text'];
    formData[type] = {
      'text': currentText!,
      'type': type,
      'controller': currentController!,
    };
    currentType.value = isFocus ? type : '';
    update();
  }

  bool getIsEmailValid(String type) {
    final emailValue = formData[type]!['text'].toString();
    return EmailValidator.validate(emailValue);
  }

  @override
  void toggleObscure() {
    isObscure.value = !isObscure.value;
    update();
  }

  bool getIsDataRegisterValid() {
    return formData['nameRegister']!['text'].toString().isNotEmpty &&
        formData['passwordRegister']!['text'].toString().isNotEmpty;
  }

  bool getIsNameValid() {
    final nameValue = formData['nameRegister']!['text'].toString();
    final nameRegExp = RegExp(r'^[a-zA-Z\s]+$');

    return !nameRegExp.hasMatch(nameValue) && nameValue.isNotEmpty;
  }

  Future<void> next() async {
    onClearController('nameRegister');
    onClearController('passwordRegister');
    await checkEmail(
      email: formData['emailRegister']!['text'].toString(),
    );
  }

  Future<void> checkEmail({required String email}) async {
    isLoading.value = true;

    try {
      // Memanggil fungsi dari repository
      bool emailExists = await _authRepo.checkEmail(email: email);

      if (emailExists) {
        isEmailRegistered.value = true;
      } else {
        isEmailRegistered.value = false;

        // Logika navigasi dipindah ke sini (Controller)
        // Get.off(
        //   () => const RegisterDataScreen(),
        //   transition: Transition.rightToLeftWithFade,
        //   fullscreenDialog: true,
        //   popGesture: false,
        //   arguments: {
        //     'email': email,
        //   },
        // );
      }
    } on TimeoutException {
      showRemoveAlbumToast("Server Timeout. Please try again later.");
    } catch (e, st) {
      logError('error: $e $st');
      showRemoveAlbumToast("Network error.");
    } finally {
      isLoading.value = false;
    }
  }
}
