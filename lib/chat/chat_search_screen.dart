import 'package:baatein/customs/chat_card.dart';
import 'package:baatein/customs/search_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:date_time_format/date_time_format.dart';

class ChatSearchScreen extends StatefulWidget {
  static const String routeId = 'chat_search_screen';
  @override
  _ChatSearchScreenState createState() => _ChatSearchScreenState();
}

class _ChatSearchScreenState extends State<ChatSearchScreen> {
  Stream<QuerySnapshot> myStream;
  String data1;
  String data2;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).accentColor,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: SearchField(
                hintText: 'Search a chat by name......',
                onChangeCallback: (value) {
                  setState(() {
                    if (value == null || value.isEmpty) {
                      data1 = 'a';
                      data2 = String.fromCharCode('z'.codeUnitAt(0) + 1);
                    } else {
                      data1 = value;
                      data1 = data1.trim().toLowerCase();
                      int lastChar = data1.codeUnitAt(data1.length - 1);
                      String last = String.fromCharCode(lastChar + 1);
                      data2 = data1.substring(0, data1.length - 1) + last;
                    }
                  });
                },
              ),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('users')
                  .doc(_auth.currentUser.email)
                  .collection('chats')
                  .where('search_name', isGreaterThanOrEqualTo: data1)
                  .where('search_name', isLessThan: data2)
                  .orderBy('search_name')
                  .snapshots(),
              builder: (context, snapshot) {
                List<ChatCard> chatList = [];
                if (snapshot.hasData) {
                  final chats = snapshot.data.docs;
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
                return Expanded(
                    child: ListView(
                  children: chatList,
                ));
              },
            )
          ],
        ),
      ),
    );
  }
}
