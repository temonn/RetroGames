import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:neon_widgets/neon_widgets.dart';

class Leaderboard extends StatefulWidget {
  const Leaderboard({Key? key}) : super(key: key);

  @override
  _LeaderboardState createState() => _LeaderboardState();
}

class _LeaderboardState extends State<Leaderboard> {
  List<Widget> items = [
    Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(height: 15, width: 90, color: Colors.amber),
        Container(height: 15, width: 90, color: Colors.blue),
        Container(height: 15, width: 90, color: Colors.yellow),
      ],
    ),
    NeonContainer(
      height: 580,
      width: 350,
      child: Container(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      items: items,
      options: CarouselOptions(
        height: double.infinity,
        viewportFraction: 1.0,
        enableInfiniteScroll: false,
      ),
    );
  }
}
