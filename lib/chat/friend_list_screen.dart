import 'package:baatein/chat/search_sheet.dart';
import 'package:baatein/customs/friend_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendListScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String myEmail = FirebaseAuth.instance.currentUser.email;
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
              margin: EdgeInsets.all(8),
              borderRadius: 8,
              icon: Icon(
                Icons.check,
                color: Colors.blue[300],
                size: 20,
              ),
              duration: Duration(seconds: 1),
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
                  .doc(myEmail)
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
