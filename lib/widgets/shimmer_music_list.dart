import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerMusicList extends StatelessWidget {
  const ShimmerMusicList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          for (int i = 0; i < 10; i++) const ShimmerLoading(),
        ],
      ),
    );
  }
}

class ShimmerLoading extends StatelessWidget {
  const ShimmerLoading({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        children: [
          SizedBox(
            height: 70,
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      margin: const EdgeInsets.only(left: 18),
                      child: Container(
                        width: 25,
                        height: 25,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                    Container(
                        width: 40,
                        height: 40,
                        margin: const EdgeInsets.only(right: 5),
                        child: ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(5)),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        )),
                    const SizedBox(
                      width: 2,
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 230,
                            height: 30,
                            alignment: Alignment.centerLeft,
                            child: Container(
                                width: double.infinity,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.circular(5),
                                )),
                          ),
                          SizedBox(
                            width: 230,
                            height: 20,
                            child: Row(
                              children: [
                                Container(
                                  alignment: Alignment.centerLeft,
                                  width: 10,
                                  height: 30,
                                  child: Icon(
                                    Icons.audiotrack_outlined,
                                    color: HexColor('#b4b5b4'),
                                    size: 15,
                                  ),
                                ),
                                const SizedBox(
                                  width: 7,
                                ),
                                Expanded(
                                    child: Container(
                                        width: 30,
                                        height: 30,
                                        alignment: Alignment.centerLeft,
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 95,
                                              height: 15,
                                              decoration: BoxDecoration(
                                                color: Colors.grey,
                                                borderRadius:
                                                    BorderRadius.circular(3),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 8,
                                            ),
                                            Expanded(
                                              child: Container(
                                                  height: 15,
                                                  decoration: BoxDecoration(
                                                    color: const Color.fromARGB(
                                                        255, 255, 0, 0),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            3),
                                                  )),
                                            )
                                          ],
                                        ))),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    IconButton(
                      highlightColor: Colors.black.withValues(alpha: 0.02),
                      icon: Icon(
                        Icons.more_vert_sharp,
                        size: 30,
                        color: HexColor('#b5b5b4'),
                      ),
                      onPressed: () {},
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
          )
        ],
      ),
    );
  }
}
