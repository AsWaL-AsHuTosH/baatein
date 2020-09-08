import 'package:baatein/constants/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:baatein/chat/chatroom_screen.dart';
import 'package:baatein/chat/profile_view.dart';

class FriendTile extends StatelessWidget {
  final String friendName;
  final String friendEmail;
  final bool readOnly;
  final bool special;
  final bool kick;
  final Function kickCallback;
  FriendTile({
    @required this.friendName,
    this.friendEmail,
    this.readOnly = false,
    this.special = false,
    this.kick = false,
    this.kickCallback,
  });
  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: readOnly
            ? () async {
                bool isFriend = await FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser.email)
                    .collection('friends')
                    .doc(friendEmail)
                    .get()
                    .then((value) => value.exists);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileView(
                      isFriend: isFriend,
                      friendEmail: friendEmail,
                      friendName: friendName,
                    ),
                  ),
                );
              }
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatRoom(
                      friendName: friendName,
                      friendEmail: friendEmail,
                    ),
                  ),
                );
              },
        child: Container(
          margin: EdgeInsets.all(3.0),
          padding: EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () async {
                  bool isFriend = await FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser.email)
                      .collection('friends')
                      .doc(friendEmail)
                      .get()
                      .then((value) => value.exists);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileView(
                        isFriend: isFriend,
                        friendEmail: friendEmail,
                        friendName: friendName,
                      ),
                    ),
                  );
                },
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('profile_pic')
                      .doc(friendEmail)
                      .collection('image')
                      .snapshots(),
                  builder: (context, snapshot) {
                    String url;
                    if (snapshot.hasData) {
                      final image = snapshot.data.docs;
                      url = image[0].data()['url'];
                    }
                    if (url == null) url = kNoProfilePic;
                    return CircleAvatar(
                      backgroundImage: NetworkImage(url),
                      radius: 30,
                    );
                  },
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      friendName,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      friendEmail,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        letterSpacing: 0.5,
                        fontSize: 10.0,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              special
                  ? Icon(
                      Icons.person_pin,
                    )
                  : Container(
                      width: 0,
                      height: 0,
                    ),
              kick
                  ? GestureDetector(
                      onTap: kickCallback,
                      child: Icon(Icons.exit_to_app),
                    )
                  : Container(
                      width: 0,
                      height: 0,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
