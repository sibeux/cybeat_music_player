import 'package:cybeat_music_player/common/utils/color_theme.dart';
import 'package:cybeat_music_player/features/auth_user/controllers/user_register_controller.dart';
import 'package:cybeat_music_player/features/auth_user/widgets/auth_button_loading.dart';
import 'package:cybeat_music_player/features/auth_user/widgets/register/forms/email_register_form.dart';
import 'package:cybeat_music_player/features/auth_user/widgets/register/buttons/register_email_disable.dart';
import 'package:cybeat_music_player/features/auth_user/widgets/register/buttons/register_email_enable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';

class EmailCheckScreen extends StatelessWidget {
  const EmailCheckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userRegisterController = Get.find<UserRegisterController>();
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        // Best Practice: Hapus controller saat halaman ini ditinggalkan.
        // 'force: true' wajib untuk menghapus controller permanent
        if (!userRegisterController.isProceedingToNextStep) {
          Get.delete<UserRegisterController>(force: true);
        }
      },
      child: Scaffold(
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
          title: const Text('Sign Up'),
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
              'Sign Up Cybeat',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: ColorPalette().primary,
              ),
            ),
            SizedBox(height: 5.h),
            Text(
              'Create your account to get started!',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.black.withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 30.h),
            EmailRegisterForm(
              controller: userRegisterController,
            ),
            Obx(
              () => userRegisterController.isEmailRegistered.value
                  ? Container(
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.only(top: 5.h),
                      padding: EdgeInsets.symmetric(horizontal: 40.w),
                      child: Text(
                        '*The email has already been registered',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.red.withValues(alpha: 1),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  : const SizedBox(),
            ),
            SizedBox(height: 20.h),
            Obx(
              () => userRegisterController.getIsEmailValid('emailRegister')
                  ? userRegisterController.isLoading.value
                      ? const AbsorbPointer(child: AuthButtonLoading())
                      : const RegisterEmailEnable()
                  : const AbsorbPointer(child: RegisterEmailDisable()),
            ),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have a Cybeat account? ',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.black.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    userRegisterController.moveToLogin();
                  },
                  child: Text(
                    'Sign In',
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
    );
  }
}
