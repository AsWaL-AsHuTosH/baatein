import 'package:baatein/chat/friends_search_screen.dart';
import 'package:baatein/customs/friend_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendListScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.search, color: Colors.white),
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FreindSearchScreen(),
          ),
        ),
      ),
      body: Container(
        color: Theme.of(context).accentColor,
        child: StreamBuilder<QuerySnapshot>(
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
            return ListView(
              children: friendList,
            );
          },
        ),
      ),
    );
  }
}
