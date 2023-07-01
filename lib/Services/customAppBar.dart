import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:neon_widgets/neon_widgets.dart';
import 'package:summerproject/Services/login.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final double height;

  CustomAppBar({required this.title, this.height = kToolbarHeight});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        final isLoggedIn = user != null;

        return Container(
          decoration: const BoxDecoration(
            color: Colors.black,
            boxShadow: [
              BoxShadow(
                color: Colors.black,
                blurRadius: 2.0,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                height: height - 5,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Center(
                        child: NeonText(
                          text: title,
                          spreadColor: Colors.lightBlue.shade700,
                          blurRadius: 5,
                          textSize: 30,
                          fontWeight: FontWeight.w600,
                          textColor: Colors.lightBlue.shade700,
                        ),
                      ),
                    ),
                    if (isLoggedIn)
                      IconButton(
                        icon: Icon(
                          Icons.logout,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor:
                                    const Color.fromARGB(255, 39, 37, 37),
                                title: Center(
                                  child: NeonText(
                                    text: "Logout Confirmation",
                                    spreadColor:
                                        const Color.fromARGB(255, 30, 67, 233),
                                    blurRadius: 20,
                                    textSize: 19,
                                    textColor: Colors.white,
                                  ),
                                ),
                                content: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    NeonText(
                                      text: "Are you sure you want to logout?",
                                      spreadColor: const Color.fromARGB(
                                          255, 30, 67, 233),
                                      blurRadius: 20,
                                      textSize: 15,
                                      textColor: Colors.white,
                                    ),
                                  ],
                                ),
                                actions: <Widget>[
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      TextButton(
                                        child: NeonText(
                                          text: "Cancel",
                                          spreadColor: const Color.fromARGB(
                                              255, 30, 67, 233),
                                          blurRadius: 20,
                                          textSize: 15,
                                          textColor: Colors.white,
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      TextButton(
                                        child: NeonText(
                                          text: "Yes",
                                          spreadColor: const Color.fromARGB(
                                              255, 30, 67, 233),
                                          blurRadius: 20,
                                          textSize: 15,
                                          textColor: Colors.white,
                                        ),
                                        onPressed: () {
                                          FirebaseAuth.instance.signOut();
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    if (!isLoggedIn)
                      IconButton(
                        icon: Icon(
                          Icons.login,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginPage()),
                          );
                        },
                      ),
                  ],
                ),
              ),
              NeonLine(
                lightSpreadRadius: 15,
                lineColor: Colors.white,
                lineHeight: 1,
                lineWidth: 600,
                margin: EdgeInsets.only(top: 2.0),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
