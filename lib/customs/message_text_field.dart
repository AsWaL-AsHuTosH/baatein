import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MessageField extends StatelessWidget {
  // final Function validator;
  final Color color = Colors.white;
  final TextEditingController controller;
  MessageField({this.controller});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
      color: Colors.white,
           borderRadius: BorderRadius.all(Radius.circular(30)),
        boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Colors.black, blurRadius: 1.0, offset: Offset(0.0, 1.0))
            ],
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          errorStyle: TextStyle(
            fontSize: 10,
          ),
          hintText: 'Type message here',
          hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
          labelStyle: TextStyle(
            fontSize: 15,
              color: Colors.grey, backgroundColor: Colors.transparent),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(30),
            ),
            borderSide: BorderSide(color: color, width: 2.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(30),
            ),
            borderSide: BorderSide(color: color, width: 2.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(30),
            ),
            borderSide: BorderSide(color: color, width: 0.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(30),
            ),
            borderSide: BorderSide(color: color, width: 0.0),
          ),
        ),
      ),
    );
  }
}
