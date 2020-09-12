import 'package:baatein/chat/forward_selection_screen.dart';
import 'package:baatein/chat/group_profile_view.dart';
import 'package:baatein/chat/message_info_screen.dart';
import 'package:baatein/provider/firebase_service.dart';
import 'package:baatein/provider/logged_in_user.dart';
import 'package:baatein/provider/selected_user.dart';
import 'package:baatein/helper/message_info.dart';
import 'package:baatein/constants/constants.dart';
import 'package:baatein/customs/group_message.dart';
import 'package:baatein/customs/group_photo_message.dart';
import 'package:baatein/customs/message_text_field.dart';
import 'package:baatein/customs/round_icon_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
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
  final TextEditingController controller = TextEditingController();
  final TextEditingController imageMessageController = TextEditingController();
  Map<String, MessageInfo> selectedMessage = {};
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

  Future<void> setLastMessageRead() async {
    try {
      await _firebase.firestore
          .collection('groups')
          .doc(widget.groupId)
          .update({
        'read': FieldValue.arrayUnion([_user.email])
      });
    } catch (e) {
      return;
    }
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
                                        .collection('groups')
                                        .doc(widget.groupId)
                                        .collection('messages')
                                        .doc(key)
                                        .update({
                                      'deleted_by':
                                          FieldValue.arrayUnion([_user.email])
                                    });
                                    Set<String> deletedBy = Set.from(
                                        await _firebase
                                            .firestore
                                            .collection('groups')
                                            .doc(widget.groupId)
                                            .collection('messages')
                                            .doc(key)
                                            .get()
                                            .then((value) =>
                                                value.data()['deleted_by']));

                                    List<String> members = List.from(
                                        await _firebase
                                            .firestore
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
                                      _firebase.firestore
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
                centerTitle: false,
                title: InkWell(
                  onTap: () async {
                    setState(() {
                      spin = true;
                    });
                    FocusScope.of(context).unfocus();
                    List<String> members = List.from(await _firebase.firestore
                        .collection('groups')
                        .doc(widget.groupId)
                        .get()
                        .then((value) => value.data()['members']));

                    List<dynamic> mapList = await _firebase.firestore
                        .collection('groups')
                        .doc(widget.groupId)
                        .get()
                        .then((value) => value.data()['members_name']);
                    Map<String, dynamic> membersName = {};
                    for (var map in mapList) membersName.addAll(map);
                    members.sort();
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
                        stream: _firebase.firestore
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
                          if (deletedBy.contains(_user.email)) continue;
                          String mess = message.data()['message'];
                          String senderEmail = message.data()['sender'];
                          String senderName = message.data()['name'];
                          Timestamp stamp = message.data()['time'];
                          String id = message.data()['id'];
                          String time = DateTimeFormat.format(stamp.toDate(),
                              format: 'h:i a');
                          String date = DateTimeFormat.format(stamp.toDate(),
                              format: 'D, M d, Y');
                          if (message.data()['type'] == 'txt') {
                            if (selectionMode) {
                              messageList.add(
                                GroupMessage(
                                  message: mess,
                                  isMe: senderEmail == _user.email,
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
                                                date: date,
                                                message: mess,
                                                time: stamp.toDate(),
                                                senderEmail: senderEmail,
                                                senderName: senderName,
                                                timeString: time,
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
                                  isMe: senderEmail == _user.email,
                                  time: time,
                                  senderName: senderName,
                                  senderEmail: senderEmail,
                                  onLongpressCallback: () {
                                    setState(
                                      () {
                                        selectedMessage.addAll(
                                          {
                                            id: MessageInfo(
                                                senderEmail: senderEmail,
                                                senderName: senderName,
                                                timeString: time,
                                                date: date,
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
                                  isSelected: selectedMessage.containsKey(id),
                                  message: mess,
                                  isMe: senderEmail == _user.email,
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
                                  isSelected: selectedMessage.containsKey(id),
                                  message: mess,
                                  id: id,
                                  senderEmail: senderEmail,
                                  senderName: senderName,
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
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
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
                              //avoiding sending message if admin deleted group.
                              String message = imageMessageController.text;
                              imageMessageController.clear();
                              if (await _firebase.firestore
                                      .collection('groups')
                                      .doc(widget.groupId)
                                      .get()
                                      .then((value) => value.exists) ==
                                  false) {
                                //Flushbar to indicate the group deletion by admin
                                await Flushbar(
                                  message: 'The group is deleted by the admin.',
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
                                if (message == null ||
                                    imageMessageController.text
                                        .trim()
                                        .isEmpty) {
                                  lastMessage = '';
                                } else {
                                  lastMessage = message.trim().length <= 25
                                      ? message
                                      : message.trim().substring(0, 25) + "...";
                                }
                                int size = await _firebase.firestore
                                    .collection('groups')
                                    .doc(widget.groupId)
                                    .get()
                                    .then((value) => value.data()['size']);
                                //setting image_share count
                                String imageName = imageId + '.jpg';
                                _firebase.firestore
                                    .collection('shared_images')
                                    .doc(imageName)
                                    .set({'count': size});
                                String messageId = Uuid().v4();

                                String myName = Provider.of<LoggedInUser>(
                                        context,
                                        listen: false)
                                    .name;

                                _firebase.firestore
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
                                _firebase.firestore
                                    .collection('groups')
                                    .doc(widget.groupId)
                                    .collection('messages')
                                    .doc(messageId)
                                    .set(
                                  {
                                    'message': message,
                                    'sender': _user.email,
                                    'time': time,
                                    'type': 'img',
                                    'image_url': url,
                                    'name': myName,
                                    'id': messageId,
                                    'image_name': imageName,
                                    'deleted_by': [],
                                  },
                                );
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
                          String message = controller.text.trim();
                          controller.clear();
                          if (await _firebase.firestore
                                  .collection('groups')
                                  .doc(widget.groupId)
                                  .get()
                                  .then((value) => value.exists) ==
                              false) {
                            //Flushbar to indicate the group deletion by admin
                            await Flushbar(
                              message: 'The group is deleted by the admin.',
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
                          if (message.isEmpty) return;
                          DateTime time = DateTime.now();
                          String lastMessage = message.length <= 25
                              ? message
                              : message.substring(0, 25) + "...";

                          String messageId = Uuid().v4();
                          String myName =
                              Provider.of<LoggedInUser>(context, listen: false)
                                  .name;

                          _firebase.firestore
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
                          _firebase.firestore
                              .collection('groups')
                              .doc(widget.groupId)
                              .collection('messages')
                              .doc(messageId)
                              .set(
                            {
                              'message': message,
                              'sender': _user.email,
                              'time': time,
                              'type': 'txt',
                              'name': myName,
                              'id': messageId,
                              'deleted_by': [],
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
