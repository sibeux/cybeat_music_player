import 'package:cybeat_music_player/common/utils/color_theme.dart';
import 'package:cybeat_music_player/features/auth_user/controllers/user_register_controller.dart';
import 'package:cybeat_music_player/features/auth_user/widgets/auth_button_loading.dart';
import 'package:cybeat_music_player/features/auth_user/widgets/register/buttons/register_submit_button_disable.dart';
import 'package:cybeat_music_player/features/auth_user/widgets/register/forms/name_register_from.dart';
import 'package:cybeat_music_player/features/auth_user/widgets/register/forms/password_register_form.dart';
import 'package:cybeat_music_player/features/auth_user/widgets/register/buttons/register_submit_button_enable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';

class DataRegistrationScreen extends StatelessWidget {
  const DataRegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userRegisterController = Get.find<UserRegisterController>();
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        // Best Practice: Hapus controller saat halaman ini ditinggalkan.
        // 'force: true' wajib untuk menghapus controller permanent
        Get.delete<UserRegisterController>(force: true);
      },
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: HexColor('#fefffe'),
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              backgroundColor: HexColor('#fefffe'),
              titleSpacing: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                color: Colors.black,
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
                  'User Data Registration',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: ColorPalette().primary,
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  'Please fill in the form below to create your account',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.black.withValues(alpha: .8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 30.h),
                NameRegisterForm(controller: userRegisterController),
                SizedBox(height: 5.h),
                Obx(
                  () => userRegisterController.getIsNameValid()
                      ? Container(
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.symmetric(horizontal: 40.w),
                          child: Text(
                            '*Name can only contain letters and spaces.',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.red.withValues(alpha: 1),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      : const SizedBox(),
                ),
                SizedBox(height: 10.h),
                PasswordRegisterForm(controller: userRegisterController),
                SizedBox(height: 20.h),
                Obx(
                  () => userRegisterController.getIsDataRegisterValid() &&
                          !userRegisterController.getIsNameValid()
                      ? userRegisterController.isLoading.value
                          ? const AbsorbPointer(child: AuthButtonLoading())
                          : RegisterSubmitButtonEnable()
                      : const AbsorbPointer(
                          child: RegisterSubmitButtonDisable()),
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have a Cybeat account? ',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.black.withValues(alpha: .8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        userRegisterController
                            .onClearController('emailRegister');
                        // Get.off(
                        //   () => const LoginScreen(),
                        //   fullscreenDialog: true,
                        //   popGesture: false,
                        // );
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
          Obx(() => userRegisterController.isRedirecting.value
              ? const Opacity(
                  opacity: 0.8,
                  child: ModalBarrier(dismissible: false, color: Colors.black),
                )
              : const SizedBox()),
          Obx(() => userRegisterController.isRedirecting.value
              ? Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                )
              : const SizedBox()),
        ],
      ),
    );
  }
}
