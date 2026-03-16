import 'package:cybeat_music_player/common/utils/colorize_terminal.dart';
import 'package:cybeat_music_player/common/utils/toast.dart';
import 'package:cybeat_music_player/core/services/album_service.dart';
import 'package:cybeat_music_player/core/services/auth_service.dart';
import 'package:cybeat_music_player/features/auth_user/interfaces/auth_form_controller_contract.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserLoginController extends AuthFormControllerContract {
  var isLoading = false.obs;
  var isLoginSuccess = true.obs;
  var isRedirecting = false.obs;
  var isObscure = true.obs;

  final _currentType = ''.obs;

  final _formData = RxMap<String, Object?>(
    // Pakai Object? untuk memungkinkan assign dynamic value + tidak terjadi error.
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
      },
    },
  );

  @override
  void onInit() {
    super.onInit();
    isLoading.value = false;
    isLoginSuccess.value = true;
    isRedirecting.value = false;
  }

  @override
  RxString get currentType => _currentType;

  @override
  RxMap get formData => _formData;

  @override
  bool get isObscureValue => isObscure.value;

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

  @override
  void toggleObscure() {
    isObscure.value = !isObscure.value;
    update();
  }

  @override
  bool getIsEmailValid(String type) {
    final emailValue = formData[type]!['text'].toString();
    return EmailValidator.validate(emailValue);
  }

  @override
  bool isFieldValid(String formType) {
    final textValue = formData[formType]?['text']?.toString();

    bool isEmailValid =
        !(!getIsEmailValid('emailLogin') && textValue!.isNotEmpty);

    return ((formType == 'emailLogin' ? isEmailValid : true) &&
        isLoginSuccess.value);
  }

  bool getIsDataLoginValid() {
    final emailValue = formData['emailLogin']!['text'].toString();
    return EmailValidator.validate(emailValue) &&
        emailValue.isNotEmpty &&
        formData['passwordLogin']!['text'].toString().isNotEmpty;
  }

  void moveToRegister() {
    onClearController('emailLogin');
    onClearController('passwordLogin');
    Get.offAndToNamed('/email_check');
  }

  Future<void> login() async {
    // Ambil data dari form
    final email = formData['emailLogin']!['text'].toString();
    final password = formData['passwordLogin']!['text'].toString();

    isLoading.value = true;

    try {
      final AuthService authService = Get.find<AuthService>();
      // Panggil Service
      bool isSuccess =
          await authService.loginUser(email: email, password: password);

      if (isSuccess) {
        logSuccess('Login success for $email');
        isRedirecting.value = true;
        await Future.delayed(const Duration(milliseconds: 200));
        final albumService = Get.find<AlbumService>();
        albumService.initializeAlbum();
        Get.back();
      } else {
        isLoginSuccess.value = false;
      }
    } catch (e, st) {
      // Handle error (Timeout, Network, atau Pesan dari API)
      logError('Login Error: $e, $st');
      showRemoveAlbumToast(
          "Login failed. Please check your connection and try again.");
    } finally {
      isLoading.value = false;
      isRedirecting.value = false;
    }
  }
}
