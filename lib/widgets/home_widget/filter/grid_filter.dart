import 'package:cybeat_music_player/controller/filter_album_controller.dart';
import 'package:cybeat_music_player/widgets/home_widget/filter/filter_playlist_album.dart';
import 'package:cybeat_music_player/widgets/home_widget/filter/scale_tap_filter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/widgets/custom_draggable.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_builder.dart';
import 'package:get/get.dart';

class GridFilter extends StatelessWidget {
  const GridFilter({super.key});

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
    final filterAlbumController = Get.find<FilterAlbumController>();
    return List<Widget>.generate(
      filterAlbumController.generateFilter.length,
      (index) => _getFilter(index: index),
    );
  }

  Widget _getFilter({required int index}) {
    final filterAlbumController = Get.find<FilterAlbumController>();
    return CustomDraggable(
      key: Key(filterAlbumController.children[index].toString()),
      data: index,
      // child: filterAlbumController.generateFilter[index],
      child: ScaleTapFilter(
        filter: filterAlbumController.generateFilter[index].filter,
        child: FilterPlaylistAlbum(
          text: filterAlbumController.generateFilter[index].text,
        ),
      ),
    );
  }
}
