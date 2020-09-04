import 'package:baatein/classes/SelectedUser.dart';
import 'package:baatein/constants/constants.dart';
import 'package:baatein/customs/friend_tile.dart';
import 'package:baatein/customs/round_text_button.dart';
import 'package:baatein/customs/search_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';

class GroupSetup extends StatefulWidget {
  final List<String> selected;
  GroupSetup({this.selected});
  @override
  _GroupSetupState createState() => _GroupSetupState();
}

class _GroupSetupState extends State<GroupSetup> {
  final TextEditingController controller = TextEditingController();

  final GlobalKey<FormState> _key = GlobalKey<FormState>();

  final Function validator = (val) {
    return val.trim().length < 3
        ? "Please enter atleast 3 character long name!"
        : null;
  };
  bool spin = false;

  File imageFile;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(left: 70),
          child: Text(
            'Baatein',
            style: TextStyle(
              fontFamily: 'DancingScript',
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
      body: ModalProgressHUD(
        inAsyncCall: spin,
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            GestureDetector(
              onTap: () async {
                final ImagePicker picker = ImagePicker();
                final PickedFile pickedImage =
                    await picker.getImage(source: ImageSource.gallery);
                if (pickedImage == null) return;
                setState(() {
                  imageFile = File(pickedImage.path);
                });
              },
              child: imageFile == null
                  ? CircleAvatar(
                      child: Icon(
                        Icons.photo_camera,
                        size: 30,
                      ),
                      radius: 50,
                    )
                  : CircleAvatar(
                      backgroundImage: AssetImage(imageFile.path),
                      radius: 50,
                    ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SearchField(
                hintText: 'Group Name',
                labelText: null,
                controller: controller,
                validator: validator,
                formKey: _key,
              ),
            ),
            Divider(
              color: Colors.grey,
              indent: 10,
              endIndent: 10,
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser.email)
                  .collection('friends')
                  .where('email', whereIn: widget.selected)
                  .snapshots(),
              builder: (context, snapshot) {
                List<FriendTile> list = [];
                if (snapshot.hasData) {
                  final friends = snapshot.data.docs;
                  if (friends != null) {
                    for (var friend in friends) {
                      String name = friend.data()['name'];
                      String email = friend.data()['email'];
                      list.add(
                        FriendTile(
                          friendName: name,
                          friendEmail: email,
                          disableMainOnTap: true,
                        ),
                      );
                    }
                  }
                }
                return Expanded(
                  child: ListView(
                    children: list,
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: RoundTextButton(
                text: 'Confirm Details',
                icon: Icons.arrow_forward,
                onPress: () async {
                  setState(() {
                    spin = true;
                  });
                  if (_key.currentState.validate()) {
                    FirebaseFirestore _firestore = FirebaseFirestore.instance;
                    FirebaseAuth _auth = FirebaseAuth.instance;
                    String id = Uuid().v4();
                    List<String> list =
                        Provider.of<SelectedUser>(context, listen: false)
                            .getList();
                    list.add(_auth.currentUser.email);
                    List<Map<String, String>> nameList =
                        Provider.of<SelectedUser>(context, listen: false)
                            .getNameList();
                    String myName = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser.email)
                        .get()
                        .then((doc) => doc.data()['name']);
                    nameList
                        .add({FirebaseAuth.instance.currentUser.email: myName});
                    await _firestore.collection('groups').doc(id).set({
                      'name': controller.text.trim(),
                      'search_name': controller.text.trim().toLowerCase(),
                      'admin': _auth.currentUser.email,
                      'members': list,
                      'members_name': nameList,
                      'id': id,
                      'last_message': null,
                      'read': null,
                      'type': null,
                      'time': null,
                    });
                    if (imageFile != null) {
                      final ref =
                          FirebaseStorage.instance.ref().child(id + '.jpg');
                      StorageUploadTask task = ref.putFile(imageFile);
                      StorageTaskSnapshot taskSnapshot = await task.onComplete;
                      String url = await taskSnapshot.ref.getDownloadURL();
                      _firestore
                          .collection('profile_pic')
                          .doc(id)
                          .collection('image')
                          .doc('image_url')
                          .set({'url': url});
                    } else {
                      await _firestore
                          .collection('profile_pic')
                          .doc(id)
                          .collection('image')
                          .doc('image_url')
                          .set({'url': kNoGroupPic});
                    }
                    for (String email
                        in Provider.of<SelectedUser>(context, listen: false)
                            .getList()) {
                      await _firestore
                          .collection('users')
                          .doc(_auth.currentUser.email)
                          .collection('friends')
                          .doc(email)
                          .update({'selected': false});
                    }
                    Provider.of<SelectedUser>(context, listen: false).clear();
                    setState(() {
                      spin = false;
                    });
                    Navigator.pop(context, true);
                  } else {
                    this.setState(() {
                      spin = false;
                    });
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
