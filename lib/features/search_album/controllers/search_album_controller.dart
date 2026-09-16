import 'dart:async';
import 'package:cybeat_music_player/common/utils/colorize_terminal.dart';
import 'package:cybeat_music_player/core/controllers/music_player_controller.dart';
import 'package:cybeat_music_player/core/mappers/album_mapper.dart';
import 'package:cybeat_music_player/core/repositories/album_repository.dart';
import 'package:cybeat_music_player/core/services/album_service.dart';
import 'package:cybeat_music_player/core/models/album.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchAlbumController extends GetxController {
  final AlbumService albumService = Get.find<AlbumService>();
  final AlbumRepository _albumRepository = AlbumRepository();
  final controller = TextEditingController();

  var isTyping = false.obs;
  var textValue = ''.obs;
  var isKeybordFocus = false.obs;
  var filteredAlbum = RxList<Album?>([]);
  var isSearch = false.obs;
  var isLoading = false.obs;

  Timer? _debounceTimer;

  @override
  void onClose() {
    _debounceTimer?.cancel();
    controller.dispose();
    super.onClose();
  }

  void onTyping(String value) {
    isTyping.value = value.isNotEmpty;
    update();
  }

  void onChanged(String value) {
    isTyping.value = value.isNotEmpty;
    textValue.value = value;
    isKeybordFocus.value = true;

    _debounceTimer?.cancel();
    if (value.trim().isEmpty) {
      filteredAlbum.clear();
      isLoading.value = false;
      isSearch.value = false;
      update();
    } else {
      isLoading.value = true;
      _debounceTimer = Timer(const Duration(milliseconds: 350), () {
        searchAlbumFromApi(value.trim());
      });
    }
  }

  Future<void> searchAlbumFromApi(String query) async {
    if (query.isEmpty) {
      filteredAlbum.clear();
      isLoading.value = false;
      isSearch.value = false;
      update();
      return;
    }

    try {
      isLoading.value = true;
      final response = await _albumRepository.fetchAlbums(search: query);
      final dataMap = response['data'] as Map<String, dynamic>?;

      final allRawData = [
        ...(dataMap?['album'] ?? []),
        ...(dataMap?['category'] ?? []),
        ...(dataMap?['playlist'] ?? []),
      ];

      final List<Album> list = allRawData.map((item) {
        return AlbumMapper.fromMap(
          item,
          currentPinCount: 0,
          gdriveApiKeyList: albumService.gdriveApiKeyList,
        );
      }).toList();

      filteredAlbum.value = list;
      isSearch.value = true;
      logSuccess('Search album success: found ${list.length} results for "$query"');
    } catch (e, st) {
      filteredAlbum.clear();
      logError('Error searching album from API: $e. Stacktrace: $st');
    } finally {
      isLoading.value = false;
      update();
    }
  }

  void openAlbum({
    required Album album,
    required MusicPlayerController musicPlayerController,
  }) {
    musicPlayerController.openAlbum(album: album);
  }

  String get getTextValue => textValue.value;

  bool get isTypingValue => isTyping.value;
}
