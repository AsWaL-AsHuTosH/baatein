import 'package:baatein/chat/image_preview_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class MessageField extends StatelessWidget {
  // final Function validator;
  final Function imageButtonCallback;
  final Color color = Colors.white;
  final TextEditingController controller;
  MessageField({@required this.controller, @required this.imageButtonCallback});
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
      child: Row(
        children: [
          Expanded(
            child: Container(
              constraints: BoxConstraints(maxHeight: 100),
              child: TextFormField(
                keyboardType: TextInputType.multiline,
                maxLines: null,
                controller: controller,
                decoration: InputDecoration(
                  errorStyle: TextStyle(
                    fontSize: 10,
                  ),
                  hintText: 'Type message here',
                  hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
                  labelStyle: TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                      backgroundColor: Colors.transparent),
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
            ),
          ),
          GestureDetector(
            onTap: imageButtonCallback,
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(
                Icons.add_photo_alternate,
                color: Colors.grey,
                size: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
