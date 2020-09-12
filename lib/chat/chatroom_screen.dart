import 'package:baatein/chat/forward_selection_screen.dart';
import 'package:baatein/chat/message_info_screen.dart';
import 'package:baatein/provider/firebase_service.dart';
import 'package:baatein/provider/logged_in_user.dart';
import 'package:baatein/provider/selected_user.dart';
import 'package:baatein/helper/message_info.dart';
import 'package:baatein/constants/constants.dart';
import 'package:baatein/customs/message_text_field.dart';
import 'package:baatein/customs/round_icon_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:baatein/customs/message.dart';
import 'package:date_time_format/date_time_format.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'image_preview_screen.dart';
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
  final TextEditingController controller = TextEditingController();
  final TextEditingController imageMessageController = TextEditingController();
  final Map<String, MessageInfo> selectedMessage = {};
  bool selectionMode = false, spin = false;

  LoggedInUser _user;
  FirebaseService _firebase;

  @override
  void initState() {
    super.initState();
    initLoggedInUser();
    initFirebaseService();
  }

  void initFirebaseService() =>
      _firebase = Provider.of<FirebaseService>(context, listen: false);

  void initLoggedInUser() =>
      _user = Provider.of<LoggedInUser>(context, listen: false);

  Future<void> setNewMessageFalse() async {
    await _firebase.firestore
        .collection('users')
        .doc(_user.email)
        .collection('chats')
        .doc(widget.friendEmail)
        .update({'new_message': false});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (selectionMode) {
          setState(() {
            selectedMessage.clear();
            selectionMode = false;
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
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
                  selectedMessage.length == 1
                      ? IconButton(
                          icon: Icon(Icons.info),
                          onPressed: () {
                            MessageInfo message;
                            selectedMessage.forEach((key, value) {
                              message = value;
                            });
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MessageInfoScrren(
                                  message: message,
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          width: 0,
                          height: 0,
                        ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () async {
                      bool ok = await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Are you sure to delete these messages?'),
                          // content: Text(
                          //     'You will have no access to group once you leave.'),
                          actions: [
                            FlatButton(
                              child: Text('Delete'),
                              onPressed: () async {
                                setState(() {
                                  spin = true;
                                });
                                selectedMessage.forEach(
                                  (key, value) async {
                                    if (value.type == 'img') {
                                      String imageName = value.imageName;
                                      int count = await _firebase.firestore
                                          .collection('shared_images')
                                          .doc(imageName)
                                          .get()
                                          .then(
                                              (value) => value.data()['count']);
                                      if (count == 1) {
                                        //last link of image => delete image + its count document.
                                        _firebase.storage
                                            .ref()
                                            .child(imageName)
                                            .delete();
                                        _firebase.firestore
                                            .collection('shared_images')
                                            .doc(imageName)
                                            .delete();
                                      } else {
                                        --count;
                                        _firebase.firestore
                                            .collection('shared_images')
                                            .doc(imageName)
                                            .update({'count': count});
                                      }
                                    }
                                    _firebase.firestore
                                        .collection('users')
                                        .doc(_user.email)
                                        .collection('chats')
                                        .doc(widget.friendEmail)
                                        .collection('messages')
                                        .doc(key)
                                        .delete();
                                  },
                                );
                                _firebase.firestore
                                    .collection('users')
                                    .doc(_user.email)
                                    .collection('chats')
                                    .doc(widget.friendEmail)
                                    .update({'last_message': ''});
                                setState(() {
                                  spin = false;
                                });
                                Navigator.pop(context, true);
                              },
                            ),
                            FlatButton(
                              child: Text('Cancel'),
                              onPressed: () => Navigator.pop(context, false),
                            ),
                          ],
                        ),
                      );
                      if (ok != null && ok == true) {
                        Flushbar(
                          message: selectedMessage.length > 1
                              ? "${selectedMessage.length} messages deleted."
                              : 'Message deleted.',
                          margin: EdgeInsets.all(8),
                          borderRadius: 8,
                          icon: Icon(
                            Icons.delete_sweep,
                            color: Colors.blue[300],
                            size: 20,
                          ),
                          duration: Duration(seconds: 1),
                        ).show(context);
                        setState(() {
                          selectedMessage.clear();
                          selectionMode = false;
                        });
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_forward),
                    onPressed: () async {
                      List<MessageInfo> list = [];
                      selectedMessage.forEach((key, value) {
                        list.add(value);
                      });
                      list.sort(comp);
                      bool ok = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ForwardSelectionScreen(
                            selectedMessage: list,
                            from: 'chat',
                          ),
                        ),
                      );
                      if (ok != null && ok == true) {
                        setState(() {
                          selectedMessage.clear();
                          selectionMode = false;
                        });
                      } else {
                        await Provider.of<SelectedUser>(context, listen: false)
                            .clearChat();
                        await Provider.of<SelectedUser>(context, listen: false)
                            .clearGroup();
                      }
                    },
                  ),
                ],
              )
            : AppBar(
                elevation: 10,
                centerTitle: false,
                title: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileView(
                          friendEmail: widget.friendEmail,
                          friendName: widget.friendName,
                          isFriend: true,
                        ),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      StreamBuilder<QuerySnapshot>(
                        stream: _firebase.firestore
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
                          );
                        },
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        widget.friendName,
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      StreamBuilder<QuerySnapshot>(
                        stream: _firebase.firestore
                            .collection('presence')
                            .doc(widget.friendEmail)
                            .collection('status')
                            .snapshots(),
                        builder: (context, snapshot) {
                          bool isOnline = false;
                          try {
                            if (snapshot.hasData && snapshot.data != null) {
                              isOnline =
                                  snapshot.data.docs[0].data()['is_online'];
                            }
                          } catch (e) {
                            isOnline = false;
                          }
                          return Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: isOnline
                                ? Icon(
                                    Icons.fiber_manual_record,
                                    color: Colors.green,
                                    size: 12,
                                  )
                                : Container(
                                    width: 0,
                                    height: 0,
                                  ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
        body: ModalProgressHUD(
          inAsyncCall: spin,
          child: SafeArea(
            child: Column(
              children: [
                StreamBuilder<QuerySnapshot>(
                  stream: _firebase.firestore
                      .collection('users')
                      .doc(_user.email)
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
                          String senderEmail = message.data()['sender'];
                          String senderName = message.data()['name'];
                          Timestamp stamp = message.data()['time'];

                          String time = DateTimeFormat.format(stamp.toDate(),
                              format: 'h:i a');
                          String date = DateTimeFormat.format(stamp.toDate(),
                              format: 'D, M d, Y');
                          String messageId = message.data()['id'];
                          if (message.data()['type'] == 'txt') {
                            if (selectionMode == false) {
                              messageList.add(
                                Message(
                                  message: mess,
                                  isMe: senderEmail == _user.email,
                                  time: time,
                                  id: messageId,
                                  onLongPressCallback: () {
                                    setState(() {
                                      selectedMessage.addAll({
                                        messageId: MessageInfo(
                                            senderEmail: senderEmail,
                                            senderName: senderName,
                                            timeString: time,
                                            date: date,
                                            message: mess,
                                            time: stamp.toDate(),
                                            type: 'txt')
                                      });

                                      selectionMode = true;
                                    });
                                  },
                                ),
                              );
                            } else {
                              messageList.add(
                                Message(
                                  message: mess,
                                  isMe: senderEmail == _user.email,
                                  time: time,
                                  id: messageId,
                                  onTapCallback: () {
                                    if (selectedMessage
                                        .containsKey(messageId)) {
                                      setState(() {
                                        selectedMessage.remove(messageId);
                                        if (selectedMessage.isEmpty)
                                          selectionMode = false;
                                      });
                                    } else {
                                      setState(() {
                                        selectedMessage.addAll({
                                          messageId: MessageInfo(
                                              senderEmail: senderEmail,
                                              senderName: senderName,
                                              timeString: time,
                                              date: date,
                                              message: mess,
                                              time: stamp.toDate(),
                                              type: 'txt')
                                        });
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
                            String imageName = message.data()['image_name'];
                            if (selectionMode) {
                              messageList.add(
                                PhotoMessage(
                                  onTapCallback: () {
                                    if (selectedMessage
                                        .containsKey(messageId)) {
                                      setState(() {
                                        selectedMessage.remove(messageId);
                                        if (selectedMessage.isEmpty)
                                          selectionMode = false;
                                      });
                                    } else {
                                      setState(
                                        () {
                                          selectedMessage.addAll(
                                            {
                                              messageId: MessageInfo(
                                                  senderEmail: senderEmail,
                                                  senderName: senderName,
                                                  timeString: time,
                                                  date: date,
                                                  message: mess,
                                                  time: stamp.toDate(),
                                                  type: 'img',
                                                  imageName: imageName,
                                                  url: url),
                                            },
                                          );
                                        },
                                      );
                                    }
                                  },
                                  isSelected:
                                      selectedMessage.containsKey(messageId),
                                  message: mess,
                                  isMe: senderEmail == _user.email,
                                  time: time,
                                  photoUrl: url,
                                ),
                              );
                            } else {
                              messageList.add(
                                PhotoMessage(
                                  onLongPressCallback: () {
                                    setState(() {
                                      selectedMessage.addAll({
                                        messageId: MessageInfo(
                                            senderEmail: senderEmail,
                                            senderName: senderName,
                                            timeString: time,
                                            date: date,
                                            message: mess,
                                            time: stamp.toDate(),
                                            type: 'img',
                                            imageName: imageName,
                                            url: url)
                                      });

                                      selectionMode = true;
                                    });
                                  },
                                  isSelected:
                                      selectedMessage.containsKey(messageId),
                                  message: mess,
                                  isMe: senderEmail == _user.email,
                                  time: time,
                                  photoUrl: url,
                                ),
                              );
                            }
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
                            final PickedFile pickedImage = await picker
                                .getImage(source: ImageSource.gallery);
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
                            String message = imageMessageController.text;
                            imageMessageController.clear();
                            if (await _firebase.firestore
                                    .collection('users')
                                    .doc(_user.email)
                                    .collection('friends')
                                    .doc(widget.friendEmail)
                                    .get()
                                    .then((value) => value.exists) ==
                                false) {
                              //Flushbar to indicate the group deletion by admin
                              await Flushbar(
                                message: '${widget.friendName} unfriends you.',
                                margin: EdgeInsets.all(8),
                                borderRadius: 8,
                                icon: Icon(
                                  Icons.error,
                                  color: Colors.blue[300],
                                  size: 20,
                                ),
                                duration: Duration(seconds: 1),
                              ).show(context);
                              Navigator.pop(context);
                              return;
                            }
                            if (send != null && send == true) {
                              String imageId = Uuid().v4();
                              String messageId = Uuid().v4();
                              final ref = _firebase.storage
                                  .ref()
                                  .child(imageId + '.jpg');
                              StorageUploadTask task = ref.putFile(imageFile);
                              StorageTaskSnapshot taskSnapshot =
                                  await task.onComplete;
                              String url =
                                  await taskSnapshot.ref.getDownloadURL();
                              String lastMessage;
                              DateTime time = DateTime.now();
                              if (message == null || message.trim().isEmpty) {
                                lastMessage = '';
                              } else {
                                lastMessage = message.trim().length <= 25
                                    ? message.trim()
                                    : message.trim().substring(0, 25) + "...";
                              }

                              // setting image_share count
                              String imageName = imageId + '.jpg';
                              _firebase.firestore
                                  .collection('shared_images')
                                  .doc(imageName)
                                  .set({'count': 2});

                              //adding message to current user database
                              _firebase.firestore
                                  .collection('users')
                                  .doc(_user.email)
                                  .collection('chats')
                                  .doc(widget.friendEmail)
                                  .set(
                                {
                                  'email': widget.friendEmail,
                                  'name': widget.friendName,
                                  'search_name':
                                      widget.friendName.toLowerCase(),
                                  'last_message': lastMessage,
                                  'new_message': false,
                                  'time': time,
                                  'type': 'img',
                                },
                              );
                              _firebase.firestore
                                  .collection('users')
                                  .doc(_user.email)
                                  .collection('chats')
                                  .doc(widget.friendEmail)
                                  .collection('messages')
                                  .doc(messageId)
                                  .set(
                                {
                                  'name': _user.name,
                                  'message': message.trim(),
                                  'sender': _user.email,
                                  'time': time,
                                  'type': 'img',
                                  'image_url': url,
                                  'id': messageId,
                                  'image_name': imageName,
                                },
                              );
                              //adding message to friend database
                              _firebase.firestore
                                  .collection('users')
                                  .doc(widget.friendEmail)
                                  .collection('chats')
                                  .doc(_user.email)
                                  .set(
                                {
                                  'email': _user.email,
                                  'name': _user.name,
                                  'search_name': _user.name.toLowerCase(),
                                  'last_message': lastMessage,
                                  'new_message': true,
                                  'time': time,
                                  'type': 'img',
                                },
                              );
                              _firebase.firestore
                                  .collection('users')
                                  .doc(widget.friendEmail)
                                  .collection('chats')
                                  .doc(_user.email)
                                  .collection('messages')
                                  .doc(messageId)
                                  .set(
                                {
                                  'name': _user.name,
                                  'message': message.trim(),
                                  'sender': _user.email,
                                  'time': time,
                                  'type': 'img',
                                  'image_url': url,
                                  'id': messageId,
                                  'image_name': imageName,
                                },
                              );
                            }
                          },
                        ),
                      ),
                      SizedBox(
                        width: 5.0,
                      ),
                      RoundIconButton(
                        icon: Icons.send,
                        onPress: () async {
                          String message = controller.text;
                          controller.clear();
                          if (await _firebase.firestore
                                  .collection('users')
                                  .doc(_user.email)
                                  .collection('friends')
                                  .doc(widget.friendEmail)
                                  .get()
                                  .then((value) => value.exists) ==
                              false) {
                            //Flushbar to indicate the group deletion by admin
                            await Flushbar(
                              message: '${widget.friendName} unfriends you.',
                              margin: EdgeInsets.all(8),
                              borderRadius: 8,
                              icon: Icon(
                                Icons.error,
                                color: Colors.blue[300],
                                size: 20,
                              ),
                              duration: Duration(seconds: 1),
                            ).show(context);
                            Navigator.pop(context);
                            return;
                          }
                          if (message == null || message.trim().isEmpty) return;

                          DateTime time = DateTime.now();
                          String lastMessage = message.trim().length <= 25
                              ? message.trim()
                              : message.trim().substring(0, 25) + "...";
                          String messageId = Uuid().v4();
                          //adding message to current user database
                          _firebase.firestore
                              .collection('users')
                              .doc(_user.email)
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
                          _firebase.firestore
                              .collection('users')
                              .doc(_user.email)
                              .collection('chats')
                              .doc(widget.friendEmail)
                              .collection('messages')
                              .doc(messageId)
                              .set(
                            {
                              'name': _user.name,
                              'message': message.trim(),
                              'sender': _user.email,
                              'time': time,
                              'type': 'txt',
                              'id': messageId,
                            },
                          );
                          //adding message to friend database
                          _firebase.firestore
                              .collection('users')
                              .doc(widget.friendEmail)
                              .collection('chats')
                              .doc(_user.email)
                              .set(
                            {
                              'email': _user.email,
                              'name': _user.name,
                              'search_name': _user.name.toLowerCase(),
                              'last_message': lastMessage,
                              'new_message': true,
                              'time': time,
                              'type': 'txt',
                            },
                          );
                          _firebase.firestore
                              .collection('users')
                              .doc(widget.friendEmail)
                              .collection('chats')
                              .doc(_user.email)
                              .collection('messages')
                              .doc(messageId)
                              .set(
                            {
                              'name': _user.name,
                              'message': message.trim(),
                              'sender': _user.email,
                              'time': time,
                              'type': 'txt',
                              'id': messageId,
                            },
                          );
                        },
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
