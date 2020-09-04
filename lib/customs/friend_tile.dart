import 'package:baatein/constants/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:baatein/chat/chatroom_screen.dart';
import 'package:baatein/chat/profile_view.dart';

class FriendTile extends StatelessWidget {
  final String friendName;
  final String friendEmail;
  final bool readOnly;
  final bool special;
  FriendTile(
      {@required this.friendName,
      this.friendEmail,
      this.readOnly = false,
      this.special = false});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: readOnly
          ? () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileView(
                    friendEmail: friendEmail,
                    friendName: friendName,
                  ),
                ),
              )
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
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileView(
                    friendEmail: friendEmail,
                    friendName: friendName,
                  ),
                ),
              ),
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
          ],
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            stops: [0.1, 0.5, 0.7, 0.9],
            colors: [
              Colors.red[300],
              Colors.red[400],
              Colors.red[600],
              Colors.red[800],
            ],
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(15),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              blurRadius: 1.0,
              color: Colors.black,
              offset: Offset(0.0, 1.0),
            )
          ],
        ),
      ),
    );
  }
}
