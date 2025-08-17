import 'package:cybeat_music_player/features/home/controllers/home_controller.dart';
import 'package:cybeat_music_player/features/home/widgets/home_filter/home_filter_album.dart';
import 'package:cybeat_music_player/features/home/widgets/home_filter/home_filter_scale_tap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/widgets/custom_draggable.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_builder.dart';
import 'package:get/get.dart';

class HomeFilterGrid extends StatelessWidget {
  const HomeFilterGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey filterKey = GlobalKey(); // ⬅️ Dideklarasikan di sini
    final generatedFilter = _getGeneratedFilter();
    return ReorderableBuilder(
      onReorder: (p0) {},
      enableDraggable: false,
      children: generatedFilter,
      builder: (context) {
        return Align(
          alignment: Alignment.centerLeft,
          child: Wrap(
            key: filterKey,
            direction: Axis.horizontal,
            spacing: 10,
            runSpacing: 10,
            children: context,
          ),
        );
      },
    );
  }

  List<Widget> _getGeneratedFilter() {
    final homeController = Get.find<HomeController>();
    return List<Widget>.generate(
      homeController.generateFilter.length,
      (index) => _getFilter(index: index),
    );
  }

  Widget _getFilter({required int index}) {
    final homeController = Get.find<HomeController>();
    return CustomDraggable(
      key: Key(homeController.homeFilterChildren[index].toString()),
      data: index,
      child: HomeFilterScaleTap(
        filter: homeController.generateFilter[index].filter,
        child: HomeFilterAlbum(
          text: homeController.generateFilter[index].text,
        ),
      ),
    );
  }
}
