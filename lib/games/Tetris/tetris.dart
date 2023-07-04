import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:neon_widgets/neon_widgets.dart';
import 'package:summerproject/Services/customAppBar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../mainmenu.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

class TetrisGame extends StatelessWidget {
  const TetrisGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tetris',
      home: TetrisBoard(),
    );
  }
}

class TetrisBoard extends StatefulWidget {
  @override
  _TetrisBoardState createState() => _TetrisBoardState();
}

class _TetrisBoardState extends State<TetrisBoard> {
  final String userId = FirebaseAuth.instance.currentUser?.uid ?? ''; // If a user is logged in gets the users id from Firebase
  final int numRows = 15; // Determines how tall/how many rows the gamefield has
  final int numCols = 10; // Determines how wide/how many columns the gamefield has
  List<List<Color>> board = []; // Represents the game board as a 2D list of colors
  List<List<bool>> piece = []; // Represents the current falling piece as a 2D list of booleans
  List<List<int>> containerState = []; // Stores the state of the container
  Point<int> piecePosition = Point(0, 0); // Represents the position of the falling piece on the board
  Timer? timer; // Timer for controlling the game loop
  bool gameOver = false; // Indicates if the game is over
  bool _isFailScreenDisplayed = false; // Indicates if the fail screen is displayed
  var colorFinal; // Stores the final color for the piece 
  late SharedPreferences prefs; // Shared preferences for storing high score in the phone
  int savedHighScore = 0; // The saved high score
  int score = 0; // The current score


