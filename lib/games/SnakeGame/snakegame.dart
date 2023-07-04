import 'dart:math';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:neon_widgets/neon_widgets.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';

import '../../Services/customAppBar.dart';
import '../../Services/failScreen.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

class SnakeGame extends StatelessWidget {
  const SnakeGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Snake Game',
      home: GamePage(),
    );
  }
}

class GamePage extends StatefulWidget {
  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  // Constants for the size of the game grid
  final int rows = 20; // Determines how tall/how many rows the gamefield has
  final int columns = 20; // Determines how wide/how many columns the gamefield has
  late SharedPreferences prefs;  // Shared preferences for storing high score in the phone
  int savedHighScore = 0; // The saved high score
  final String userId = FirebaseAuth.instance.currentUser?.uid ?? ''; // If a user is logged in gets the users id from Firebase

  // The four possible directions of the snake
  final List<Point<int>> directions = [
    Point(-1, 0), // left
    Point(0, -1), // up
    Point(1, 0), // right
    Point(0, 1), // down
  ];

  // The initial state of the game
  List<Point<int>> snake = [
    Point(10, 10),
    Point(10, 9),
    Point(10, 8),
  ];
  Point<int> food = Point(5, 5);
  Point<int> direction = Point(1, 0);
  bool isPlaying = true;
  int score = 0;
  Timer? _timer;

  // Initialize the game when the widget is first created
  @override
  void initState() {
    super.initState();
    startGame();
    _loadHighScore();
  }

  // Start a new game
  void startGame() {
    setState(() {
      snake = [
        Point(10, 10),
        Point(10, 9),
        Point(10, 8),
      ];
      food = _randomPoint();
      direction = Point(1, 0);
      score = 0;
    });
    isPlaying = true;
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer if it's active
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(milliseconds: 150), (timer) {
      if (isPlaying) {
        _moveSnake();
      } else {
        timer.cancel();
      }
    });
  }

