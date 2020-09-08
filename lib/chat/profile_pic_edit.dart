import 'dart:io';
import 'package:baatein/constants/constants.dart';
import 'package:baatein/customs/round_icon_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:photo_view/photo_view.dart';

class ProfileEditScreen extends StatefulWidget {
  final String docId;
  ProfileEditScreen({@required this.docId});

  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  bool spin = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ModalProgressHUD(
        inAsyncCall: spin,
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('profile_pic')
                      .doc(widget.docId)
                      .collection('image')
                      .snapshots(),
                  builder: (context, snapshot) {
                    String url;
                    if (snapshot.hasData) {
                      final image = snapshot.data.docs;
                      url = image[0].data()['url'];
                    }
                    if (url == null) url = kNoProfilePic;
                    return PhotoView(
                      imageProvider: NetworkImage(url),
                    );
                  }),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20, left: 5, right: 5),
              child: RoundIconButton(
                icon: Icons.edit,
                onPress: () async {
                  final ImagePicker picker = ImagePicker();
                  final PickedFile pickedImage =
                      await picker.getImage(source: ImageSource.gallery);
                  if (pickedImage == null) return;
                  setState(() {
                    spin = true;
                  });
                  final ref = FirebaseStorage.instance
                      .ref()
                      .child(FirebaseAuth.instance.currentUser.email + '.jpg');
                  final File file = File(pickedImage.path);
                  StorageUploadTask task = ref.putFile(file);
                  StorageTaskSnapshot taskSnapshot = await task.onComplete;
                  String url = await taskSnapshot.ref.getDownloadURL();
                  FirebaseFirestore.instance
                      .collection('profile_pic')
                      .doc(widget.docId)
                      .collection('image')
                      .doc('image_url')
                      .update({'url': url});
                  Flushbar(
                    message: "Your profile picture is updated successfully.",
                    backgroundGradient:
                        LinearGradient(colors: [Colors.red, Colors.orange]),
                    icon: Icon(
                      Icons.check,
                      color: Colors.green,
                      size: 40,
                    ),
                    margin: EdgeInsets.all(8),
                    borderRadius: 8,
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 3),
                    boxShadows: [
                      BoxShadow(
                        color: Colors.lightBlueAccent,
                        offset: Offset(0.0, 2.0),
                        blurRadius: 3.0,
                      )
                    ],
                  ).show(context);
                  setState(() {
                    spin = false;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
