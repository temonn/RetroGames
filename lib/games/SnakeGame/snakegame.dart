import 'dart:math'; // For generating random numbers
import 'dart:async'; // For creating a Timer
import 'package:neon_widgets/neon_widgets.dart'; // For creating neon widgets

import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';

import '../../Services/customAppBar.dart';
import '../../Services/failScreen.dart';

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
  final int rows = 20;
  final int columns = 20;
  late SharedPreferences prefs;
  int savedHighScore = 0;

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

  Future<void> _loadHighScore() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      savedHighScore = prefs.getInt('highScore') ?? 0;
    });
  }

  void _showFailScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final savedHighScore = prefs.getInt('highScore') ?? 0;

    final isPlayingAgain = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return FailScreen(score: score, highScore: savedHighScore);
      },
    );

    if (isPlayingAgain == true) {
      setState(() {
        isPlaying = true;
      });
      startGame();
    }
  }

  // Move the snake one step
  void _moveSnake() {
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
          prefs.setInt('highScore', score);
          savedHighScore = score;
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
