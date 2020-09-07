import 'package:baatein/customs/group_chatcard_builder.dart';
import 'package:baatein/customs/search_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class GroupSearchScreen extends StatefulWidget {
  static const String routeId = 'group_search_screen';
  @override
  _GroupSearchScreenState createState() => _GroupSearchScreenState();
}

class _GroupSearchScreenState extends State<GroupSearchScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String data1;
  String data2;

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
      backgroundColor: Theme.of(context).accentColor,
      body: ModalProgressHUD(
        inAsyncCall: spin,
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: SearchField(
                  hintText: 'Type group name......',
                  labelText: null,
                  onChangeCallback: (value) {
                    setState(() {
                      if (value == null || value.isEmpty) {
                        data1 = 'a';
                        data2 = String.fromCharCode('z'.codeUnitAt(0) + 1);
                      } else {
                        data1 = value;
                        data1 = data1.trim().toLowerCase();
                        int lastChar = data1.codeUnitAt(data1.length - 1);
                        String last = String.fromCharCode(lastChar + 1);
                        data2 = data1.substring(0, data1.length - 1) + last;
                      }
                    });
                  },
                ),
              ),
              SizedBox(
                height: 5,
              ),
              StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('users')
                    .doc(_auth.currentUser.email)
                    .collection('groups')
                    .where('search_name', isGreaterThanOrEqualTo: data1)
                    .where('search_name', isLessThan: data2)
                    .orderBy('search_name')
                    .snapshots(),
                builder: (context, snapshot) {
                  List<GroupChatCardBuilder> friendList = [];
                  if (snapshot.hasData) {
                    final groups = snapshot.data.docs;
                    if (groups != null) {
                      for (var group in groups) {
                        String id = group.data()['id'];
                        friendList.add(
                          GroupChatCardBuilder(
                            spinFalse: spinFalse,
                            spinTrue: spinTrue,
                            groupId: id,
                          ),
                        );
                      }
                    }
                  }
                  return Expanded(
                    child: ListView(
                      children: friendList,
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
