import 'package:cybeat_music_player/features/auth_user/controllers/user_register_controller.dart';
import 'package:cybeat_music_player/features/auth_user/widgets/form_blueprint.dart';
import 'package:flutter/material.dart';

class EmailRegisterForm extends StatelessWidget {
  const EmailRegisterForm({
    super.key,
    required this.controller,
  });

  final UserRegisterController controller;

  @override
  Widget build(BuildContext context) {
    return FormBlueprint(
      controller: controller,
      formType: 'emailRegister',
      formText: 'email',
      keyboardType: TextInputType.emailAddress,
      icon: Icons.email,
      autoFillHints: AutofillHints.email,
    );
  }
}
