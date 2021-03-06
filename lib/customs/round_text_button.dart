import 'package:flutter/material.dart';

class RoundTextButton extends StatelessWidget {
  final String text;
  final Color color;
  final Function onPress;
  final double margin;
  final IconData icon;
  RoundTextButton({
    @required this.text,
    this.color = Colors.blue,
    this.onPress,
    this.margin = 10,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top : 8.0, left: 20, right: 20,),
      child: RaisedButton(
        onPressed: onPress,
        color: color,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        child: Padding(
          padding: const EdgeInsets.only(
            top: 5,
            bottom: 5,
            left: 5,
            right: 5,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Center(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'DancingScript',
                  ),
                ),
              ),
              CircleAvatar(
                child: Icon(icon, color: Colors.grey),
                backgroundColor: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
