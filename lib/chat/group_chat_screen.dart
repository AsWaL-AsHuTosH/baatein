import 'package:baatein/chat/group_selection_screen.dart';
import 'package:baatein/customs/group_chatcard_builder.dart';
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(
          Icons.group,
          color: Colors.white,
        ),
        onPressed: () async {
          var ok =
              await Navigator.pushNamed(context, GroupSelectionScreen.routeId);
          if (ok != null && ok == true) {
            Flushbar(
              message: "Group created successfully.",
              margin: EdgeInsets.all(8),
              borderRadius: 8,
              icon: Icon(
                Icons.check_circle,
                color: Colors.blue[300],
                size: 20,
              ),
              duration: Duration(seconds: 1),
            ).show(context);
            return;
          }
        },
      ),
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
            ],
          ),
        ),
      ),
    );
  }
}
