import 'package:flutter/material.dart';
import 'package:neon_widgets/neon_widgets.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final double height;

  CustomAppBar({required this.title, this.height = kToolbarHeight});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
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
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
