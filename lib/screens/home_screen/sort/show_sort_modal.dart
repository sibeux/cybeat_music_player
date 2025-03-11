import 'package:cybeat_music_player/controller/sort_preferences_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

Future<dynamic> showSortModalBottom(BuildContext context) {

  return showMaterialModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(20),
      ),
    ),
    clipBehavior: Clip.antiAliasWithSaveLayer,
    builder: (context) => Container(
      color: Colors.white,
      child: Column(
        // mainAxisSize: MainAxisSize.min - mencegah layar full
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 5, bottom: 10),
            height: 5,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Sort by',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Divider(
            height: 1,
            thickness: 1,
          ),
          // const SizedBox(height: 20),
          // by default, ListTile has a padding of 16
          const Column(
            children: [
              ListTileBottomModal(
                title: 'Recents',
              ),
              ListTileBottomModal(
                title: 'Alphabetical',
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class ListTileBottomModal extends StatelessWidget {
  const ListTileBottomModal({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    final sortPreferencesController = Get.put(SortPreferencesController());
    final sortValue = title == 'Recents' ? 'uid' : 'title';
    return Obx(() => ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
          minVerticalPadding: 5,
          trailing: sortPreferencesController.sortValue == sortValue
              ? Icon(Icons.check, color: HexColor('#ac8bc9'))
              : null,
          title: Text(title),
          titleTextStyle: const TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          onTap: () {
            sortPreferencesController.saveSortBy(title);
            Get.back();
          },
        ));
  }
}
