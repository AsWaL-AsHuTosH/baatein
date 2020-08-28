import 'package:baatein/customs/friend_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';


class FriendListScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).accentColor,
      child: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('users').doc(_auth.currentUser.email).collection('friends').snapshots(),
        builder: (context, snaps){
          List<FriendTile> friendList = [];
          if(snaps.hasData){
            final friends = snaps.data.docs;
            for(var friend in friends){
              String name = friend.data()['name'];
              friendList.add(FriendTile(friendName: name));
            } 
          }
          return ListView(children: friendList,);
        },
      ),
    );
  }
}