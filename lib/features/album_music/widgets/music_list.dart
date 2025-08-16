import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cybeat_music_player/controller/music_download_controller.dart';
import 'package:cybeat_music_player/core/controllers/audio_state_provider.dart';
import 'package:cybeat_music_player/core/controllers/music_state_provider.dart';
import 'package:cybeat_music_player/common/utils/capitalize.dart';
import 'package:cybeat_music_player/screens/azlistview/show_music_modal.dart';
import 'package:cybeat_music_player/widgets/spectrum_animation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:path/path.dart' as path;

class MusicList extends StatelessWidget {
  const MusicList({
    super.key,
    required this.mediaItem,
    required this.audioPlayer,
    required this.index,
    required this.audioState,
  });

  final MediaItem mediaItem;
  final AudioPlayer audioPlayer;
  final int index;
  final AudioState audioState;

  @override
  Widget build(BuildContext context) {
    final musikDimainkan = context.watch<MusicState>().currentMediaItem;
    final musicDownloadController = Get.find<MusicDownloadController>();
    String colorTitle = "#313031";
    double marginList = 18;

    Widget indexIcon = Text(
      mediaItem.id.toString().padLeft(2, '0'),
      style: TextStyle(
        fontSize: 12,
        color: HexColor('#8d8c8c'),
        fontWeight: FontWeight.bold,
      ),
    );

    // Perbaikan di bug warna ungu yang tidak hilang saat pindah album, 
    // adalah dengan mengganti logika cek lagu yang semula index, menjadi music_id.
    if (musikDimainkan?.extras!['music_id'] == mediaItem.extras!['music_id']) {
      colorTitle = '#8238be';
      marginList = 12;
      indexIcon = const SpectrumAnimation();
    }

    const lossyFormats = ['mp3', 'aac', 'ogg', 'opus', 'wma'];

    return SizedBox(
      height: 70,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              IndexNumberList(
                marginList: marginList,
                musicDownloadController: musicDownloadController,
                mediaItem: mediaItem,
                indexIcon: indexIcon,
                musikDimainkan: musikDimainkan,
              ),
              // cover image
              Container(
                width: 45,
                height: 45,
                margin: const EdgeInsets.only(right: 5),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5)),
                        child: CachedNetworkImage(
                          imageUrl: mediaItem.artUri.toString(),
                          fit: BoxFit.cover,
                          maxHeightDiskCache: 150,
                          maxWidthDiskCache: 150,
                          filterQuality: FilterQuality.low,
                          placeholder: (context, url) => Image.asset(
                            'assets/images/placeholder_cover_music.png',
                            fit: BoxFit.cover,
                          ),
                          errorWidget: (context, url, error) => Image.asset(
                            'assets/images/placeholder_cover_music.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    if (!lossyFormats.contains(path
                        .extension(mediaItem.extras!['url'].toString())
                        .replaceFirst('.', '')
                        .toLowerCase()))
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Image.asset(
                          'assets/images/badge-en-lossless.png',
                          fit: BoxFit.cover,
                          width: 30,
                          height: 30,
                        ),
                      )
                  ],
                ),
              ),
              const SizedBox(
                width: 2,
              ),
              Expanded(
                child: SizedBox(
                  height: 45,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        capitalizeEachWord(mediaItem.title),
                        style: TextStyle(
                          fontSize: 14,
                          color: HexColor(colorTitle),
                          overflow: TextOverflow.ellipsis,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            child: Icon(
                              Icons.audiotrack_outlined,
                              color: HexColor('#b4b5b4'),
                              size: 15,
                            ),
                          ),
                          Expanded(
                            child: Container(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                style: TextStyle(
                                  fontSize: 12,
                                  color: HexColor('#b4b5b4'),
                                  overflow: TextOverflow.ellipsis,
                                  fontWeight: FontWeight.values[4],
                                ),
                                '${capitalizeEachWord(mediaItem.artist!)} | ${capitalizeEachWord(mediaItem.album!)}',
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              IconButton(
                highlightColor: Colors.black.withValues(alpha: 0.02),
                icon: Icon(
                  Icons.more_vert_sharp,
                  size: 30,
                  color: HexColor('#b5b5b4'),
                ),
                onPressed: () {
                  showMusicModalBottom(
                    context,
                    mediaItem,
                    audioPlayer,
                    index,
                    audioState,
                  );
                },
              ),
              const SizedBox(
                width: 15,
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            margin: const EdgeInsets.only(left: 18, right: 10),
            width: double.infinity,
            height: 1,
            color: HexColor('#e0e0e0').withValues(alpha: 0.7),
          ),
        ],
      ),
    );
  }
}

class IndexNumberList extends StatelessWidget {
  const IndexNumberList({
    super.key,
    required this.marginList,
    required this.musicDownloadController,
    required this.mediaItem,
    required this.indexIcon,
    required this.musikDimainkan,
  });

  final double marginList;
  final MusicDownloadController musicDownloadController;
  final MediaItem mediaItem;
  final Widget indexIcon;
  final MediaItem? musikDimainkan;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      margin: EdgeInsets.only(
        left: marginList,
      ),
      child: Obx(
        () => musicDownloadController
                    .dataProgressDownload[mediaItem.extras!['music_id']] !=
                null
            ? musicDownloadController.dataProgressDownload[
                        mediaItem.extras!['music_id']]!['progress'] ==
                    0.0
                ? indexIcon
                : Transform.scale(
                    scale: 0.8,
                    child: CircularPercentIndicator(
                      radius: 20,
                      lineWidth: 2,
                      percent: musicDownloadController.dataProgressDownload[
                          mediaItem.extras!['music_id']]!['progress'],
                      center: Text(
                        '${(musicDownloadController.dataProgressDownload[mediaItem.extras!['music_id']]!['progress'] * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 12,
                          color: HexColor('#8238be'),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      progressColor: HexColor('#8238be'),
                      backgroundColor: HexColor('#8d8c8c'),
                    ),
                  )
            : mediaItem.extras?['is_downloaded'] == true &&
                    musikDimainkan?.id != mediaItem.id
                ? const Icon(
                    Icons.download_done_rounded,
                    color: Colors.green,
                    size: 20,
                  )
                : indexIcon,
      ),
    );
  }
}
