import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:neon_widgets/neon_widgets.dart';
import 'package:summerproject/Services/customAppBar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../mainmenu.dart';

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
  final int numRows = 15;
  final int numCols = 10;
  List<List<Color>> board = [];
  List<List<bool>> piece = [];
  List<List<int>> containerState = [];
  Point<int> piecePosition = Point(0, 0);
  Timer? timer;
  bool gameOver = false;
  bool _isFailScreenDisplayed = false;
  var colorFinal;
  late SharedPreferences prefs;
  int savedHighScore = 0;
  int score = 0;

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

  void spawnPiece() {
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
    ];
    final random = Random();
    final index = random.nextInt(pieces.length);
    piece = List<List<bool>>.from(pieces[index]);
    final colors = [Colors.blue, Colors.red, Colors.yellow, Colors.purple];
    final colorIndex = random.nextInt(colors.length);
    final color = colors[colorIndex];
    colorFinal = color;
    piecePosition = Point<int>((numCols - piece[0].length) ~/ 2, 0);

    // Apply the random color to the piece
    for (int row = 0; row < piece.length; row++) {
      for (int col = 0; col < piece[row].length; col++) {
        if (piece[row][col]) {
          board[piecePosition.y + row][piecePosition.x + col] = color;
          print("Row: ${piecePosition.y + row}, Col: ${piecePosition.x + col}");
        }
      }
    }

    placePiece();
  }

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
          board[piecePosition.y + row][piecePosition.x + col] = colorFinal;
          containerState[piecePosition.y + row][piecePosition.x + col] = 1;
        }
      }
    }
  }

  void clearPiece() {
    for (int row = 0; row < piece.length; row++) {
      for (int col = 0; col < piece[row].length; col++) {
        if (piece[row][col]) {
          board[piecePosition.y + row][piecePosition.x + col] = Colors.black;
          containerState[piecePosition.y + row][piecePosition.x + col] = 0;
          score++;
          if (score > savedHighScore) {
            // Save the new high score
            prefs.setInt('highScore', score);
            savedHighScore = score;
          }
        }
      }
    }
  }

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

  void checkGameOver() {
    int topRow = 0;

    for (int col = 0; col < piece[topRow].length; col++) {
      if (piece[topRow][col] &&
          ((piecePosition.y + topRow == 0) &&
              (piecePosition.y + topRow < numRows - 1 &&
                  containerState[piecePosition.y + topRow + 1]
                          [piecePosition.x + col] ==
                      1))) {
        setState(() {
          gameOver = true;
          _showFailScreen();
        });
        timer?.cancel();
        return;
      }
    }
  }

  void clearLines() {
    for (int row = numRows - 1; row >= 0; row--) {
      if (board[row].every((cell) => cell != Colors.black)) {
        setState(() {
          board.removeAt(row);
          board.insert(0, List<Color>.filled(numCols, Colors.black));
          containerState.removeAt(row);
          containerState.insert(0, List<int>.filled(numCols, 0));
        });
      }
    }
  }

  Future<void> _loadHighScore() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      savedHighScore = prefs.getInt('highScore') ?? 0;
    });
  }

  void _showFailScreen() async {
    if (_isFailScreenDisplayed) {
      return;
    }

    _isFailScreenDisplayed = true;

    final prefs = await SharedPreferences.getInstance();
    final savedHighScore = prefs.getInt('highScore') ?? 0;

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
                text: "Your highest score is $savedHighScore",
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