// For getting the highscore from Firestore
  Future<void> _loadHighScore() async {
    prefs = await SharedPreferences.getInstance();

    User? currentUser = FirebaseAuth.instance.currentUser;

  // If a user is logged in this gets their data from firestore
    if (currentUser != null) {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

  // save user data as a Map
      Map<String, dynamic>? userData =
          userSnapshot.data() as Map<String, dynamic>?;
  
  // Get the logged in users username from Firestore
      final username = userData?['username'];

  // Add the users username and highcore to the leaderboard database
      FirebaseFirestore.instance
          .collection("games")
          .doc("Snake")
          .get()
          .then((docSnapshot) {
        List<dynamic> leaderboard = docSnapshot.data()?['leaderboard'] ?? [];

  // Go through the "leaderboard" array in Firestore to see if the user is already in it
        for (int i = 0; i < leaderboard.length; i++) {
          if (leaderboard[i]['username'] == username) {
            savedHighScore = leaderboard[i]['highscore'];
            break;
          }
        }

        setState(() {
          savedHighScore =
              savedHighScore ?? prefs.getInt('highScoreSnake_$userId') ?? 0;
        });
      });
    } else {
      setState(() {
        savedHighScore = prefs.getInt('highScoreSnake_$userId') ?? 0;
      });
    }
  }

  void _showFailScreen() async {
    final prefs = await SharedPreferences.getInstance();

    User? currentUser = FirebaseAuth.instance.currentUser;

    int highScoreFromPrefs = prefs.getInt('highScoreSnake_$userId') ?? 0;
    int highScoreFromFirestore = 0;

    if (currentUser != null) {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      Map<String, dynamic>? userData =
          userSnapshot.data() as Map<String, dynamic>?;

      final username = userData?['username'];

      DocumentSnapshot gameSnapshot = await FirebaseFirestore.instance
          .collection("games")
          .doc("Snake")
          .get();
      Map<String, dynamic>? gameData =
          gameSnapshot.data() as Map<String, dynamic>?;

      List<dynamic> leaderboard =
          gameData?['leaderboard'] as List<dynamic>? ?? [];

      for (int i = 0; i < leaderboard.length; i++) {
        if (leaderboard[i]['username'] == username) {
          highScoreFromFirestore = leaderboard[i]['highscore'];
          break;
        }
      }
    }

  // This displays the highscore based on which is higher the phones of firestores highscore
    int displayedHighScore = highScoreFromFirestore > highScoreFromPrefs
        ? highScoreFromFirestore
        : highScoreFromPrefs;

    final isPlayingAgain = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return FailScreen(score: score, highScore: displayedHighScore);
      },
    );

    if (isPlayingAgain == true) {
      setState(() {
        isPlaying = true;
      });
      startGame();
    }
  }

  void updateData() async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      Map<String, dynamic>? userData =
          userSnapshot.data() as Map<String, dynamic>?;

      final username = userData?['username'];

      FirebaseFirestore.instance
          .collection("games")
          .doc("Snake")
          .get()
          .then((docSnapshot) {
        List<dynamic> leaderboard = docSnapshot.data()?['leaderboard'] ?? [];

        bool usernameExists = false;
        int indexToUpdate = -1;

        for (int i = 0; i < leaderboard.length; i++) {
          if (leaderboard[i]['username'] == username) {
            usernameExists = true;
            indexToUpdate = i;
            break;
          }
        }

    // If the users username already exists in the array and the "highscore" value is less than
    // the currently saved highscore it gets updated
        if (usernameExists) {
          if (leaderboard[indexToUpdate]['highscore'] < savedHighScore) {
            leaderboard[indexToUpdate]['highscore'] = savedHighScore;
          }
        } else {
          leaderboard.add({
            "username": username,
            "highscore": savedHighScore,
          });
        }

        FirebaseFirestore.instance
            .collection("games")
            .doc("Snake")
            .set({
              "leaderboard": leaderboard,
            }, SetOptions(merge: true))
            .then((_) => print("User data updated successfully!"))
            .catchError((error) => print("Failed to update user data: $error"));
      });
    }
  }

  // Move the snake one step
  Future<void> _moveSnake() async {
    final head = snake.first + direction;
    Point<int> newHead;

    // Check if the snake hits the edge of the game grid
    if (head.x < 0) {
      newHead = Point(columns - 1, head.y);
    } else if (head.x >= columns) {
      newHead = Point(0, head.y);
    } else if (head.y < 0) {
      newHead = Point(head.x, rows - 1);
    } else if (head.y >= rows) {
      newHead = Point(head.x, 0);
    } else {
      newHead = head;
    }

    // Check if the snake hits itself
    if (_hitsBody(newHead)) {
      setState(() {
        isPlaying = false;
        _showFailScreen();
      });
      return;
    }

    // Move the snake and update the score if the snake eats the food
    setState(() {
      snake.insert(0, newHead);
      if (newHead == food) {
        score++;
        if (score > savedHighScore) {
          // Save the new high score
          prefs.setInt('highScoreSnake_$userId', score);
          savedHighScore = score;
          updateData();
        }
        food = _randomPoint();
      } else {
        snake.removeLast();
      }
    });
  }

  // Check if the snake hits a wall
  bool _isOutOfBounds(Point<int> point) {
    return point.x < 0 || point.x >= columns || point.y < 0 || point.y >= rows;
  }

  bool _hitsBody(Point<int> point) {
    return snake.skip(1).any((p) => p == point);
  }

  Point<int> _randomPoint() {
    final random = Random();
    return Point(random.nextInt(columns), random.nextInt(rows));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Snake Game'),
      body: Container(
        padding: const EdgeInsets.all(10),
        color: Colors.black,
        child: Column(
          children: [
            SizedBox(height: 16),
            NeonContainer(
              spreadColor: Color(0xFF00008B),
              borderColor: Color.fromARGB(255, 2, 2, 194),
              containerColor: Colors.black,
              lightBlurRadius: 20,
              lightSpreadRadius: 10,
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                child: GestureDetector(
                  child: GridView.builder(
                    shrinkWrap: true,
                    itemCount: rows * columns,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                    ),
                    itemBuilder: (context, index) {
                      final row = index ~/ columns;
                      final column = index % columns;
                      final point = Point(column, row);
                      final isSnake = snake.contains(point);
                      final isFood = point == food;

                      Widget child = Container();

                      if (isSnake) {
                        child = DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            color: Colors.green,
                          ),
                        );
                      } else if (isFood) {
                        child = DecoratedBox(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('images/apple2.png'),
                              fit: BoxFit.fill,
                            ),
                          ),
                        );
                      }

                      return GestureDetector(
                        onTap: () {
                          if (!isPlaying) {
                            startGame();
                          }
                        },
                        child: Container(
                          child: child,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            SizedBox(height: 60),
            Container(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(child: SizedBox()),
                      ElevatedButton(
                        onPressed: () {
                          if (direction != directions[3]) {
                            direction = directions[1];
                          }
                        },
                        child: Icon(Icons.arrow_upward),
                        style: ElevatedButton.styleFrom(
                          shape: StadiumBorder(
                            side: BorderSide(
                              color: const Color.fromARGB(255, 241, 233,
                                  233), // Define the border color
                              width: 2.0, // Define the border width
                            ),
                          ),
                          minimumSize: Size(100.0, 50.0),
                          padding: EdgeInsets.all(16.0),
                          backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                      Expanded(child: SizedBox()),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          if (direction != directions[2]) {
                            direction = directions[0];
                          }
                        },
                        child: Icon(Icons.arrow_back),
                        style: ElevatedButton.styleFrom(
                          shape: StadiumBorder(
                            side: BorderSide(
                              color: const Color.fromARGB(255, 241, 233,
                                  233), // Define the border color
                              width: 2.0, // Define the border width
                            ),
                          ),
                          minimumSize: Size(100.0, 50.0),
                          padding: EdgeInsets.all(16.0),
                          backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (direction != directions[0]) {
                            direction = directions[2];
                          }
                        },
                        child: Icon(Icons.arrow_forward),
                        style: ElevatedButton.styleFrom(
                          shape: StadiumBorder(
                            side: BorderSide(
                              color: const Color.fromARGB(255, 241, 233,
                                  233), // Define the border color
                              width: 2.0, // Define the border width
                            ),
                          ),
                          minimumSize: Size(100.0, 50.0),
                          padding: EdgeInsets.all(16.0),
                          backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(child: SizedBox()),
                      ElevatedButton(
                        onPressed: () {
                          if (direction != directions[1]) {
                            direction = directions[3];
                          }
                        },
                        child: Icon(Icons.arrow_downward),
                        style: ElevatedButton.styleFrom(
                          shape: StadiumBorder(
                            side: BorderSide(
                              color: const Color.fromARGB(255, 241, 233,
                                  233), // Define the border color
                              width: 2.0, // Define the border width
                            ),
                          ),
                          minimumSize: Size(100.0, 50.0),
                          padding: EdgeInsets.all(16.0),
                          backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                      Expanded(child: SizedBox()),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
