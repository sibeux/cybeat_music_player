import 'package:cybeat_music_player/features/auth_user/controllers/user_login_controller.dart';
import 'package:cybeat_music_player/features/auth_user/widgets/form_blueprint.dart';
import 'package:flutter/material.dart';

class PasswordLoginForm extends StatelessWidget {
  const PasswordLoginForm({super.key, required this.controller});

  final UserLoginController controller;

  @override
  Widget build(BuildContext context) {
    return FormBlueprint(
      controller: controller,
      formType: 'passwordLogin',
      formText: 'password',
      keyboardType: TextInputType.visiblePassword,
      icon: Icons.lock,
      autoFillHints: '',
    );
  }
}
