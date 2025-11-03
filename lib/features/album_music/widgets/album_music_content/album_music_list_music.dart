import 'package:cybeat_music_player/common/widgets/shimmer_music_list.dart';
import 'package:cybeat_music_player/core/controllers/audio_state_controller.dart';
import 'package:cybeat_music_player/core/controllers/music_player_controller.dart';
import 'package:cybeat_music_player/features/album_music/controllers/album_music_controller.dart';
import 'package:cybeat_music_player/features/album_music/widgets/album_music_list_mode/azlist_mode/album_music_azlist_list.dart';
import 'package:cybeat_music_player/features/album_music/widgets/album_music_list_mode/simple_mode/album_music_simple_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class AlbumMusicListMusic extends StatelessWidget {
  const AlbumMusicListMusic({
    super.key,
    required this.albumMusicController,
    required this.audioStateController,
    required this.musicPlayerController,
  });

  final AlbumMusicController albumMusicController;
  final AudioStateController audioStateController;
  final MusicPlayerController musicPlayerController;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        if (albumMusicController.initAlbumLoading.value) {
          return SliverToBoxAdapter(child: ShimmerMusicList());
        }
        if (audioStateController.playlist.isEmpty) {
          if (audioStateController.isAlbumEmpty.value) {
            albumMusicController.underLoadingFetchMusic = false;
            albumMusicController.sisaJumlahMusicTersedia = 0;
            return SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(
                  'No songs available in this ${musicPlayerController.currentActivePlaylist.value!.type.toLowerCase()}',
                  style: TextStyle(
                    color: Colors.black.withValues(alpha: 0.7),
                    fontSize: 16.sp,
                  ),
                ),
              ),
            );
          }
          albumMusicController.underLoadingFetchMusic = true;
        }

        albumMusicController.underLoadingFetchMusic = false;
        final musicList = audioStateController.playlist;
        if (albumMusicController.countMusicAlbum == 0) {
          albumMusicController.countMusicAlbum = musicList.length;
          albumMusicController.jumlahMusicDitampilkan.value =
              musicList.length >= 100 ? 100 : musicList.length;
          albumMusicController.sisaJumlahMusicTersedia = musicList.length -
              albumMusicController.jumlahMusicDitampilkan.value;
        }

        return Obx(
          () => SliverList(
            delegate: SliverChildBuilderDelegate(
              childCount: albumMusicController.isTapSearch.value
                  ? albumMusicController.filteredMusic.length
                  : albumMusicController.jumlahMusicDitampilkan.value,
              (context, index) {
                return Obx(
                  () => InkWell(
                    // Menghilangkan efek tap.
                    splashFactory: NoSplash.splashFactory,
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    child: albumMusicController.isSimpleMode
                        ? AlbumMusicSimpleList(
                            index: index,
                            music: albumMusicController.isTapSearch.value
                                ? albumMusicController.filteredMusic[index]
                                : musicList[index],
                            audioStateController: audioStateController,
                            albumMusicController: albumMusicController,
                          )
                        : AlbumMusicAzlistList(
                            index: index,
                            music: albumMusicController.isTapSearch.value
                                ? albumMusicController.filteredMusic[index]
                                : musicList[index],
                            audioPlayer:
                                audioStateController.activePlayer.value!,
                            audioState: audioStateController,
                          ),
                    onTap: () {
                      albumMusicController.navigateToDetailMusicScreen(
                        music: albumMusicController.isTapSearch.value
                            ? albumMusicController.filteredMusic[index]
                            : musicList[index],
                        index: index,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
