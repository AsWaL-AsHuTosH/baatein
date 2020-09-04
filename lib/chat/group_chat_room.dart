import 'package:baatein/chat/group_profile_view.dart';
import 'package:baatein/constants/constants.dart';
import 'package:baatein/customs/group_message.dart';
import 'package:baatein/customs/group_photo_message.dart';
import 'package:baatein/customs/message_text_field.dart';
import 'package:baatein/customs/round_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:date_time_format/date_time_format.dart';
import 'package:image_picker/image_picker.dart';
import 'image_preview_screen.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';

class GroupChatRoom extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String admin;
  GroupChatRoom({this.groupName, this.groupId, this.admin});
  @override
  _GroupChatScreenState createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatRoom> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController controller = TextEditingController();
  final TextEditingController imageMessageController = TextEditingController();

  Future<void> setLastMessageRead() async {
    await _firestore.collection('groups').doc(widget.groupId).update({
      'read': FieldValue.arrayUnion([_auth.currentUser.email])
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 10,
        title: GestureDetector(
          onTap: () async {
            List<String> members = List.from(await _firestore
                .collection('groups')
                .doc(widget.groupId)
                .get()
                .then((value) => value.data()['members']));

            List<dynamic> mapList = await _firestore
                .collection('groups')
                .doc(widget.groupId)
                .get()
                .then((value) => value.data()['members_name']);
            Map<String,dynamic> membersName = {};
            for(var map in mapList)
                membersName.addAll(map);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GroupProfileView(
                  groupId: widget.groupId,
                  groupName: widget.groupName,
                  groupAdmin: widget.admin,
                  memebers: members,
                  membersName: membersName,
                ),
              ),
            );
          },
          child: Row(
            children: [
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('profile_pic')
                    .doc(widget.groupId)
                    .collection('image')
                    .snapshots(),
                builder: (context, snapshot) {
                  String url;
                  if (snapshot.hasData) {
                    final image = snapshot.data.docs;
                    url = image[0].data()['url'];
                  }
                  if (url == null) url = kNoGroupPic;
                  return CircleAvatar(
                    backgroundImage: NetworkImage(url),
                    backgroundColor: Colors.grey,
                    radius: 25,
                  );
                },
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                widget.groupName,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('groups')
                  .doc(widget.groupId)
                  .collection('messages')
                  .orderBy('time', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                setLastMessageRead();
                List<Widget> messageList = [];
                if (snapshot.hasData) {
                  final messages = snapshot.data.docs;
                  if (messages != null) {
                    for (var message in messages) {
                      String mess = message.data()['message'];
                      String senderEmail = message.data()['sender'];
                      String senderName = message.data()['name'];
                      Timestamp stamp = message.data()['time'];
                      String time = DateTimeFormat.format(stamp.toDate(),
                          format: 'h:i a');
                      if (message.data()['type'] == 'txt') {
                        messageList.add(
                          GroupMessage(
                            message: mess,
                            isMe: senderEmail == _auth.currentUser.email,
                            time: time,
                            senderName: senderName,
                            senderEmail: senderEmail,
                          ),
                        );
                      } else {
                        String url = message.data()['image_url'];
                        messageList.add(
                          GroupPhotoMessage(
                            message: mess,
                            isMe: senderEmail == _auth.currentUser.email,
                            time: time,
                            photoUrl: url,
                            senderEmail: senderEmail,
                            senderName: senderName,
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
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: MessageField(
                        controller: controller,
                        imageButtonCallback: () async {
                          final ImagePicker picker = ImagePicker();
                          final PickedFile pickedImage = await picker.getImage(
                              source: ImageSource.gallery);
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
                            String url =
                                await taskSnapshot.ref.getDownloadURL();
                            String lastMessage;
                            DateTime time = DateTime.now();
                            if (imageMessageController.text == null ||
                                imageMessageController.text.trim().isEmpty) {
                              lastMessage = '';
                            } else {
                              lastMessage =
                                  imageMessageController.text.trim().length <=
                                          25
                                      ? imageMessageController.text.trim()
                                      : imageMessageController.text
                                              .substring(0, 25) +
                                          "...";
                            }
                            String myName = await FirebaseFirestore.instance
                                .collection('users')
                                .doc(_auth.currentUser.email)
                                .get()
                                .then((doc) => doc.data()['name']);
                            _firestore
                                .collection('groups')
                                .doc(widget.groupId)
                                .update(
                              {
                                'last_message': lastMessage,
                                'read': [],
                                'type': 'img',
                                'time': time,
                              },
                            );
                            _firestore
                                .collection('groups')
                                .doc(widget.groupId)
                                .collection('messages')
                                .add(
                              {
                                'message': imageMessageController.text.trim(),
                                'sender': _auth.currentUser.email,
                                'time': time,
                                'type': 'img',
                                'image_url': url,
                                'name': myName,
                              },
                            );
                            imageMessageController.clear();
                          }
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 5.0,
                  ),
                  RoundIconButton(
                    icon: Icons.send,
                    onPress: () async {
                      if (controller.text.trim().isEmpty) return;
                      DateTime time = DateTime.now();
                      String lastMessage = controller.text.trim().length <= 25
                          ? controller.text.trim()
                          : controller.text.substring(0, 25) + "...";
                      String myName = await FirebaseFirestore.instance
                          .collection('users')
                          .doc(_auth.currentUser.email)
                          .get()
                          .then((doc) => doc.data()['name']);
                      _firestore
                          .collection('groups')
                          .doc(widget.groupId)
                          .update(
                        {
                          'last_message': lastMessage,
                          'read': [],
                          'type': 'txt',
                          'time': time,
                        },
                      );
                      _firestore
                          .collection('groups')
                          .doc(widget.groupId)
                          .collection('messages')
                          .add(
                        {
                          'message': controller.text.trim(),
                          'sender': _auth.currentUser.email,
                          'time': time,
                          'type': 'txt',
                          'name': myName,
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
