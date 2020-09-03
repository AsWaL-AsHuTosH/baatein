import 'package:baatein/customs/message_text_field.dart';
import 'package:baatein/customs/round_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:baatein/customs/message.dart';
import 'package:date_time_format/date_time_format.dart';
import 'package:image_picker/image_picker.dart';
import 'image_preview_screen.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:baatein/customs/photo_message.dart';
import 'package:uuid/uuid.dart';
import 'package:baatein/chat/profile_view.dart';
import 'dart:io';

class GroupChatRoom extends StatefulWidget {
  final String friendName;
  final String friendEmail;
  GroupChatRoom({this.friendName, this.friendEmail});
  @override
  _GroupChatScreenState createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatRoom> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController controller = TextEditingController();
  final TextEditingController imageMessageController = TextEditingController();

  String myName;

  @override
  void initState() {
    super.initState();
    getName();
  }

  Future<void> getName() async {
    myName = await _firestore
        .collection('users')
        .doc(_auth.currentUser.email)
        .get()
        .then((doc) => doc.data()['name']);
  }

  Future<void> setNewMessageFalse() async {
    var doc = await _firestore
        .collection('users')
        .doc(_auth.currentUser.email)
        .collection('chats')
        .doc(widget.friendEmail)
        .get();
    Map<String, dynamic> map = doc.data();
    if (map == null) return;
    map['new_message'] = false;
    await _firestore
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
        elevation: 10,
        title: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileView(
                    friendEmail: widget.friendEmail,
                    friendName: widget.friendName,
                  ),
                ),
              ),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('profile_pic')
                    .doc(widget.friendEmail)
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
                    radius: 25,
                  );
                },
              ),
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
              stream: _firestore
                  .collection('users')
                  .doc(_auth.currentUser.email)
                  .collection('chats')
                  .doc(widget.friendEmail)
                  .collection('messages')
                  .orderBy('time', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                setNewMessageFalse();
                List<Widget> messageList = [];
                if (snapshot.hasData) {
                  final messages = snapshot.data.docs;
                  if (messages != null) {
                    for (var message in messages) {
                      String mess = message.data()['message'];
                      String sender = message.data()['sender'];
                      Timestamp stamp = message.data()['time'];
                      String time = DateTimeFormat.format(stamp.toDate(),
                          format: 'h:i a');
                      if (message.data()['type'] == 'txt') {
                        messageList.add(
                          Message(
                            message: mess,
                            isMe: sender == _auth.currentUser.email,
                            time: time,
                          ),
                        );
                      } else {
                        String url = message.data()['image_url'];
                        messageList.add(
                          PhotoMessage(
                            message: mess,
                            isMe: sender == _auth.currentUser.email,
                            time: time,
                            photoUrl: url,
                          ),
                        );
                      }
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
                      imageButtonCallback: () async {
                        final ImagePicker picker = ImagePicker();
                        final PickedFile pickedImage =
                            await picker.getImage(source: ImageSource.gallery);
                        if (pickedImage == null) return;
                        final File imageFile = File(pickedImage.path);
                        bool send = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImagePreviewScreen(
                              imageFile: imageFile,
                              controller: imageMessageController,
                            ),
                          ),
                        );
                        if (send != null && send == true) {
                          String imageId = Uuid().v4();
                          final ref = FirebaseStorage.instance
                              .ref()
                              .child(imageId + '.jpg');
                          StorageUploadTask task = ref.putFile(imageFile);
                          StorageTaskSnapshot taskSnapshot =
                              await task.onComplete;
                          String url = await taskSnapshot.ref.getDownloadURL();
                          String lastMessage;
                          DateTime time = DateTime.now();
                          if (imageMessageController.text == null ||
                              imageMessageController.text.trim().isEmpty) {
                            lastMessage = '';
                          } else {
                            lastMessage =
                                imageMessageController.text.trim().length <= 25
                                    ? imageMessageController.text.trim()
                                    : imageMessageController.text
                                            .substring(0, 25) +
                                        "...";
                          }
                          _firestore
                              .collection('users')
                              .doc(_auth.currentUser.email)
                              .collection('chats')
                              .doc(widget.friendEmail)
                              .set(
                            {
                              'email': widget.friendEmail,
                              'name': widget.friendName,
                              'search_name': widget.friendName.toLowerCase(),
                              'last_message': lastMessage,
                              'new_message': false,
                              'time': time,
                              'type': 'img',
                            },
                          );
                          _firestore
                              .collection('users')
                              .doc(_auth.currentUser.email)
                              .collection('chats')
                              .doc(widget.friendEmail)
                              .collection('messages')
                              .add(
                            {
                              'message': imageMessageController.text.trim(),
                              'sender': _auth.currentUser.email,
                              'time': time,
                              'type': 'img',
                              'image_url': url,
                            },
                          );
                          //adding message to friend database
                          _firestore
                              .collection('users')
                              .doc(widget.friendEmail)
                              .collection('chats')
                              .doc(_auth.currentUser.email)
                              .set(
                            {
                              'email': _auth.currentUser.email,
                              'name': myName,
                              'search_name': myName.toLowerCase(),
                              'last_message': lastMessage,
                              'new_message': true,
                              'time': time,
                              'type': 'img',
                            },
                          );
                          _firestore
                              .collection('users')
                              .doc(widget.friendEmail)
                              .collection('chats')
                              .doc(_auth.currentUser.email)
                              .collection('messages')
                              .add(
                            {
                              'message': imageMessageController.text.trim(),
                              'sender': _auth.currentUser.email,
                              'time': time,
                              'type': 'img',
                              'image_url': url,
                            },
                          );
                          imageMessageController.clear();
                        }
                      },
                    ),
                  ),
                  SizedBox(
                    width: 5.0,
                  ),
                  RoundIconButton(
                    icon: Icons.send,
                    onPress: () {
                      if (controller.text.trim().isEmpty) return;
                      DateTime time = DateTime.now();
                      String lastMessage = controller.text.trim().length <= 25
                          ? controller.text.trim()
                          : controller.text.substring(0, 25) + "...";
                      //adding message to current user database
                      _firestore
                          .collection('users')
                          .doc(_auth.currentUser.email)
                          .collection('chats')
                          .doc(widget.friendEmail)
                          .set(
                        {
                          'email': widget.friendEmail,
                          'name': widget.friendName,
                          'search_name': widget.friendName.toLowerCase(),
                          'last_message': lastMessage,
                          'new_message': false,
                          'time': time,
                          'type': 'txt',
                        },
                      );
                      _firestore
                          .collection('users')
                          .doc(_auth.currentUser.email)
                          .collection('chats')
                          .doc(widget.friendEmail)
                          .collection('messages')
                          .add(
                        {
                          'message': controller.text.trim(),
                          'sender': _auth.currentUser.email,
                          'time': time,
                          'type': 'txt',
                        },
                      );
                      //adding message to friend database
                      _firestore
                          .collection('users')
                          .doc(widget.friendEmail)
                          .collection('chats')
                          .doc(_auth.currentUser.email)
                          .set(
                        {
                          'email': _auth.currentUser.email,
                          'name': myName,
                          'search_name': myName.toLowerCase(),
                          'last_message': lastMessage,
                          'new_message': true,
                          'time': time,
                          'type': 'txt',
                        },
                      );
                      _firestore
                          .collection('users')
                          .doc(widget.friendEmail)
                          .collection('chats')
                          .doc(_auth.currentUser.email)
                          .collection('messages')
                          .add(
                        {
                          'message': controller.text.trim(),
                          'sender': _auth.currentUser.email,
                          'time': time,
                          'type': 'txt',
                        },
                      );
                      controller.clear();
                    },
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}