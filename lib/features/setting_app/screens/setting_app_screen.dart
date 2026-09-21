import 'package:cybeat_music_player/features/setting_app/controllers/setting_app_controller.dart';
import 'package:cybeat_music_player/features/setting_app/widgets/log_viewer_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class SettingAppScreen extends StatelessWidget {
  const SettingAppScreen({super.key});

  void _openLogModal(BuildContext context) {
    showMaterialModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24.r),
        ),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (context) => const LogViewerModal(),
    );
  }

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
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Divider(
              color: Colors.grey.withValues(alpha: 0.3),
              thickness: 2,
              height: 0,
            ),
          ),
          SizedBox(height: 20.h),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 25.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section: Tampilan
                    Text(
                      'Tampilan',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: HexColor('#8238be'),
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Simple mode',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                'Switch display to simple music list view',
                                maxLines: null,
                                style: TextStyle(
                                  fontSize: 13.sp,
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

                    SizedBox(height: 24.h),
                    Divider(color: Colors.grey.shade200),
                    SizedBox(height: 16.h),

                    // Section: Development & Diagnostics
                    Text(
                      'Development & Diagnostik',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: HexColor('#8238be'),
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // Card Download & View Log
                    InkWell(
                      borderRadius: BorderRadius.circular(16.r),
                      onTap: () => _openLogModal(context),
                      child: Container(
                        padding: EdgeInsets.all(16.r),
                        decoration: BoxDecoration(
                          color: HexColor('#fbfaff'),
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: HexColor('#ede7f6')),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10.r),
                              decoration: BoxDecoration(
                                color: HexColor('#8238be').withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Icon(
                                Icons.text_snippet_rounded,
                                color: HexColor('#8238be'),
                                size: 24.sp,
                              ),
                            ),
                            SizedBox(width: 14.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Download & Periksa Log',
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w600,
                                      color: HexColor('#1e0b2b'),
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    'Unduh log offline & error dalam rentang retensi 30 hari terakhir',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: HexColor('#676767'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 16.sp,
                              color: HexColor('#8238be'),
                            ),
                          ],
                        ),
                      ),
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

