import 'package:baatein/chat/group_search_screen.dart';
import 'package:baatein/chat/group_selection_screen.dart';
import 'package:baatein/customs/group_chatcard_builder.dart';
import 'package:baatein/customs/round_text_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class GroupChatScreen extends StatefulWidget {
  @override
  _GroupChatScreenState createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool spin = false;

  void spinTrue() {
    setState(() {
      spin = true;
    });
  }

  void spinFalse() {
    setState(() {
      spin = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: spin,
        child: Container(
          color: Theme.of(context).accentColor,
          child: Column(
            children: [
              StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('users')
                    .doc(_auth.currentUser.email)
                    .collection('groups')
                    .snapshots(),
                builder: (context, snaps) {
                  List<GroupChatCardBuilder> groupList = [];
                  if (snaps.hasData) {
                    var groups;
                    if (snaps.data != null) groups = snaps.data.docs;
                    if (groups != null) {
                      for (var group in groups) {
                        String id = group.data()['id'];
                        groupList.add(
                          GroupChatCardBuilder(
                            groupId: id,
                            spinFalse: spinFalse,
                            spinTrue: spinTrue,
                          ),
                        );
                      }
                    }
                  }
                  return Expanded(
                    child: ListView(
                      children: groupList,
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.only(right: 80.0, bottom: 18),
                child: RoundTextButton(
                  text: 'Create Group',
                  icon: Icons.group,
                  onPress: () async {
                    var ok = await Navigator.pushNamed(
                        context, GroupSelectionScreen.routeId);
                    if (ok != null && ok == true) {
                      Flushbar(
                        message: "Group created successfully.",
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
                      return;
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
