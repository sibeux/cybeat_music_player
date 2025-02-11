import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class ListPlaylistContainer extends StatelessWidget {
  const ListPlaylistContainer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: HexColor('#f1f1f1'),
              borderRadius: BorderRadius.circular(5),
            ),
            child: const Center(
              child: Icon(
                Icons.add,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'IndoPride',
                maxLines: 1,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black.withOpacity(0.8),
                  overflow: TextOverflow.ellipsis,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Row(
                children: [
                  Icon(
                    Icons.push_pin,
                    size: 16,
                    color: HexColor('#8238be'),
                  ),
                  Text(
                    '1089 songs',
                    maxLines: 1,
                    style: TextStyle(
                      color: HexColor('#313031'),
                      overflow: TextOverflow.ellipsis,
                      fontSize: 12,
                    ),
                  ),
                ],
              )
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.check_circle,
              color: HexColor('#8238be'),
            ),
          ),
        ],
      ),
    );
  }
}
