// import 'package:baatein/constants/constants.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:baatein/chat/chatroom_screen.dart';

class FriendTile extends StatelessWidget {
  final String friendName;
  // final FirebaseAuth _auth = FirebaseAuth.instance;
  // final FirebaseFirestore _firesotre = FirebaseFirestore.instance;
  FriendTile({@required this.friendName});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(1.0),
      padding: EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            child: Icon(Icons.person),
            radius: 30,
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: Text(
              friendName,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatRoom(
                    friendName: friendName,
                  ),
                ),
              );
             
            },
            child: CircleAvatar(
              child: Icon(
                Icons.chat,
                color: Colors.white,
              ),
              backgroundColor: Colors.red,
            ),
          )
        ],
      ),
      decoration: BoxDecoration(
        color: Color(0xffffccbc),
        borderRadius: BorderRadius.all(
          Radius.circular(15),
        ),
      ),
    );
  }
}
