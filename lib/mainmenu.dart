import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:neon_widgets/neon_widgets.dart';
import 'package:summerproject/Services/login.dart';
import 'package:summerproject/games/SnakeGame/snakegame.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'games/Pong/pong.dart';
import 'Services/customAppBar.dart';
import 'games/Tetris/tetris.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({Key? key}) : super(key: key);

  @override
  _MainMenuState createState() => _MainMenuState();
}

const List<String> list = <String>['Snake', 'Tetris'];
String dropdownValue = list.first;

class _MainMenuState extends State<MainMenu> {
  List<dynamic> leaderboardData = [];

  @override
  void initState() {
    super.initState();
    fetchLeaderboardData().then((data) {
      setState(() {
        leaderboardData = data;
      });
    });
  }

  void updateLeaderboardData() {
    fetchLeaderboardData().then((data) {
      setState(() {
        leaderboardData = data;
      });
    });
  }

Future<List<dynamic>> fetchLeaderboardData() async {
  if (dropdownValue == "Snake") {
    DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
        .collection("games")
        .doc("Snake")
        .get();
    Map<String, dynamic>? data = docSnapshot.data() as Map<String, dynamic>?;
    List<dynamic> leaderboard = data?['leaderboard'] ?? [];
    leaderboard.sort((a, b) => b['highscore'].compareTo(a['highscore']));
    return leaderboard;
  } else if (dropdownValue == "Tetris") {
    DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
        .collection("games")
        .doc("Tetris")
        .get();
    Map<String, dynamic>? data = docSnapshot.data() as Map<String, dynamic>?;
    List<dynamic> leaderboard = data?['leaderboard'] ?? [];
    leaderboard.sort((a, b) => b['highscore'].compareTo(a['highscore']));
    return leaderboard;
  } else {
    return [];
  }
}

