import 'dart:io';
import 'package:baatein/customs/imagePre_text_field.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImagePreviewScreen extends StatelessWidget {
  final TextEditingController controller;
  final File imageFile;
  ImagePreviewScreen({this.imageFile, this.controller});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Expanded(
            child: PhotoView(
              imageProvider: AssetImage(imageFile.path),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20, left: 5, right: 5),
            child: Row(
              children: [
                Expanded(
                  child: MessageFieldIP(
                    controller: controller,
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context, true);
                  },
                  child: CircleAvatar(
                    radius: 25,
                    child: Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
