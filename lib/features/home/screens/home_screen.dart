import 'package:cybeat_music_player/features/home/controllers/home_controller.dart';
import 'package:cybeat_music_player/core/controllers/audio_state_controller.dart';
import 'package:cybeat_music_player/features/home/widgets/home_filter/home_filter_grid.dart';
import 'package:cybeat_music_player/features/home/widgets/home_list/home_list_scale_tap.dart';
import 'package:cybeat_music_player/features/home/widgets/scale_tap_profile.dart';
import 'package:cybeat_music_player/features/playlist/new_playlist/widgets/show_new_playlist_modal.dart';
import 'package:cybeat_music_player/features/home/widgets/home_sort/scale_tap_sort.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_reorderable_grid_view/widgets/custom_draggable.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _gridViewKey = GlobalKey();
  final _homeController = Get.find<HomeController>();
  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
    return Scaffold(
      backgroundColor: HexColor('#fefffe'),
      appBar: AppBar(
        backgroundColor: HexColor('#fefffe'),
        scrolledUnderElevation: 0,
        elevation: 0,
        toolbarHeight: 20.h,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              children: [
                Row(
                  children: [
                    ScaleTapProfile(
                      onTap: () {
                        // ** Kalau drawer dari file ini, perlu Builder.
                        // Ini memanggil drawer di root page.
                        Scaffold.of(context).openDrawer();
                      },
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 10.w),
                      child: Text(
                        'Your Library',
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        Get.toNamed('/search_album', id: 1);
                      },
                      child: const Icon(
                        Icons.search_outlined,
                        color: Colors.black,
                        size: 30,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    GestureDetector(
                      onTap: () {
                        showNewPlaylistModal(context);
                      },
                      child: const Icon(
                        Icons.add,
                        color: Colors.black,
                        size: 30,
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 15.h,
                ),
                Obx(
                  // Awalnya, HomeFilterGrid ada const, tetapi di release mode,
                  // dia tidak bergeser, sehingga const dihapus.
                  () => _homeController.filterIsTapped.value ||
                          !_homeController.filterIsTapped.value
                      ? HomeFilterGrid()
                      : SizedBox(),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.3),
                  spreadRadius: 2,
                  blurRadius: 2,
                  offset: const Offset(0, 1), // changes position of shadow
                ),
              ],
            ),
            child: Divider(
              color: Colors.grey.withValues(alpha: 0.3),
              thickness: 2,
              height: 0,
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 20.w, right: 10.w),
              child: RawScrollbar(
                radius: const Radius.circular(10),
                controller: _scrollController,
                thumbVisibility: false,
                timeToFade: const Duration(milliseconds: 500),
                padding: EdgeInsets.only(top: 55.h),
                thickness: 5,
                thumbColor: HexColor('#ac8bc9').withValues(alpha: 0.7),
                trackVisibility: false,
                child: SmartRefresher(
                  controller: _homeController.refreshController,
                  scrollController: _scrollController,
                  onRefresh: _homeController.onRefresh,
                  onLoading: _homeController.onLoading,
                  enablePullDown: true,
                  enablePullUp: true,
                  header: const ClassicHeader(
                    height: 40,
                    refreshStyle: RefreshStyle.Follow,
                    refreshingIcon: SizedBox(
                      width: 25,
                      height: 25,
                      child: CircularProgressIndicator(
                        color: Colors.black,
                        strokeWidth: 2,
                      ),
                    ),
                    releaseText: 'Release to refresh',
                    refreshingText: 'Loading data...',
                    completeText: 'Success',
                    idleText: 'Pull down to refresh',
                    failedText: 'Failed',
                    textStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                    ),
                  ),
                  footer: const ClassicFooter(
                    height: 40,
                    loadStyle: LoadStyle.ShowWhenLoading,
                    loadingIcon: SizedBox(
                      width: 25,
                      height: 25,
                      child: CircularProgressIndicator(
                        color: Colors.black,
                        strokeWidth: 2,
                      ),
                    ),
                    idleText: 'Pull up to load more',
                    loadingText: 'Loading data...',
                    noDataText: 'No more data',
                    textStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              SizedBox(
                                height: 15.h,
                              ),
                              Row(
                                children: [
                                  ScaleTapSort(),
                                  Spacer(),
                                  InkWell(
                                    onTap: () {
                                      _homeController.changeLayoutGrid();
                                    },
                                    child: Obx(
                                      () => _homeController
                                                  .albumCountGrid.value ==
                                              1
                                          ? Icon(Icons.view_list_outlined)
                                          : Icon(Icons.grid_view_outlined),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Obx(
                                () => _homeController.isTapped.value ||
                                        !_homeController.isTapped.value
                                    ? _homeController.isLoading
                                        ? const SizedBox(
                                            height: 400,
                                            child: Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                          )
                                        : _homeController.initiateAlbum.isEmpty
                                            ? const Center(
                                                child: Text('No album found'),
                                              )
                                            : _getReorderableAlbum()
                                    : SizedBox(),
                              ),
                            ],
                          ),
                        ),
                        // ini sama aja padding kanan 20
                        SizedBox(
                          width: 10.w,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // mengambil data dari playlistList
  Widget _getReorderableAlbum() {
    final generatedChildren = _getGeneratedChildren();

    return ReorderableBuilder(
      onReorder: (p0) {},
      children: generatedChildren,
      builder: (context) {
        return Obx(
          () => GridView(
            key: _gridViewKey,
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            primary: false,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisSpacing: 15,
              mainAxisSpacing: 10,
              crossAxisCount: _homeController.albumCountGrid.value,
              childAspectRatio:
                  _homeController.albumCountGrid.value == 1 ? 40 / 9 : 2 / 3.5,
            ),
            children: context,
          ),
        );
      },
    );
  }

  List<Widget> _getGeneratedChildren() {
    return List<Widget>.generate(
      _homeController.selectedAlbum.length >= 15
          ? _homeController.jumlahAlbumDitampilkan.value
          : _homeController.selectedAlbum.length,
      (index) => _getChild(index: index),
    );
  }

  Widget _getChild({required int index}) {
    final audioStateController = Get.find<AudioStateController>();
    return CustomDraggable(
      key: Key(_homeController.allAlbumChildren[index].toString()),
      data: index,
      child: HomeListScaleTap(
        playlist: _homeController
            .initiateAlbum[(_homeController.allAlbumChildren[index])],
        audioState: audioStateController,
      ),
    );
  }
}
