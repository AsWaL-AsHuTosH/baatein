import 'package:baatein/classes/SelectedUser.dart';
import 'package:baatein/constants/constants.dart';
import 'package:baatein/customs/friend_tile.dart';
import 'package:baatein/customs/round_text_button.dart';
import 'package:baatein/customs/search_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

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

  @override
  Widget build(BuildContext context) {
    bool spin = false;
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
            CircleAvatar(
              child: Icon(
                Icons.photo_camera,
                size: 30,
              ),
              radius: 50,
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
                    final List<String> list =
                        Provider.of<SelectedUser>(context, listen: false)
                            .getList();
                    list.add(_auth.currentUser.email);
                    await _firestore.collection('groups').doc(id).set({
                      'name': controller.text.trim(),
                      'search_name': controller.text.trim().toLowerCase(),
                      'admin': _auth.currentUser.email,
                      'members': list,
                      'id': id,
                      'lastMessage': null,
                      'read': null,
                    });
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
                    setState(() {
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
