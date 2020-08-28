import 'package:baatein/customs/chat_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatOverviewScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firesotre = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 1.0),
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: StreamBuilder<QuerySnapshot>(
        stream: _firesotre
            .collection('users')
            .doc(_auth.currentUser.email)
            .collection('chats')
            .snapshots(),
        builder: (context, snapshot) {
          List<ChatCard> chatList = [];
          print('hello');
          if (snapshot.hasData) {
            print('hasData');
            final chats = snapshot.data.docs;
            if (chats.isNotEmpty) {
              print('ops');
              for (var chat in chats) {
                String name = chat.data()['name'];
                print(name);
                chatList.add(
                  ChatCard(newMessage: false, name: name),
                );
              }
            }
          }
          return ListView(
            children: chatList,
          );
        },
      ),
    );
  }
}
