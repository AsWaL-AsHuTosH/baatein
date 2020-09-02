import 'package:baatein/customs/friend_tile.dart';
import 'package:baatein/customs/search_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FreindSearchScreen extends StatefulWidget {
  @override
  _ChatSearchScreenState createState() => _ChatSearchScreenState();
}

class _ChatSearchScreenState extends State<FreindSearchScreen> {
  Stream<QuerySnapshot> myStream;
  String data1;
  String data2;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).accentColor,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: SearchField(
                hintText: 'Search......',
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
            StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('users')
                  .doc(_auth.currentUser.email)
                  .collection('friends')
                  .where('search_name', isGreaterThanOrEqualTo: data1)
                  .where('search_name', isLessThan: data2).orderBy('search_name')
                  .snapshots(),
              builder: (context, snapshot) {
                List<FriendTile> friendList = [];
                if (snapshot.hasData) {
                  final friends = snapshot.data.docs;
                  for (var friend in friends) {
                    String name = friend.data()['name'];
                    String email = friend.data()['email'];
                    friendList.add(FriendTile(
                      friendName: name,
                      friendEmail: email,
                    ));
                  }
                }
                return Expanded(
                    child: ListView(
                  children: friendList,
                ));
              },
            )
          ],
        ),
      ),
    );
  }
}
