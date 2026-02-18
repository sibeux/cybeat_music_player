import 'package:cybeat_music_player/core/controllers/music_download_controller.dart';
import 'package:cybeat_music_player/core/services/auth_service.dart';
import 'package:cybeat_music_player/features/root_page/widgets/login_button.dart';
import 'package:cybeat_music_player/features/root_page/widgets/root_drawer_listtile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class RootNavigationDrawer extends StatelessWidget {
  const RootNavigationDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = Get.find<AuthService>();
    return Drawer(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.zero,
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsetsGeometry.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40.h),
              Obx(
                () => !authService.isAuthenticated
                    ? LoginButton(navDrawerContext: context)
                    : Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(100.r),
                            child: Image(
                              image:
                                  AssetImage('assets/images/cybeat_splash.png'),
                              width: 50.w,
                              height: 50.h,
                            ),
                          ),
                          SizedBox(width: 15.w),
                          Text(
                            authService.fullName.value,
                            maxLines: 1,
                            style: TextStyle(
                              overflow: TextOverflow.ellipsis,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
              ),
              SizedBox(height: 10.h),
              RootDrawerListtile(
                icon: Icons.cloud_download_outlined,
                title: "Downloads",
                onTap: () async {
                  Navigator.of(context).pop();
                  await Future.delayed(const Duration(milliseconds: 300));
                  final musicDownloadController =
                      Get.find<MusicDownloadController>();
                  musicDownloadController.goOfflineScreen();
                },
              ),
              if (authService.isAuthenticated)
                RootDrawerListtile(
                  icon: Icons.history,
                  title: "Recents",
                  onTap: () async {
                    Navigator.of(context).pop();
                    await Future.delayed(const Duration(milliseconds: 300));
                    Get.toNamed(
                      '/recents',
                      id: 1,
                    );
                  },
                ),
              RootDrawerListtile(
                icon: Icons.settings_outlined,
                title: "Settings",
                onTap: () async {
                  Navigator.of(context).pop();
                  await Future.delayed(const Duration(milliseconds: 300));
                  Get.toNamed(
                    '/setting_app',
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
