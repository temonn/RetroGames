import 'dart:async';
import 'package:flutter/material.dart';
import 'package:neon_widgets/neon_widgets.dart';

import '../../Services/customAppBar.dart';

class PongGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: PongScreen(),
        ),
      ),
    );
  }
}

class PongScreen extends StatefulWidget {
  @override
  _PongScreenState createState() => _PongScreenState();
}

class _PongScreenState extends State<PongScreen> {
  double racketOnePosition = 5; // Position of the AI paddle
  double racketTwoPosition = 5; // Position of the AI paddle
  double racketSpeed = 5; // The speed of the players paddle
  double AIracketSpeed = 3; // The speed of the AIs paddle
  double racketWidth = 10; // width of the paddles
  double racketHeight = 60; // height of the paddles

  // Position, size and speed of the ball
  double ballX = 0;
  double ballY = 0;
  double ballSize = 10;
  double ballSpeedX = 3;
  double ballSpeedY = 3;

  int playerOneScore = 0;
  int playerTwoScore = 0;

  String scored = 'Player';
  bool gameStarted = false;

  Timer? _racketMovementTimer;

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    racketOnePosition = 160;
    racketTwoPosition = 160;
    ballX = 200;
    ballY = 200;
    ballSpeedX = 3;
    ballSpeedY = 0;
    playerOneScore = 0;
    playerTwoScore = 0;

    Timer.periodic(Duration(milliseconds: 16), (timer) {
      updateGameState();
    });
  }

  void updateGameState() {
    setState(() {
      // Update ball position
      ballX += ballSpeedX;
      ballY += ballSpeedY;

      // Determine the height and width of the container so that the game is scalable
      double containerHeight =
          MediaQuery.of(context).size.height * 0.6 - ballSize;
      double containerWidth =
          MediaQuery.of(context).size.width - racketWidth - ballSize;

      // Check collision with racket one
      if (ballX - ballSize / 2 <= racketWidth &&
          ballY + ballSize / 2 >= racketOnePosition &&
          ballY - ballSize / 2 <= racketOnePosition + racketHeight) {
        // Calculate impact factor based on where the ball hits the paddle
        double impactFactor = (ballY - (racketOnePosition + racketHeight / 2)) /
            (racketHeight / 2);

        // Update ball speed and direction based on impact factor
        ballSpeedX = -ballSpeedX;
        ballSpeedY = impactFactor * 5;
      }

      // Check collision with racket two
      if (ballX + ballSize / 2 >= containerWidth - racketWidth - ballSize &&
          ballY + ballSize / 2 >= racketTwoPosition &&
          ballY - ballSize / 2 <= racketTwoPosition + racketHeight) {
        // Calculate impact factor based on where the ball hits the paddle
        double impactFactor = (ballY - (racketTwoPosition + racketHeight / 2)) /
            (racketHeight / 2);

        // Update ball speed and direction based on impact factor
        ballSpeedX = -ballSpeedX;
        ballSpeedY = impactFactor * 5;
      }

      // Check collision with top and bottom walls
      if (ballY - ballSize / 2 <= 0 ||
          ballY + ballSize / 2 >= containerHeight) {
        ballSpeedY = -ballSpeedY;
      }

      // Check if the ball goes out of bounds
      if (ballX <= -10) {
        playerTwoScore++;
        scored = 'Player';
        resetBall();
      } else if (ballX >= containerWidth + 10) {
        playerOneScore++;
        scored = 'AI';
        resetBall();
      }

      // AI logic to control the first racket
      if (ballY < racketOnePosition + racketHeight / 2) {
        racketOnePosition -= AIracketSpeed;
      } else if (ballY > racketOnePosition + racketHeight / 2) {
        racketOnePosition += AIracketSpeed;
      }

      //Check boundary collision for the AIs racket
      if (racketOnePosition < 0) {
        racketOnePosition = 0;
      } else if (racketOnePosition + racketHeight > containerHeight) {
        racketOnePosition = containerHeight - racketHeight;
      }
    });
  }

  // If a point is scored this function is called
  void resetBall() {
    racketOnePosition = 160;
    racketTwoPosition = 160;

    // Check which player scored the last point,
    // The one who scored last gets to have the ball again
    if (scored == 'Player') {
      ballX = MediaQuery.of(context).size.width / 4;
      ballY = MediaQuery.of(context).size.height / 4;
      ballSpeedX = 3;
      ballSpeedY = 0;
    } else if (scored == 'AI') {
      ballX = MediaQuery.of(context).size.width / 4;
      ballY = MediaQuery.of(context).size.height / 4;
      ballSpeedX = -3;
      ballSpeedY = 0;
    }
  }

  // For moving the paddle
  void startRacketMovement(bool isMovingUp) {
    _racketMovementTimer = Timer.periodic(Duration(milliseconds: 16), (timer) {
      setState(() {
        if (isMovingUp) {
          if (racketTwoPosition - racketSpeed >= 0) {
            racketTwoPosition -= racketSpeed;
          }
        } else {
          final containerHeight = MediaQuery.of(context).size.height * 0.6;
          if (racketTwoPosition + racketHeight + racketSpeed <=
              containerHeight) {
            racketTwoPosition += racketSpeed;
          }
        }
      });
    });
  }

  void stopRacketMovement() {
    _racketMovementTimer?.cancel();
  }

  @override
  void dispose() {
    _racketMovementTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Pong'),
      body: Container(
        padding: const EdgeInsets.all(10),
        color: Colors.black,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            NeonContainer(
              height: MediaQuery.of(context).size.height * 0.6,
              spreadColor: Color(0xFF00008B),
              borderColor: Color.fromARGB(255, 2, 2, 194),
              containerColor: Colors.black,
              lightBlurRadius: 20,
              lightSpreadRadius: 10,
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: racketOnePosition,
                    child: Container(
                      width: racketWidth,
                      height: racketHeight,
                      color: Colors.white,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: racketTwoPosition,
                    child: Container(
                      width: racketWidth,
                      height: racketHeight,
                      color: Colors.white,
                    ),
                  ),
                  Positioned(
                    top: ballY,
                    left: ballX,
                    child: Container(
                      width: ballSize,
                      height: ballSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 16),
              color: Colors.transparent,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  NeonText(
                    text: 'AI: $playerOneScore',
                  ),
                  NeonLine(
                    spreadColor: const Color(0xFF00008B),
                    lightSpreadRadius: 30,
                    lightBlurRadius: 90,
                    lineWidth: 1,
                    lineHeight: 20,
                    lineColor: Color.fromARGB(255, 254, 254, 255),
                  ),
                  NeonText(
                    text: 'Player: $playerTwoScore',
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 50,
            ),
            Container(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTapDown: (_) {
                          startRacketMovement(true); // Start moving racket up
                        },
                        onTapUp: (_) {
                          stopRacketMovement(); // Stop moving racket
                        },
                        child: Container(
                          child: Icon(
                            Icons.arrow_upward,
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
                      GestureDetector(
                        onTapDown: (_) {
                          startRacketMovement(
                              false); // Start moving racket down
                        },
                        onTapUp: (_) {
                          stopRacketMovement(); // Stop moving racket
                        },
                        child: Container(
                          child: Icon(
                            Icons.arrow_downward,
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
