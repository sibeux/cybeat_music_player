import 'package:cybeat_music_player/common/utils/color_theme.dart';
import 'package:cybeat_music_player/features/auth_user/controllers/user_register_controller.dart';
import 'package:cybeat_music_player/features/auth_user/widgets/auth_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterEmailEnable extends StatelessWidget {
  const RegisterEmailEnable({super.key});

  @override
  Widget build(BuildContext context) {
    final userRegisterController = Get.find<UserRegisterController>();
    return AuthButton(
      authType: 'emailRegister',
      buttonText: 'Next',
      foreground: Colors.white,
      background: ColorPalette().primary,
      isEnable: true,
      onPressed: () {
        userRegisterController.next();
      },
    );
  }
}
