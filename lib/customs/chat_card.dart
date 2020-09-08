import 'package:baatein/chat/profile_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:baatein/chat/chatroom_screen.dart';

class ChatCard extends StatelessWidget {
  final bool newMessage, isImage;
  final String lastMessage;
  final String friendName;
  final String friendEmail;
  final time;

  ChatCard(
      {@required this.friendName,
      @required this.newMessage,
      @required this.lastMessage,
      @required this.friendEmail,
      @required this.time,
      @required this.isImage});
  Widget message() {
    return isImage
        ? Icon(Icons.image)
        : Text(
            lastMessage,
            style: TextStyle(
                color: newMessage ? Colors.black : Colors.black45,
                fontSize: 15,
                fontWeight: newMessage ? FontWeight.bold : FontWeight.normal,),
          );
  }
  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
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
          margin: EdgeInsets.symmetric(vertical: 1.0, horizontal: 1.0),
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileView(
                      isFriend: true,
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
                    return CircleAvatar(
                      child: url != null ? null : Icon(Icons.person),
                      backgroundImage: url != null ? NetworkImage(url) : null,
                      radius: 30,
                    );
                  },
                ),
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
                  message(),
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
                          color: newMessage ? Colors.black: Colors.black45,
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Icon(
                      newMessage ? Icons.sms : null,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
