import 'package:cybeat_music_player/features/auth_user/widgets/auth_button.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class RegisterEmailDisable extends StatelessWidget {
  const RegisterEmailDisable({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthButton(
      authType: 'emailRegister',
      buttonText: 'Next',
      foreground: HexColor('#a8b5c8'),
      background: HexColor('#e5eaf5'),
      isEnable: false,
      onPressed: () {},
    );
  }
}