  @override
  Widget build(BuildContext context) {
    List<Widget> slides = [
      Container(
        child: Column(
          children: [
            SizedBox(height: 10),
            NeonContainer(
              spreadColor: Colors.teal.shade200,
              borderColor: Colors.teal.shade50,
              containerColor: Colors.black,
              lightBlurRadius: 5,
              lightSpreadRadius: 5,
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                height: 580,
                width: 350,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                          'https://i.natgeofe.com/n/101c7d2c-d45a-4579-a63c-450c4bac73e4/snakes_06_square.jpg'),
                      fit: BoxFit.scaleDown,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            NeonContainer(
              lightSpreadRadius: 0,
              height: 50,
              borderWidth: 2,
              borderRadius: BorderRadius.circular(10),
              spreadColor: Colors.lightBlue.shade700,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SnakeGame()),
                  );
                },
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.transparent),
                ),
                child: FlickerNeonText(
                  text: 'Play',
                  flickerTimeInMilliSeconds: 1000,
                  randomFlicker: false,
                  spreadColor: Colors.lightBlue.shade700,
                ),
              ),
            ),
          ],
        ),
      ),
      Container(
        child: Column(
          children: [
            SizedBox(height: 10),
            NeonContainer(
              spreadColor: Colors.teal.shade200,
              borderColor: Colors.teal.shade50,
              containerColor: Colors.black,
              lightBlurRadius: 5,
              lightSpreadRadius: 5,
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                height: 580,
                width: 350,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                          'https://s.hdnux.com/photos/01/31/65/24/23549203/3/rawImage.jpg'),
                      fit: BoxFit.scaleDown,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            NeonContainer(
              lightSpreadRadius: 0,
              height: 50,
              borderWidth: 2,
              borderRadius: BorderRadius.circular(10),
              spreadColor: Colors.lightBlue.shade700,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PongGame()),
                  );
                },
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.transparent),
                ),
                child: FlickerNeonText(
                  text: 'Play',
                  flickerTimeInMilliSeconds: 1000,
                  randomFlicker: false,
                  spreadColor: Colors.lightBlue.shade700,
                ),
              ),
            ),
          ],
        ),
      ),
      Container(
        child: Column(
          children: [
            SizedBox(height: 10),
            NeonContainer(
              spreadColor: Colors.teal.shade200,
              borderColor: Colors.teal.shade50,
              containerColor: Colors.black,
              lightBlurRadius: 5,
              lightSpreadRadius: 5,
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                height: 580,
                width: 350,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                          'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9c/Typical_Tetris_Game.svg/1200px-Typical_Tetris_Game.svg.png'),
                      fit: BoxFit.scaleDown,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            NeonContainer(
              lightSpreadRadius: 0,
              height: 50,
              borderWidth: 2,
              borderRadius: BorderRadius.circular(10),
              spreadColor: Colors.lightBlue.shade700,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TetrisGame()),
                  );
                },
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.transparent),
                ),
                child: FlickerNeonText(
                  text: 'Play',
                  flickerTimeInMilliSeconds: 1000,
                  randomFlicker: false,
                  spreadColor: Colors.lightBlue.shade700,
                ),
              ),
            ),
          ],
        ),
      ),

      // LeaderBoard starts here
      Container(
          child: Column(
        children: [
          SizedBox(height: 10),
          NeonContainer(
            spreadColor: Colors.teal.shade200,
            borderColor: Colors.teal.shade50,
            containerColor: Colors.black,
            lightBlurRadius: 5,
            lightSpreadRadius: 5,
            borderRadius: BorderRadius.circular(10),
            height: 580,
            width: 350,
            child: Column(
              children: [
                SizedBox(height: 5),
                NeonText(text: 'Leaderboard', textSize: 24),
                SizedBox(height: 5),
                NeonLine(
                  lineWidth: MediaQuery.of(context).size.width * 0.9,
                  lineHeight: MediaQuery.of(context).size.height * 0.0015,
                  lightBlurRadius: 1,
                  lightSpreadRadius: 1,
                  spreadColor: Colors.teal.shade200,
                ),
                DropdownButton<String>(
                  value: dropdownValue,
                  icon: const Icon(Icons.arrow_downward),
                  elevation: 16,
                  style:
                      const TextStyle(color: Colors.deepPurple, fontSize: 20),
                  underline: Container(
                    width: 0,
                    height: 2,
                    color: Colors.deepPurpleAccent,
                  ),
                  onChanged: (String? value) {
                    // This is called when the user selects an item.
                    setState(() {
                      dropdownValue = value!;
                    });
                    updateLeaderboardData();
                  },
                  items: list.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Container(
                        width: MediaQuery.of(context).size.width *
                            0.6, // Adjust the width as needed
                        child: Text(value),
                      ),
                    );
                  }).toList(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(width: 1),
                    NeonText(
                      text: 'User',
                      textSize: 24,
                    ),
                    SizedBox(width: 80),
                    NeonText(
                      text: 'Highscore',
                      textSize: 24,
                    ),
                    SizedBox(width: 1),
                  ],
                ),
                SizedBox(height: 20),
                GridView.builder(
                  shrinkWrap: true,
                  itemCount: leaderboardData.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 5,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(1),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          NeonText(
                            text: leaderboardData[index]['username'],
                            textSize: 20,
                          ),
                          SizedBox(height: 10),
                          NeonText(
                            text: "${leaderboardData[index]['highscore']}",
                            textSize: 20,
                          ),
                        ],
                      ),
                    );
                  },
                )
              ],
            ),
          ),
          SizedBox(height: 16),
          NeonContainer(
            lightSpreadRadius: 0,
            height: 50,
            borderWidth: 2,
            borderRadius: BorderRadius.circular(10),
            spreadColor: Colors.lightBlue.shade700,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.transparent),
              ),
              child: FlickerNeonText(
                text: 'Join the leaderboard!',
                flickerTimeInMilliSeconds: 1000,
                randomFlicker: false,
                spreadColor: Colors.lightBlue.shade700,
              ),
            ),
          ),
        ],
      )),
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: CustomAppBar(title: 'Menu'),
      body: Center(
        child: CarouselSlider(
          items: slides,
          options: CarouselOptions(
            height: double.infinity,
            viewportFraction: 1.0,
            enableInfiniteScroll: false,
          ),
        ),
      ),
    );
  }
}
