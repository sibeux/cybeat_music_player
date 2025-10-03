import 'package:cybeat_music_player/features/setting_app/controllers/setting_app_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';

class SettingAppScreen extends StatelessWidget {
  const SettingAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingAppController settingAppController =
        Get.find<SettingAppController>();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: HexColor('#fefffe'),
        scrolledUnderElevation: 0.0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          tooltip: 'Menu',
          onPressed: () {
            Get.back();
          },
        ),
        centerTitle: true,
        toolbarHeight: 60.h,
        title: Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: HexColor('#1e0b2b'),
            fontSize: 16.sp,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.3),
                  spreadRadius: 2.r,
                  blurRadius: 2.r,
                  offset: const Offset(0, 1), // changes position of shadow
                ),
              ],
            ),
            child: Divider(
              color: Colors.grey.withValues(alpha: 0.3),
              thickness: 2,
              height: 0,
            ),
          ),
          SizedBox(height: 30.h),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsetsGeometry.symmetric(horizontal: 25.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Simple mode',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                'Switch display to simple music list view',
                                maxLines: null,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w400,
                                  color: HexColor('#676767'),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Obx(
                          () => Switch(
                            activeThumbColor: HexColor('#8238be'),
                            value: settingAppController.isSimpleMode,
                            onChanged: (value) {
                              settingAppController.toggleSimpleMode(value);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
