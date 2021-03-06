import 'package:baatein/customs/chat_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:date_time_format/date_time_format.dart';

class ChatOverviewScreen extends StatelessWidget {
  final FirebaseFirestore _firesotre = FirebaseFirestore.instance;
  final String myEmail = FirebaseAuth.instance.currentUser.email;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 1.0),
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: _firesotre
              .collection('users')
              .doc(myEmail)
              .collection('chats')
              .orderBy('time', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            List<ChatCard> chatList = [];
            if (snapshot.hasData) {
              final chats = snapshot.data.docs;
              if (chats != null) {
                for (var chat in chats) {
                  String friendName = chat.data()['name'];
                  String lastMessage = chat.data()['last_message'];
                  bool newMessage = chat.data()['new_message'];
                  String friendEmail = chat.data()['email'];
                  Timestamp stamp = chat.data()['time'];
                  bool imageMessage = chat.data()['type'] == 'img';
                  String time =
                      DateTimeFormat.format(stamp.toDate(), format: 'h:i a');
                  chatList.add(
                    ChatCard(
                        newMessage: newMessage,
                        friendName: friendName,
                        lastMessage: lastMessage,
                        friendEmail: friendEmail,
                        time: time,
                        isImage: imageMessage),
                  );
                }
              }
            }
            return ListView(
              children: chatList,
            );
          },
        ),
      ),
    );
  }
}
