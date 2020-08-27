import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RoundTextField extends StatelessWidget {
  final String labelText;
  final Color color;
  final double radius;
  final bool obscureText;
  final Function validator;
  final TextEditingController controller;
  RoundTextField({
    this.labelText,
    this.radius = 10,
    this.validator,
    this.color = Colors.white,
    this.obscureText = false,
    this.controller,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: TextFormField(
        validator: validator,
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          errorStyle: TextStyle(
            fontSize: 10,
          ),
          labelText: labelText,
          labelStyle: TextStyle(
              color: Colors.grey, backgroundColor: Colors.transparent),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(radius),
            ),
            borderSide: BorderSide(color: color, width: 2.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(radius),
            ),
            borderSide: BorderSide(color: color, width: 2.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(radius),
            ),
            borderSide: BorderSide(color: color, width: 0.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(radius),
            ),
            borderSide: BorderSide(color: color, width: 0.0),
          ),
        ),
      ),
    );
  }
}
