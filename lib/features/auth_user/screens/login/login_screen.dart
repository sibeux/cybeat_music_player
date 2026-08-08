import 'package:cybeat_music_player/common/utils/color_theme.dart';
import 'package:cybeat_music_player/features/auth_user/controllers/user_login_controller.dart';
import 'package:cybeat_music_player/features/auth_user/widgets/auth_button_loading.dart';
import 'package:cybeat_music_player/features/auth_user/widgets/login/buttons/login_submit_button_disable.dart';
import 'package:cybeat_music_player/features/auth_user/widgets/login/buttons/login_submit_button_enable.dart';
import 'package:cybeat_music_player/features/auth_user/widgets/login/forms/email_login_form.dart';
import 'package:cybeat_music_player/features/auth_user/widgets/login/forms/password_login_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userLoginController = Get.find<UserLoginController>();
    return Stack(
      children: [
        Scaffold(
          backgroundColor: HexColor('#fefffe'),
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            backgroundColor: HexColor('#fefffe'),
            titleSpacing: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Get.back();
              },
            ),
            title: const Text('Sign In'),
            titleTextStyle: TextStyle(
              color: Colors.black,
              fontSize: 18.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          body: Column(
            children: [
              SizedBox(height: 30.h),
              Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: ColorPalette().primary,
                ),
              ),
              SizedBox(height: 5.h),
              Text(
                'Please log in to your account',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.black.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 30.h),
              EmailLoginForm(controller: userLoginController),
              SizedBox(height: 10.h),
              PasswordLoginForm(controller: userLoginController),
              Obx(
                () => !userLoginController.isLoginSuccess.value
                    ? Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.only(top: 5.h),
                        padding: EdgeInsets.symmetric(horizontal: 40.w),
                        child: Text(
                          '*Email or password is incorrect',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.red.withValues(alpha: 1),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    : const SizedBox(),
              ),
              SizedBox(height: 30.h),
              Obx(
                () => userLoginController.getIsDataLoginValid()
                    ? userLoginController.isLoading.value
                        ? const AbsorbPointer(child: AuthButtonLoading())
                        : LoginSubmitButtonEnable(
                            controller: userLoginController)
                    : const AbsorbPointer(child: LoginSubmitButtonDisable()),
              ),
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Don\'t have an account? ',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.black.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      userLoginController.moveToRegister();
                    },
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: ColorPalette().primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Obx(
          () => userLoginController.isRedirecting.value
              ? const Opacity(
                  opacity: 0.8,
                  child: ModalBarrier(dismissible: false, color: Colors.black),
                )
              : const SizedBox(),
        ),
        Obx(
          () => userLoginController.isRedirecting.value
              ? Center(
                  child: CircularProgressIndicator(
                  color: Colors.white,
                ))
              : const SizedBox(),
        ),
      ],
    );
  }
}
