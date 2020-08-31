import 'package:baatein/customs/message_text_field.dart';
import 'package:baatein/customs/round_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:baatein/constants/constants.dart';
import 'package:baatein/customs/round_text_field.dart';
import 'package:baatein/customs/message.dart';
import 'package:date_time_format/date_time_format.dart';

class ChatRoom extends StatefulWidget {
  final String friendName;
  final String friendEmail;
  ChatRoom({this.friendName, this.friendEmail});
  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firesotre = FirebaseFirestore.instance;
  final TextEditingController controller = TextEditingController();
  String myName;

  @override
  void initState() {
    super.initState();
    getName();
  }

  Future<void> getName() async {
    myName = await _firesotre
        .collection('users')
        .doc(_auth.currentUser.email)
        .get()
        .then((doc) => doc.data()['name']);
  }

  Future<void> setReadFalse() async {
    var doc = await _firesotre
        .collection('users')
        .doc(_auth.currentUser.email)
        .collection('chats')
        .doc(widget.friendEmail)
        .get();
    Map<String, dynamic> map = doc.data();
    if(map == null)
      return;
    map['new_message'] = false;
    await _firesotre
        .collection('users')
        .doc(_auth.currentUser.email)
        .collection('chats')
        .doc(widget.friendEmail)
        .update(map);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
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
                  .doc(widget.friendEmail)
                  .collection('messages')
                  .orderBy('time', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                setReadFalse();
                List<Message> messageList = [];
                if (snapshot.hasData) {
                  final messages = snapshot.data.docs;
                  if (messages != null) {
                    for (var message in messages) {
                      String mess = message.data()['message'];
                      String sender = message.data()['sender'];
                      Timestamp stamp = message.data()['time'];
                      String time = DateTimeFormat.format(stamp.toDate(), format: 'h:i a');
                      messageList.add(
                        Message(
                          message: mess,
                          isMe: sender == _auth.currentUser.email,
                          time: time,
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
              padding: EdgeInsets.all(5),
              child: Row(
                children: [
                  Expanded(
                    child: MessageField(
                      controller: controller,
                    ),
                  ),
                  SizedBox(
                    width: 5.0,
                  ),
                  RoundIconButton(icon: Icons.send, onPress: (){
                      if (controller.text.trim().isEmpty)return;
                      DateTime time = DateTime.now();
                      String lastMessage = controller.text.trim().length <= 25 ? controller.text.trim() : controller.text.substring(0, 25) + "...";
                      //adding message to current user database
                      _firesotre
                          .collection('users')
                          .doc(_auth.currentUser.email)
                          .collection('chats')
                          .doc(widget.friendEmail)
                          .set(
                        {
                          'email': widget.friendEmail,
                          'name': widget.friendName,
                          'last_message': lastMessage,
                          'new_message': false,
                          'time': time,
                        },
                      );
                      _firesotre
                          .collection('users')
                          .doc(_auth.currentUser.email)
                          .collection('chats')
                          .doc(widget.friendEmail)
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
                          .doc(widget.friendEmail)
                          .collection('chats')
                          .doc(_auth.currentUser.email)
                          .set(
                        {
                          'email': _auth.currentUser.email,
                          'name': myName,
                          'last_message': lastMessage,
                          'new_message': true,
                          'time': time,
                        },
                      );
                     _firesotre
                          .collection('users')
                          .doc(widget.friendEmail)
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
                    },)
                
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
