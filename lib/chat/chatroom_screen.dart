import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:baatein/constants/constants.dart';
import 'package:baatein/customs/round_text_field.dart';
import 'package:baatein/customs/message.dart';

class ChatRoom extends StatefulWidget {
  final friendName;
  ChatRoom({this.friendName});
  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firesotre = FirebaseFirestore.instance;
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              child: Icon(Icons.person),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              widget.friendName,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: _firesotre
                  .collection('users')
                  .doc(_auth.currentUser.email)
                  .collection('chats')
                  .doc(widget.friendName)
                  .collection('messages').orderBy('time', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                List<Message> messageList = [];
                if (snapshot.hasData) {
                  final messages = snapshot.data.docs;
                  if (messages.isNotEmpty) {
                    for (var message in messages) {
                      String mess = message.data()['message'];
                      String sender = message.data()['sender'];
                      messageList.add(
                        Message(
                          message: mess,
                          isMe: sender == _auth.currentUser.email,
                        ),
                      );
                    }
                  }
                }
                return Expanded(
                  child: ListView(
                    reverse: true,
                    children: messageList,
                  ),
                );
              },
            ),
            Container(
              child: Row(
                children: [
                  Expanded(
                    child: RoundTextField(
                      color: Colors.black,
                      controller: controller,
                    ),
                  ),
                  SizedBox(
                    width: 5.0,
                  ),
                  RaisedButton(
                    child: Text('Send'),
                    onPressed: () {
                      if (controller.text.isEmpty) return;
                      final time = DateTime.now().millisecondsSinceEpoch;
                      //adding message to current user database
                      _firesotre
                          .collection('users')
                          .doc(_auth.currentUser.email)
                          .collection('chats')
                          .doc(widget.friendName)
                          .set(
                        {'name': widget.friendName},
                      );
                      _firesotre
                          .collection('users')
                          .doc(_auth.currentUser.email)
                          .collection('chats')
                          .doc(widget.friendName)
                          .collection('messages')
                          .add(
                        {
                          'message': controller.text,
                          'sender': _auth.currentUser.email,
                          'time': time,
                        },
                      );
                      //adding message to friend database
                      _firesotre
                          .collection('users')
                          .doc(widget.friendName)
                          .collection('chats')
                          .doc(_auth.currentUser.email)
                          .set(
                        {'name': _auth.currentUser.email},
                      );
                      _firesotre
                          .collection('users')
                          .doc(widget.friendName)
                          .collection('chats')
                          .doc(_auth.currentUser.email)
                          .collection('messages')
                          .add(
                        {
                          'message': controller.text,
                          'sender': _auth.currentUser.email,
                          'time': time,
                        },
                      );

                      controller.clear();
                    },
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
