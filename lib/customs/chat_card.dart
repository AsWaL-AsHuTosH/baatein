import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:baatein/chat/chatroom_screen.dart';

class ChatCard extends StatelessWidget {
  final bool newMessage;
  final String lastMessage;
  final String friendName;
  final String friendEmail;
  final time;

  ChatCard(
      {this.friendName,
      this.newMessage = false,
      this.lastMessage,
      this.friendEmail,
      this.time});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
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
        decoration: BoxDecoration(
          gradient: newMessage
              ? LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  stops: [0.1, 0.5, 0.7, 0.9],
                  colors: [
                    Colors.green[500],
                    Colors.green[600],
                    Colors.green[700],
                    Colors.green[800],
                  ],
                )
              : LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  stops: [0.1, 0.5, 0.7, 0.9],
                  colors: [
                    Colors.red[300],
                    Colors.red[300],
                    Colors.red[300],
                    Colors.red[300],
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
        margin: EdgeInsets.symmetric(vertical: 1.0, horizontal: 1.0),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StreamBuilder<QuerySnapshot>(
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
                return CircleAvatar(
                  child: url != null ? null : Icon(Icons.person),
                  backgroundImage: url != null ? NetworkImage(url) : null,
                  radius: 30,
                );
              },
            ),
            SizedBox(
              width: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  friendName,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  lastMessage,
                  style: TextStyle(
                      color: Colors.black45,
                      fontSize: 15,
                      fontWeight: FontWeight.normal),
                ),
              ],
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                   time,
                    style: TextStyle(
                        color: Colors.black45,
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Icon(
                    newMessage ? Icons.sms : null,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