  @override
  void initState() {
    super.initState();
    _loadHighScore();
    initializeBoard();
    startGame();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  // Initialize the game board
  void initializeBoard() {
    board = List<List<Color>>.generate(
      numRows,
      (_) => List<Color>.filled(numCols, Colors.black),
    );

    containerState = List<List<int>>.generate(
      numRows,
      (_) => List<int>.filled(numCols, 0),
    );
  }

  void startGame() {
    gameOver = false;
    score = 0;
    spawnPiece();
    startTimer();
  }

  void startTimer() {
    timer?.cancel();
    timer = Timer.periodic(Duration(milliseconds: 300), (_) {
      setState(() {
        if (!movePieceDown()) {
          lockPiece();
          clearLines();
          if (!gameOver) {
            spawnPiece();
          } else {
            timer?.cancel();
          }
        }
      });
    });
  }

  // Update user data
  void updateData() async {
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
          .doc("Tetris")
          .get()
          .then((docSnapshot) {
        List<dynamic> leaderboard = docSnapshot.data()?['leaderboard'] ?? [];

        bool usernameExists = false;
        int indexToUpdate = -1;

    // Go through the "leaderboard" array in Firestore to see if the user is already in it
        for (int i = 0; i < leaderboard.length; i++) {
          if (leaderboard[i]['username'] == username) {
            usernameExists = true;
            indexToUpdate = i; // Get the array value to update
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
            .doc("Tetris")
            .set({
              "leaderboard": leaderboard,
            }, SetOptions(merge: true))
            .then((_) => print("User data updated successfully!"))
            .catchError((error) => print("Failed to update user data: $error"));
      });
    }
  }

  void spawnPiece() {

    //Determine the different pieces shapes
    final pieces = [
      [
        [true, true, true, true]
      ],
      [
        [true, true],
        [true, true]
      ],
      [
        [true, true, true],
        [false, false, true]
      ],
      [
        [true, true, true],
        [true, false, false]
      ],
      [
        [true, true, true],
        [false, true, false]
      ],
      [
        [true, true, false],
        [false, true, true]
      ],
      [
        [false, true, true],
        [true, true, false]
      ],
      [
        [false, true, true],
        [false, false, true]
      ],
      [
        [true, true, false],
        [true, false, false]
      ],
    ];
    final random = Random();
    final index = random.nextInt(pieces.length);
    piece = List<List<bool>>.from(pieces[index]);
    final colors = [Colors.blue, Colors.red, Colors.yellow, Colors.purple];
    final colorIndex = random.nextInt(colors.length); // Apply randomly a color from the 4 given options
    final color = colors[colorIndex];
    colorFinal = color;
    piecePosition = Point<int>((numCols - piece[0].length) ~/ 2, 0); // Determine the pieces first position

    // Apply the random color to the piece
    for (int row = 0; row < piece.length; row++) {
      for (int col = 0; col < piece[row].length; col++) {
        if (piece[row][col]) {
          board[piecePosition.y + row][piecePosition.x + col] = color;
          print("Row: ${piecePosition.y + row}, Col: ${piecePosition.x + col}");
        }
      }
    }
    score += 10;
    placePiece();
  }

  // For moving the peices down
  bool movePieceDown() {
    final nextPosition = Point(piecePosition.x, piecePosition.y + 1); 
    if (isValidPosition(piece, nextPosition)) {
      setState(() {
        // Clear the previous position of the piece
        clearPiece();

        // Update the piece position
        piecePosition = nextPosition;

        // Place the piece at the new position on the board
        placePiece();
      });
      return true;
    }
    return false;
  }

  // For rotating pieces
  void rotatePiece() {
    final List<List<bool>> rotatedPiece = List.generate(
      piece[0].length,
      (col) => List.generate(piece.length, (row) => false),
    );

    for (int row = 0; row < piece.length; row++) {
      for (int col = 0; col < piece[row].length; col++) {
        rotatedPiece[col][piece.length - 1 - row] = piece[row][col];
      }
    }

    if (isValidPosition(rotatedPiece, piecePosition)) {
      setState(() {
        clearPiece();
        piece = rotatedPiece;
        placePiece();
      });
    }
  }

  void moveLeft() {
    final nextPosition = Point(piecePosition.x - 1, piecePosition.y);
    if (isValidPosition(piece, nextPosition)) {
      setState(() {
        // Clear the previous position of the piece
        clearPiece();

        // Update the piece position
        piecePosition = nextPosition;

        // Place the piece at the new position on the board
        placePiece();
      });
    }
  }

  void moveRight() {
    final nextPosition = Point(piecePosition.x + 1, piecePosition.y);
    if (isValidPosition(piece, nextPosition)) {
      setState(() {
        // Clear the previous position of the piece
        clearPiece();

        // Update the piece position
        piecePosition = nextPosition;

        // Place the piece at the new position on the board
        placePiece();
      });
    }
  }


  void placePiece() {
    for (int row = 0; row < piece.length; row++) {
      for (int col = 0; col < piece[row].length; col++) {
        if (piece[row][col]) {
          // Places the pieces colors where the piece is
          board[piecePosition.y + row][piecePosition.x + col] = colorFinal;
          // Sets the containerState to 1 where the pieces is located
          containerState[piecePosition.y + row][piecePosition.x + col] = 1;
        }
      }
    }
  }

  void clearPiece() {
    for (int row = 0; row < piece.length; row++) {
      for (int col = 0; col < piece[row].length; col++) {
        if (piece[row][col]) {
          // changes the color back to black when the piece is cleared
          board[piecePosition.y + row][piecePosition.x + col] = Colors.black;
          // Sets the containerState to 0 where the pieces was
          containerState[piecePosition.y + row][piecePosition.x + col] = 0;
        }
      }
    }
  }

  // For checking if the pieces postion is valid
  bool isValidPosition(List<List<bool>> piece, Point<int> position) {
    for (int row = 0; row < piece.length; row++) {
      for (int col = 0; col < piece[row].length; col++) {
        if (piece[row][col]) {
          final int boardRow = position.y + row;
          final int boardCol = position.x + col;

          if (boardRow >= numRows ||
              boardCol < 0 ||
              boardCol >= numCols ||
              (containerState[boardRow][boardCol] == 1 &&
                  !isPartOfPiece(boardRow, boardCol))) {
            return false;
          }
        }
      }
    }
    return true;
  }

  bool isPartOfPiece(int row, int col) {
    for (int pieceRow = 0; pieceRow < piece.length; pieceRow++) {
      for (int pieceCol = 0; pieceCol < piece[pieceRow].length; pieceCol++) {
        if (piece[pieceRow][pieceCol] &&
            piecePosition.y + pieceRow == row &&
            piecePosition.x + pieceCol == col) {
          return true;
        }
      }
    }
    return false;
  }

  void lockPiece() {
    final color = colorFinal;

    for (int row = 0; row < piece.length; row++) {
      for (int col = 0; col < piece[row].length; col++) {
        if (piece[row][col]) {
          board[piecePosition.y + row][piecePosition.x + col] = color;
          checkGameOver();
        }
      }
    }
  }

  // For checking if the game is over
  void checkGameOver() {
    int topRow = 0;

    for (int col = 0; col < piece[topRow].length; col++) {
      if (piece[topRow][col] &&
          ((piecePosition.y + topRow == 0) &&
              (piecePosition.y + topRow < numRows - 1 &&
                  containerState[piecePosition.y + topRow + 1]
                          [piecePosition.x + col] ==
                      1))) {
        // If the game is over we declare  gameOver = true, save the current highscore and show the Failcreen
        setState(() {
          gameOver = true;
          if (score > savedHighScore) {
            // Save the new high score
            prefs.setInt('highScore_$userId', score);
            savedHighScore = score;
          }
          _showFailScreen();
        });
        timer?.cancel();
        return;
      }
    }
  }

  // For clearing lines if a row is completely full
  void clearLines() {
    List<int> fullRows = [];

    for (int row = numRows - 1; row >= 0; row--) {
      if (board[row].every((cell) => cell != Colors.black)) {
        fullRows.add(row);
      }
    }

    if (fullRows.isNotEmpty) {
      setState(() {
        for (int row in fullRows) {
          board.removeAt(row);
          board.insert(0, List<Color>.filled(numCols, Colors.black));
          containerState.removeAt(row);
          containerState.insert(0, List<int>.filled(numCols, 0));
        }

        score += 50; // Increment score by the number of cleared lines

        if (score > savedHighScore) {
          // Save the new high score
          prefs.setInt('highScore_$userId', score);
          savedHighScore = score;
          updateData();
        }
      });
    }
  }

  // For getting the highscore from Firestore
  Future<void> _loadHighScore() async {
    prefs = await SharedPreferences.getInstance();

    User? currentUser = FirebaseAuth.instance.currentUser; // 

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

        for (int i = 0; i < leaderboard.length; i++) {
          if (leaderboard[i]['username'] == username) {
            savedHighScore = leaderboard[i]['highscore'];
            break;
          }
        }

        setState(() {
          savedHighScore =
              savedHighScore ?? prefs.getInt('highScore_$userId') ?? 0;
        });
      });
    } else {
      setState(() {
        savedHighScore = prefs.getInt('highScore_$userId') ?? 0;
      });
    }
  }

  // If game over thsi scren will be shown to the user
  void _showFailScreen() async {
    if (_isFailScreenDisplayed) {
      return;
    }

    _isFailScreenDisplayed = true;

    User? currentUser = FirebaseAuth.instance.currentUser;

    int highScoreFromPrefs = prefs.getInt('highScore_$userId') ?? 0;
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
          .doc("Tetris")
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
    
    int displayedHighScore = highScoreFromFirestore > highScoreFromPrefs
        ? highScoreFromFirestore
        : highScoreFromPrefs;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 39, 37, 37),
          title: Center(
            child: NeonText(
              text: "You lost :(",
              spreadColor: const Color.fromARGB(255, 30, 67, 233),
              blurRadius: 20,
              textSize: 19,
              textColor: Colors.white,
            ),
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              NeonText(
                text: "Your score was $score",
                spreadColor: const Color.fromARGB(255, 30, 67, 233),
                blurRadius: 20,
                textSize: 15,
                textColor: Colors.white,
              ),
              SizedBox(height: 8.0),
              NeonText(
                text: "Your highest score is $displayedHighScore",
                spreadColor: const Color.fromARGB(255, 30, 67, 233),
                blurRadius: 20,
                textSize: 15,
                textColor: Colors.white,
              ),
            ],
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  child: NeonText(
                    text: "Return to menu",
                    spreadColor: const Color.fromARGB(255, 30, 67, 233),
                    blurRadius: 20,
                    textSize: 15,
                    textColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MainMenu()),
                    );
                  },
                ),
                TextButton(
                  child: NeonText(
                    text: "Try again",
                    spreadColor: const Color.fromARGB(255, 30, 67, 233),
                    blurRadius: 20,
                    textSize: 15,
                    textColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _isFailScreenDisplayed = false;
                    startGame();
                    initializeBoard();
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Tetris'),
      backgroundColor: Colors.black,
      body: Container(
        padding: const EdgeInsets.all(10),
        color: Colors.black,
        child: Column(
          children: [
            GridView.builder(
              shrinkWrap: true,
              itemCount: numRows * numCols,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: numCols,
              ),
              itemBuilder: (BuildContext context, int index) {
                final row = index ~/ numCols;
                final col = index % numCols;
                final color = board[row][col];
                final state = containerState[row][col];

                return NeonContainer(
                  spreadColor: Color(0xFF00008B),
                  borderColor: Color.fromARGB(255, 2, 2, 194),
                  borderWidth: 1,
                  containerColor: state == 1 ? color : Colors.black,
                  lightBlurRadius: 1,
                  lightSpreadRadius: 1,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(),
                );
              },
            ),
            SizedBox(height: 10),
            Container(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTapDown: (_) {
                                moveLeft();
                              },
                              onTapUp: (_) {},
                              child: Container(
                                child: Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                ),
                                padding: EdgeInsets.all(22),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color.fromARGB(255, 0, 0, 0),
                                  border: Border.all(
                                    color: const Color.fromARGB(
                                        255, 241, 233, 233),
                                    width: 2.0,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 40),
                            GestureDetector(
                              onTapDown: (_) {
                                moveRight();
                              },
                              onTapUp: (_) {},
                              child: Container(
                                child: Icon(
                                  Icons.arrow_forward,
                                  color: Colors.white,
                                ),
                                padding: EdgeInsets.all(22),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color.fromARGB(255, 0, 0, 0),
                                  border: Border.all(
                                    color: const Color.fromARGB(
                                        255, 241, 233, 233),
                                    width: 2.0,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTapDown: (_) {
                          rotatePiece();
                        },
                        onTapUp: (_) {},
                        child: Container(
                          child: Icon(
                            Icons.replay,
                            color: Colors.white,
                          ),
                          padding: EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color.fromARGB(255, 0, 0, 0),
                            border: Border.all(
                              color: const Color.fromARGB(255, 241, 233, 233),
                              width: 2.0,
                            ),
                          ),
                        ),
                      ),
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
