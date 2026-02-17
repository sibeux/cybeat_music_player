import 'package:cybeat_music_player/features/auth_user/controllers/user_register_controller.dart';
import 'package:cybeat_music_player/features/auth_user/widgets/form_blueprint.dart';
import 'package:flutter/material.dart';

class PasswordRegisterForm extends StatelessWidget {
  const PasswordRegisterForm({super.key, required this.controller});

  final UserRegisterController controller;

  @override
  Widget build(BuildContext context) {
    return FormBlueprint(
      controller: controller,
      formType: 'passwordRegister',
      formText: 'password',
      keyboardType: TextInputType.visiblePassword,
      icon: Icons.lock,
      autoFillHints: '',
    );
  }
}
