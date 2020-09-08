import 'package:baatein/chat/search_sheet.dart';
import 'package:baatein/customs/friend_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendListScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(
          Icons.person_add,
          color: Colors.white,
        ),
        onPressed: () async {
          bool sent = await showModalBottomSheet(
            context: context,
            builder: (context) => SearchSheet(),
          );
          if (sent == null) return;
          if (sent) {
            Flushbar(
              message: "Your reuest is sent successfully.",
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
          }
        },
      ),
      body: Container(
        color: Theme.of(context).accentColor,
        child: Column(
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('users')
                  .doc(_auth.currentUser.email)
                  .collection('friends')
                  .orderBy('name', descending: false)
                  .snapshots(),
              builder: (context, snaps) {
                List<FriendTile> friendList = [];
                if (snaps.hasData) {
                  final friends = snaps.data.docs;
                  if (friends != null) {
                    for (var friend in friends) {
                      String name = friend.data()['name'];
                      String email = friend.data()['email'];
                      friendList.add(FriendTile(
                        friendName: name,
                        friendEmail: email,
                      ));
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
    );
  }
}
