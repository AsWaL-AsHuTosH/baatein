import 'package:baatein/chat/forward_selection_screen.dart';
import 'package:baatein/chat/group_profile_view.dart';
import 'package:baatein/classes/SelectedUser.dart';
import 'package:baatein/classes/message_info.dart';
import 'package:baatein/constants/constants.dart';
import 'package:baatein/customs/group_message.dart';
import 'package:baatein/customs/group_photo_message.dart';
import 'package:baatein/customs/message_text_field.dart';
import 'package:baatein/customs/round_icon_button.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:date_time_format/date_time_format.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
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
  Map<String, MessageInfo> selectedMessage = {};
  bool selectionMode = false, spin = false;
  String myName;

  Future<void> setLastMessageRead() async {
    try {
      await _firestore.collection('groups').doc(widget.groupId).update({
        'read': FieldValue.arrayUnion([_auth.currentUser.email])
      });
    } catch (e) {
      return;
    }
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
                                    int count = await _firestore
                                        .collection('shared_images')
                                        .doc(imageName)
                                        .get()
                                        .then((value) => value.data()['count']);
                                    if (count == 1) {
                                      //last link of image => delete image + its count document.
                                      FirebaseStorage.instance
                                          .ref()
                                          .child(imageName)
                                          .delete();
                                      _firestore
                                          .collection('shared_images')
                                          .doc(imageName)
                                          .delete();
                                    } else {
                                      --count;
                                      _firestore
                                          .collection('shared_images')
                                          .doc(imageName)
                                          .update({'count': count});
                                    }
                                  }

                                  _firestore
                                      .collection('groups')
                                      .doc(widget.groupId)
                                      .collection('messages')
                                      .doc(key)
                                      .update({
                                    'deleted_by': FieldValue.arrayUnion(
                                        [_auth.currentUser.email])
                                  });
                                  Set<String> deletedBy = Set.from(
                                      await _firestore
                                          .collection('groups')
                                          .doc(widget.groupId)
                                          .collection('messages')
                                          .doc(key)
                                          .get()
                                          .then((value) =>
                                              value.data()['deleted_by']));

                                  List<String> members = List.from(
                                      await _firestore
                                          .collection('groups')
                                          .doc(widget.groupId)
                                          .get()
                                          .then((value) =>
                                              value.data()['members']));
                                  bool everyOneDeleted = true;
                                  for (String member in members) {
                                    everyOneDeleted &=
                                        deletedBy.contains(member);
                                    if (everyOneDeleted == false) break;
                                  }
                                  if (everyOneDeleted) {
                                    _firestore
                                        .collection('groups')
                                        .doc(widget.groupId)
                                        .collection('messages')
                                        .doc(key)
                                        .delete();
                                  }
                                },
                              );
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
                        backgroundGradient:
                            LinearGradient(colors: [Colors.grey, Colors.grey]),
                        icon: Icon(
                          Icons.delete_sweep,
                          color: Colors.black,
                          size: 20,
                        ),
                        margin: EdgeInsets.all(8),
                        borderRadius: 8,
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 2),
                        boxShadows: [
                          BoxShadow(
                            color: Colors.lightBlueAccent,
                            offset: Offset(0.0, 2.0),
                            blurRadius: 3.0,
                          )
                        ],
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
                            selectedMessage: list, from: 'group'),
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
              actions: [
                InkWell(
                  onTap: () async {
                    setState(() {
                      spin = true;
                    });
                    FocusScope.of(context).unfocus();
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
                    Map<String, dynamic> membersName = {};
                    for (var map in mapList) membersName.addAll(map);
                    setState(() {
                      spin = false;
                    });
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GroupProfileView(
                          groupId: widget.groupId,
                          groupName: widget.groupName,
                          groupAdmin: widget.admin,
                          members: members,
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
                          );
                        },
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Text(
                        widget.groupName,
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        width: 200,
                      )
                    ],
                  ),
                ),
              ],
            ),
      body: ModalProgressHUD(
        inAsyncCall: spin,
        child: SafeArea(
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
                        Set<String> deletedBy =
                            Set<String>.from(message.data()['deleted_by']);
                        if (deletedBy.contains(_auth.currentUser.email))
                          continue;
                        String mess = message.data()['message'];
                        String senderEmail = message.data()['sender'];
                        String senderName = message.data()['name'];
                        Timestamp stamp = message.data()['time'];
                        String id = message.data()['id'];
                        String time = DateTimeFormat.format(stamp.toDate(),
                            format: 'h:i a');
                        if (message.data()['type'] == 'txt') {
                          if (selectionMode) {
                            messageList.add(
                              GroupMessage(
                                message: mess,
                                isMe: senderEmail == _auth.currentUser.email,
                                time: time,
                                senderName: senderName,
                                senderEmail: senderEmail,
                                onTapCallback: () {
                                  if (selectedMessage.containsKey(id)) {
                                    setState(
                                      () {
                                        selectedMessage.remove(id);
                                        if (selectedMessage.isEmpty)
                                          selectionMode = false;
                                      },
                                    );
                                  } else {
                                    setState(
                                      () {
                                        selectedMessage.addAll(
                                          {
                                            id: MessageInfo(
                                              message: mess,
                                              time: stamp.toDate(),
                                              type: 'txt',
                                            )
                                          },
                                        );
                                      },
                                    );
                                  }
                                },
                                isSelected: selectedMessage.containsKey(id),
                              ),
                            );
                          } else {
                            messageList.add(
                              GroupMessage(
                                message: mess,
                                isMe: senderEmail == _auth.currentUser.email,
                                time: time,
                                senderName: senderName,
                                senderEmail: senderEmail,
                                onLongpressCallback: () {
                                  setState(
                                    () {
                                      selectedMessage.addAll(
                                        {
                                          id: MessageInfo(
                                              message: mess,
                                              time: stamp.toDate(),
                                              type: 'txt')
                                        },
                                      );
                                      selectionMode = true;
                                    },
                                  );
                                },
                              ),
                            );
                          }
                        } else {
                          String url = message.data()['image_url'];
                          String imageName = message.data()['image_name'];
                          if (selectionMode) {
                            messageList.add(
                              GroupPhotoMessage(
                                onTapCallback: () {
                                  if (selectedMessage.containsKey(id)) {
                                    setState(() {
                                      selectedMessage.remove(id);
                                      if (selectedMessage.isEmpty)
                                        selectionMode = false;
                                    });
                                  } else {
                                    setState(
                                      () {
                                        selectedMessage.addAll(
                                          {
                                            id: MessageInfo(
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
                                isSelected: selectedMessage.containsKey(id),
                                message: mess,
                                isMe: senderEmail == _auth.currentUser.email,
                                time: time,
                                photoUrl: url,
                                id: id,
                                senderEmail: senderEmail,
                                senderName: senderName,
                              ),
                            );
                          } else {
                            messageList.add(
                              GroupPhotoMessage(
                                onLongPressCallback: () {
                                  setState(() {
                                    selectedMessage.addAll({
                                      id: MessageInfo(
                                          message: mess,
                                          time: stamp.toDate(),
                                          type: 'img',
                                          imageName: imageName,
                                          url: url)
                                    });
                                    selectionMode = true;
                                  });
                                },
                                isSelected: selectedMessage.containsKey(id),
                                message: mess,
                                id: id,
                                senderEmail: senderEmail,
                                senderName: senderName,
                                isMe: senderEmail == _auth.currentUser.email,
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
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: MessageField(
                          controller: controller,
                          imageButtonCallback: () async {
                            //avoiding sending message if admin deleted group.
                            if (await _firestore
                                    .collection('groups')
                                    .doc(widget.groupId)
                                    .get()
                                    .then((value) => value.exists) ==
                                false) {
                              //Flushbar to indicate the group deletion by admin
                              await Flushbar(
                                message: 'The group is deleted by the admin.',
                                backgroundGradient: LinearGradient(
                                    colors: [Colors.grey, Colors.grey]),
                                icon: Icon(
                                  Icons.delete_sweep,
                                  color: Colors.black,
                                  size: 20,
                                ),
                                margin: EdgeInsets.all(8),
                                borderRadius: 8,
                                backgroundColor: Colors.red,
                                duration: Duration(seconds: 2),
                                boxShadows: [
                                  BoxShadow(
                                    color: Colors.lightBlueAccent,
                                    offset: Offset(0.0, 2.0),
                                    blurRadius: 3.0,
                                  )
                                ],
                              ).show(context);
                              Navigator.pop(context);
                              return;
                            }
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
                              int size = await _firestore
                                  .collection('groups')
                                  .doc(widget.groupId)
                                  .get()
                                  .then((value) => value.data()['size']);
                              //setting image_share count
                              String imageName = imageId + '.jpg';
                              _firestore
                                  .collection('shared_images')
                                  .doc(imageName)
                                  .set({'count': size});
                              String messageId = Uuid().v4();

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
                                  .doc(messageId)
                                  .set(
                                {
                                  'message': imageMessageController.text.trim(),
                                  'sender': _auth.currentUser.email,
                                  'time': time,
                                  'type': 'img',
                                  'image_url': url,
                                  'name': myName,
                                  'id': messageId,
                                  'image_name': imageName,
                                  'deleted_by': [],
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
                        //avoiding sending message if admin deleted group.
                        if (await _firestore
                                .collection('groups')
                                .doc(widget.groupId)
                                .get()
                                .then((value) => value.exists) ==
                            false) {
                          //Flushbar to indicate the group deletion by admin
                          await Flushbar(
                            message: 'The group is deleted by the admin.',
                            backgroundGradient: LinearGradient(
                                colors: [Colors.grey, Colors.grey]),
                            icon: Icon(
                              Icons.delete_sweep,
                              color: Colors.black,
                              size: 20,
                            ),
                            margin: EdgeInsets.all(8),
                            borderRadius: 8,
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 2),
                            boxShadows: [
                              BoxShadow(
                                color: Colors.lightBlueAccent,
                                offset: Offset(0.0, 2.0),
                                blurRadius: 3.0,
                              )
                            ],
                          ).show(context);
                          Navigator.pop(context);
                          return;
                        }
                        if (controller.text.trim().isEmpty) return;
                        DateTime time = DateTime.now();
                        String lastMessage = controller.text.trim().length <= 25
                            ? controller.text.trim()
                            : controller.text.substring(0, 25) + "...";

                        String messageId = Uuid().v4();
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
                            .doc(messageId)
                            .set(
                          {
                            'message': controller.text.trim(),
                            'sender': _auth.currentUser.email,
                            'time': time,
                            'type': 'txt',
                            'name': myName,
                            'id': messageId,
                            'deleted_by': [],
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
      ),
    );
  }
}
