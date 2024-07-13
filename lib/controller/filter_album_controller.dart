import 'package:cybeat_music_player/screens/home_screen/filter/grid_filter.dart';
import 'package:cybeat_music_player/screens/home_screen/filter/scale_tap_filter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';

class FilterAlbumController extends GetxController {
  var initialFilter = RxList(
    [
      const ScaleTapFilter(
          filter: 'playlist', child: FilterPlaylistAlbum(text: 'Playlist')),
      const ScaleTapFilter(
          filter: 'album', child: FilterPlaylistAlbum(text: 'Album')),
      const ScaleTapFilter(
          filter: 'category', child: FilterPlaylistAlbum(text: 'Category')),
    ],
  );

  var generateFilter = RxList(
    [
      const ScaleTapFilter(
          filter: 'playlist', child: FilterPlaylistAlbum(text: 'Playlist')),
      const ScaleTapFilter(
          filter: 'album', child: FilterPlaylistAlbum(text: 'Album')),
      const ScaleTapFilter(
          filter: 'category', child: FilterPlaylistAlbum(text: 'Category')),
    ],
  );

  var cancelButton = ScaleTapFilter(
    filter: 'cancel',
    child: Container(
      height: 35,
      width: 35,
      decoration: BoxDecoration(
        color: HexColor('#ac8bc9'),
        borderRadius: BorderRadius.circular(50),
      ),
      child: const Icon(
        Icons.cancel,
        color: Colors.white,
        size: 32,
      ),
    ),
  );

  var children = RxList([0, 1, 2]);

  var selectedFilter = ''.obs;
  var isTapped = false.obs;

  void onTapFilter({required String filter}) {
    var index =
        generateFilter.indexWhere((element) => element.filter == filter);

    final currentChild = children[index];
    final currentFilter = generateFilter[index];
    children.removeAt(index);
    generateFilter.removeAt(index);
    children.insert(0, currentChild);
    generateFilter.insert(0, currentFilter);

    children.insert(0, 4);
    generateFilter.insert(0, cancelButton);

    selectedFilter.value = filter;
    isTapped.value = !isTapped.value;
  }

  void onResetFilter() {
    var initialIndex = initialFilter
        .indexWhere((element) => element.filter == selectedFilter.value);
    var currentIndex = generateFilter
        .indexWhere((element) => element.filter == selectedFilter.value);

    final currentChild = children[currentIndex];
    final currentFilter = generateFilter[currentIndex];
    children.removeAt(currentIndex);
    generateFilter.removeAt(currentIndex);

    children.removeAt(0);
    generateFilter.removeAt(0);

    children.insert(initialIndex, currentChild);
    generateFilter.insert(initialIndex, currentFilter);

    selectedFilter.value = '';
    isTapped.value = !isTapped.value;
  }

  get getSelectedFilter => selectedFilter.value;
}
