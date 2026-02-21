import 'package:get/get.dart';

abstract class AuthFormControllerContract extends GetxController {
  bool get isObscureValue;
  RxString get currentType;
  RxMap get formData;

  void toggleObscure();
  void onClearController(String type);
  void onChanged(String value, String type);
  void onTap(String type, bool isFocus);

  bool isFieldValid(String formType);
  bool getIsEmailValid(String formType);
}
