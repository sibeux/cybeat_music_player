import 'package:cybeat_music_player/features/home/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';

class HomeFilterAlbum extends StatelessWidget {
  const HomeFilterAlbum({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();
    return text.toLowerCase() == 'cancel'
        ? Container(
            height: 35,
            width: 35,
            decoration: BoxDecoration(
              color: HexColor('#ac8bc9'),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Icons.cancel,
              color: Colors.white,
              size: 32.sp,
            ),
          )
        : Obx(
            () => Container(
              alignment: Alignment.center,
              width: 80,
              height: 35,
              decoration: BoxDecoration(
                color: homeController.getSelectedFilter.toString() ==
                        text.toLowerCase()
                    ? HexColor('#ac8bc9')
                    : homeController.getSelectedFilter.toString() ==
                            ''
                        ? Colors.grey
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  color:
                      homeController.getSelectedFilter.toString() ==
                              text.toLowerCase()
                          ? HexColor('#fefffe')
                          : homeController.getSelectedFilter
                                      .toString() ==
                                  ''
                              ? HexColor('#fefffe')
                              : Colors.transparent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
  }
}
