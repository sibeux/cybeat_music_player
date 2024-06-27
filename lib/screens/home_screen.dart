import 'package:cybeat_music_player/widgets/home_screen/grid_playlist_album.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor('#fefffe'),
      appBar: AppBar(
        backgroundColor: HexColor('#fefffe'),
        scrolledUnderElevation: 0,
        elevation: 0,
        toolbarHeight: 30,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: const Image(
                        image: NetworkImage(
                            'https://sibeux.my.id/images/sibe.png'),
                        width: 40,
                        height: 40,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 10),
                      child: const Text(
                        'Your Library',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: SizedBox(),
                    ),
                    const Icon(
                      Icons.search_outlined,
                      color: Colors.black,
                      size: 30,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    const Icon(
                      Icons.add,
                      color: Colors.black,
                      size: 30,
                    )
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                const Row(
                  children: [
                    FilterPlaylistAlbum(
                      text: 'Playlist',
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    FilterPlaylistAlbum(
                      text: "Album",
                    )
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          const Divider(
            color: Colors.black,
            thickness: 3,
            height: 0,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    const Row(
                      children: [
                        Row(
                          children: [
                            Icon(
                              CupertinoIcons.arrow_up_arrow_down,
                              size: 20,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              "Recents",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                        Expanded(child: SizedBox()),
                        Icon(Icons.list)
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    GridView.count(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      primary: false,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 20,
                      crossAxisCount: 3,
                      childAspectRatio: 2 / 3.5,
                      children: const <Widget>[
                        GridViewPlaylistAlbum(text: '日本の歌'),
                        GridViewPlaylistAlbum(
                            text:
                                'TV Anime "Haikyu!! Second Season" Original Soundtrack (Vol.1)'),
                        GridViewPlaylistAlbum(
                            text:
                                'TV Anime "Haikyu!! Second Season" Original Soundtrack (Vol.1)'),
                        GridViewPlaylistAlbum(text: '日本の歌'),
                        GridViewPlaylistAlbum(
                            text:
                                'TV Anime "Haikyu!! Second Season" Original Soundtrack (Vol.1)'),
                        GridViewPlaylistAlbum(text: '日本の歌'),
                        GridViewPlaylistAlbum(
                            text:
                                'TV Anime "Haikyu!! Second Season" Original Soundtrack (Vol.1)'),
                        GridViewPlaylistAlbum(text: '日本の歌'),
                        GridViewPlaylistAlbum(
                            text:
                                'TV Anime "Haikyu!! Second Season" Original Soundtrack (Vol.1)'),
                        GridViewPlaylistAlbum(text: '日本の歌'),
                        GridViewPlaylistAlbum(
                            text:
                                'TV Anime "Haikyu!! Second Season" Original Soundtrack (Vol.1)'),
                        GridViewPlaylistAlbum(text: '日本の歌'),
                        GridViewPlaylistAlbum(
                            text:
                                'TV Anime "Haikyu!! Second Season" Original Soundtrack (Vol.1)'),
                        GridViewPlaylistAlbum(text: '日本の歌'),
                      ],
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class FilterPlaylistAlbum extends StatelessWidget {
  const FilterPlaylistAlbum({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: 80,
      height: 35,
      decoration: BoxDecoration(
          color: HexColor('#ac8bc9'), borderRadius: BorderRadius.circular(50)),
      child: Text(
        text,
        style: TextStyle(
            fontSize: 14,
            color: HexColor('#fefffe'),
            fontWeight: FontWeight.bold),
      ),
    );
  }
}
