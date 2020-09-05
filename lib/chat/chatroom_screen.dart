import 'package:baatein/chat/forward_selection_screen.dart';
import 'package:baatein/classes/SelectedUser.dart';
import 'package:baatein/classes/time_message_pair.dart';
import 'package:baatein/constants/constants.dart';
import 'package:baatein/customs/message_text_field.dart';
import 'package:baatein/customs/round_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:baatein/customs/message.dart';
import 'package:date_time_format/date_time_format.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'image_preview_screen.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:baatein/customs/photo_message.dart';
import 'package:uuid/uuid.dart';
import 'package:baatein/chat/profile_view.dart';
import 'dart:io';

class ChatRoom extends StatefulWidget {
  final String friendName;
  final String friendEmail;
  ChatRoom({this.friendName, this.friendEmail});
  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController controller = TextEditingController();
  final TextEditingController imageMessageController = TextEditingController();
  Map<String, TimeMessagePair> selectedMessage = {};
  bool selectionMode = false;
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
    await _firestore
        .collection('users')
        .doc(_auth.currentUser.email)
        .collection('chats')
        .doc(widget.friendEmail)
        .update({'new_message': false});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: selectionMode
          ? AppBar(
              automaticallyImplyLeading: false,
              elevation: 10,
              title: Padding(
                padding: const EdgeInsets.only(left: 50),
                child: Text('${selectedMessage.length} selected'),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.cancel),
                  onPressed: () {
                    setState(() {
                      selectedMessage.clear();
                      selectionMode = false;
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed: () async {
                    List<TimeMessagePair> list = [];
                    selectedMessage.forEach((key, value) {list.add(value);});
                    list.sort(comp);
                    bool ok = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ForwardSelectionScreen(
                            selectedMessage: list),
                      ),
                    );
                    if (ok != null && ok == true)
                      setState(() {
                        selectedMessage.clear();
                        selectionMode = false;
                      });
                    for (String email
                        in Provider.of<SelectedUser>(context, listen: false)
                            .getList()) {
                      await _firestore
                          .collection('users')
                          .doc(_auth.currentUser.email)
                          .collection('friends')
                          .doc(email)
                          .update({'selected': false});
                    }
                    Provider.of<SelectedUser>(context, listen: false).clear();
                  },
                ),
              ],
            )
          : AppBar(
              elevation: 10,
              title: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileView(
                      friendEmail: widget.friendEmail,
                      friendName: widget.friendName,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    StreamBuilder<QuerySnapshot>(
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
                        if (url == null) url = kNoProfilePic;
                        return CircleAvatar(
                          backgroundImage: NetworkImage(url),
                          radius: 25,
                        );
                      },
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      widget.friendName,
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
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
                      String messageId = message.data()['id'];
                      if (message.data()['type'] == 'txt') {
                        if (selectionMode == false) {
                          messageList.add(
                            Message(
                              message: mess,
                              isMe: sender == _auth.currentUser.email,
                              time: time,
                              id: messageId,
                              onLongpressCallback: () {
                                selectedMessage.addAll({messageId: TimeMessagePair(message: mess, time: stamp.toDate())});
                                setState(() {
                                  selectionMode = true;
                                });
                              },
                            ),
                          );
                        } else {
                          messageList.add(
                            Message(
                              message: mess,
                              isMe: sender == _auth.currentUser.email,
                              time: time,
                              id: messageId,
                              onTap: () {
                                if (selectedMessage.containsKey(messageId)) {
                                  setState(() {
                                    selectedMessage.remove(messageId);
                                    if (selectedMessage.isEmpty)
                                      selectionMode = false;
                                  });
                                } else {
                                  setState(() {
                                    selectedMessage.addAll({messageId: TimeMessagePair(message: mess, time: stamp.toDate())});
                                  });
                                }
                              },
                              isSelected:
                                  selectedMessage.containsKey(messageId),
                            ),
                          );
                        }
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
                      String messageId = Uuid().v4();
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
                          'id': messageId,
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
                          'id': messageId,
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
