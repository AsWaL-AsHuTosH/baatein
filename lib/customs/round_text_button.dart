import 'package:flutter/material.dart';

class RoundTextButton extends StatelessWidget {
  final String text;
  final Color color;
  final Function onPress;
  final double height, width;
  RoundTextButton({@required this.text, this.color = Colors.blue, this.onPress, this.height = 40, this.width = 150});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black,
              spreadRadius: 0.3,
              blurRadius: 3,
              offset: Offset(0.0, 1.0),
            )
          ],
          color: color,
          borderRadius: BorderRadius.all(Radius.circular(18)),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
