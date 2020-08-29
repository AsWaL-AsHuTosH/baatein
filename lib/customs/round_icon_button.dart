import 'package:flutter/material.dart';

class RoundIconButton extends StatelessWidget {
  final IconData icon;
  final Function onPress;
  RoundIconButton(
      {@required this.icon,
      @required this.onPress,
      });
  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      shape: CircleBorder(),
      fillColor: Colors.blue,
      elevation: 5,
      constraints: BoxConstraints.tightFor(
        width: 50.0,
        height: 60.0,
      ),
      child: Icon(
        icon,
        color: Colors.white,
      ),
      onPressed: onPress,
    );
  }
}
