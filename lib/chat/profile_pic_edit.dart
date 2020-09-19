import 'dart:io';
import 'package:baatein/constants/constants.dart';
import 'package:baatein/customs/round_icon_button.dart';
import 'package:baatein/provider/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';

class ProfileEditScreen extends StatefulWidget {
  final String docId;
  ProfileEditScreen({@required this.docId});

  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  FirebaseService _firebase;
  bool spin = false;
  
  @override
  void initState() {
    super.initState();
    initFirebaseService();
  }

  void initFirebaseService() =>
      _firebase = Provider.of<FirebaseService>(context, listen: false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: spin,
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                  stream: _firebase.firestore
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
                      .child(widget.docId + '.jpg');
                  final File file = File(pickedImage.path);
                  StorageUploadTask task = ref.putFile(file);
                  StorageTaskSnapshot taskSnapshot = await task.onComplete;
                  String url = await taskSnapshot.ref.getDownloadURL();
                  _firebase.firestore
                      .collection('profile_pic')
                      .doc(widget.docId)
                      .collection('image')
                      .doc('image_url')
                      .update({'url': url});

                  Flushbar(
                    message: "Your profile picture is updated successfully.",
                    margin: EdgeInsets.all(8),
                    borderRadius: 8,
                    icon: Icon(
                      Icons.check_circle,
                      color: Colors.blue[300],
                      size: 20,
                    ),
                    duration: Duration(seconds: 1),
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
