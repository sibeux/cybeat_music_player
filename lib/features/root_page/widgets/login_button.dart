import 'package:cybeat_music_player/common/utils/color_theme.dart';
import 'package:cybeat_music_player/common/widgets/action_button.dart';
import 'package:cybeat_music_player/features/root_page/controllers/root_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginButton extends StatelessWidget {
  const LoginButton({super.key, required this.navDrawerContext});

  final BuildContext navDrawerContext;

  @override
  Widget build(BuildContext context) {
    final RootController rootController = Get.find<RootController>();
    return ActionButton(
      title: "Login",
      hexTextColor: Colors.white,
      hexBackColor: ColorPalette().primary,
      onPressed: () {
        rootController.clickLogin(navDrawerContext);
      },
    );
  }
}
