import 'package:flutter/material.dart';
import 'package:neon_widgets/neon_widgets.dart';
import 'package:summerproject/mainmenu.dart';

class QuitScreen extends StatelessWidget {

  const QuitScreen({Key? key})
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
            text: "Are you sure you want to quit?",
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
                text: "Yes",
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
                text: "No",
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
