import 'package:flutter/material.dart';
import 'package:neon_widgets/neon_widgets.dart';
import 'package:summerproject/mainmenu.dart';

class FailScreen extends StatelessWidget {
  final int score;
  final int highScore;

  const FailScreen({Key? key, required this.score, required this.highScore})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          SizedBox(height: 8.0), // Adjust the spacing between the lines
          NeonText(
            text: "Your highest score is $highScore",
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
                Navigator.of(context)
                    .pop(true); // Pass `true` to indicate isPlaying is true
              },
            ),
          ],
        ),
      ],
    );
  }
}
