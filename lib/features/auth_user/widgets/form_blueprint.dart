import 'package:cybeat_music_player/common/utils/color_theme.dart';
import 'package:cybeat_music_player/features/auth_user/interfaces/auth_form_controller_contract.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';

class FormBlueprint extends StatelessWidget {
  const FormBlueprint({
    super.key,
    required this.formType,
    required this.keyboardType,
    required this.icon,
    required this.formText,
    required this.autoFillHints,
    required this.controller,
  });

  final String formType, formText, autoFillHints;
  final TextInputType keyboardType;
  final IconData icon;
  final AuthFormControllerContract controller;

  @override
  Widget build(BuildContext context) {
    final textController = controller.formData[formType]?['controller'];
    return Obx(
      () => Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: TextFormField(
          controller: textController as TextEditingController?,
          cursorColor: HexColor('#575757'),
          textAlignVertical: TextAlignVertical.center,
          enableSuggestions: true,
          autofillHints: [autoFillHints],
          keyboardType: keyboardType,
          obscureText: formType.toLowerCase().contains('password')
              ? controller.isObscureValue
              : false,
          onChanged: (value) {
            controller.onChanged(value, formType);
          },
          onTap: () {
            controller.onTap(formType, true);
          },
          onTapOutside: (event) {
            controller.onTap(formType, false);
            FocusManager.instance.primaryFocus?.unfocus();
          },
          style: TextStyle(
            color: Colors.black,
            fontSize: 12.sp,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color: HexColor('#575757'),
            ),
            suffixIcon: formType.toLowerCase().contains('password')
                ? Obx(
                    () => controller.isObscureValue == false
                        ? GestureDetector(
                            onTap: () {
                              controller.toggleObscure();
                            },
                            child: Icon(
                              Icons.visibility_off,
                              color: HexColor('#575757'),
                            ),
                          )
                        : GestureDetector(
                            onTap: () {
                              controller.toggleObscure();
                            },
                            child: Icon(
                              Icons.visibility,
                              color: HexColor('#575757'),
                            ),
                          ),
                  )
                : null,
            filled: true,
            isDense: true,
            fillColor: HexColor('#fefffe'),
            contentPadding: EdgeInsets.symmetric(
              vertical: 7.h,
              horizontal: 12.w,
            ),
            hintText: formText.capitalize,
            hintStyle: TextStyle(
              color: Colors.grey,
              fontSize: 12.sp,
            ),
            suffixIconConstraints: BoxConstraints(
              minWidth: 40.w,
              minHeight: 45.h,
            ),
            prefixIconConstraints: BoxConstraints(
              minWidth: 40.w,
              minHeight: 45.h,
            ),
            enabledBorder: outlineInputBorder(
              hasContent: controller.formData[formType]?['text']
                      .toString()
                      .isNotEmpty ??
                  false,
              isFocused: controller.currentType.value == formType,
              isValid: controller.isFieldValid(formType),
            ),
            focusedBorder: outlineInputBorder(
              hasContent: controller.formData[formType]?['text']
                      .toString()
                      .isNotEmpty ??
                  false,
              isFocused: controller.currentType.value == formType,
              isValid: controller.isFieldValid(formType),
            ),
          ),
        ),
      ),
    );
  }
}

OutlineInputBorder outlineInputBorder({
  required bool hasContent,
  required bool isFocused,
  required bool isValid,
}) {
  final Color borderColor;

  if (!hasContent && !isFocused) {
    borderColor = HexColor('#575757');
  } else {
    borderColor = isValid ? ColorPalette().primary : HexColor('#ff0000');
  }

  return OutlineInputBorder(
    borderSide: BorderSide(
      color: borderColor.withValues(alpha: hasContent || isFocused ? 0.5 : 0.5),
      width: 2.w,
    ),
    borderRadius: BorderRadius.all(Radius.circular(7.r)),
  );
}
