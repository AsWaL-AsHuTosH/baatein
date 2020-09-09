import 'package:baatein/classes/SelectedUser.dart';
import 'package:baatein/classes/message_info.dart';
import 'package:baatein/constants/constants.dart';
import 'package:baatein/customs/group_selection_card.dart';
import 'package:baatein/customs/round_text_button.dart';
import 'package:baatein/customs/search_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class GroupForwardScreen extends StatefulWidget {
  final List<MessageInfo> selectedMessage;
  final String from;
  GroupForwardScreen({@required this.selectedMessage, this.from});
  @override
  _GroupForwardScreenState createState() => _GroupForwardScreenState();
}

class _GroupForwardScreenState extends State<GroupForwardScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool spin = false;
  String data1;
  String data2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).accentColor,
      body: ModalProgressHUD(
        inAsyncCall: spin,
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: SearchField(
                  hintText: 'Type group name......',
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
              SizedBox(
                height: 5,
              ),
              Provider.of<SelectedUser>(context, listen: true).isEmptyGroup
                  ? Container()
                  : Container(
                      margin: EdgeInsets.all(4),
                      height: 60,
                      child: Consumer<SelectedUser>(
                        builder: (context, value, child) {
                          List<String> list = value.getListGroup();
                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: list.length,
                            itemBuilder: (context, index) =>
                                StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('profile_pic')
                                  .doc(list[index])
                                  .collection('image')
                                  .snapshots(),
                              builder: (context, snapshot) {
                                String url;
                                if (snapshot.hasData) {
                                  final image = snapshot.data.docs;
                                  url = image[0].data()['url'];
                                }
                                if (url == null) url = kNoProfilePic;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 2.0),
                                  child: CircleAvatar(
                                    backgroundImage: NetworkImage(url),
                                    backgroundColor: Colors.grey,
                                    radius: 30,
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
              Provider.of<SelectedUser>(context, listen: true).isEmptyGroup
                  ? Divider(
                      color: Colors.transparent,
                      height: 0,
                    )
                  : Divider(
                      color: Colors.grey,
                      endIndent: 10,
                      indent: 10,
                    ),
              StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('users')
                    .doc(_auth.currentUser.email)
                    .collection('groups')
                    .where('search_name', isGreaterThanOrEqualTo: data1)
                    .where('search_name', isLessThan: data2)
                    .orderBy('search_name')
                    .snapshots(),
                builder: (context, snapshot) {
                  List<GroupSelectionCard> friendList = [];
                  if (snapshot.hasData) {
                    final groups = snapshot.data.docs;
                    if (groups != null) {
                      for (var group in groups) {
                        String id = group.data()['id'];
                        bool isSelected = group.data()['selected'];
                        String admin = group.data()['admin'];
                        String name = group.data()['name'];
                        friendList.add(
                          GroupSelectionCard(
                            groupAdmin: admin,
                            groupName: name,
                            groupId: id,
                            isSelected: isSelected,
                          ),
                        );
                      }
                    }
                  }
                  return Expanded(
                    child: ListView(
                      children: friendList,
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: RoundTextButton(
                  text: 'Send',
                  icon: Icons.send,
                  onPress: () async {
                    setState(() {
                      spin = true;
                    });
                    if (Provider.of<SelectedUser>(context, listen: false)
                        .nothingSelected) {
                      Flushbar(
                        message: "No member selected!",
                        margin: EdgeInsets.all(8),
                        borderRadius: 8,
                        icon: Icon(
                          Icons.error,
                          color: Colors.blue[300],
                          size: 20,
                        ),
                        duration: Duration(seconds: 1),
                      ).show(context);
                      setState(() {
                        spin = false;
                      });
                      return;
                    }
                    //Data for chats required
                    String myName = await _firestore
                        .collection('users')
                        .doc(_auth.currentUser.email)
                        .get()
                        .then((doc) => doc.data()['name']);
                    String myEmail = _auth.currentUser.email;
                    List<String> chats =
                        Provider.of<SelectedUser>(context, listen: false)
                            .getListChat();
                    Map<String, String> nameofChat =
                        Provider.of<SelectedUser>(context, listen: false)
                            .getMapChat();
                    Map<String, int> imageCount = {};

                    List<String> groups =
                        Provider.of<SelectedUser>(context, listen: false)
                            .getListGroup();

                    Map<String, int> sizeOfGroup = {};

                    for (String id in groups)
                      sizeOfGroup[id] = await _firestore
                          .collection('groups')
                          .doc(id)
                          .get()
                          .then((value) => value.data()['size']);

                    //SENDING TO CHATS
                    for (String friendEmail in chats) {
                      for (MessageInfo element in widget.selectedMessage) {
                        if (element.type == 'txt') {
                          //text type
                          String lastMessage = element.message.length <= 25
                              ? element.message
                              : element.message.substring(0, 25) + '...';
                          DateTime time = DateTime.now();
                          String messageId = Uuid().v4();
                          //adding to current user database
                          _firestore
                              .collection('users')
                              .doc(myEmail)
                              .collection('chats')
                              .doc(friendEmail)
                              .set(
                            {
                              'email': friendEmail,
                              'name': nameofChat[friendEmail],
                              'search_name':
                                  nameofChat[friendEmail].toLowerCase(),
                              'last_message': lastMessage,
                              'new_message': false,
                              'time': time,
                              'type': 'txt',
                            },
                          );
                          _firestore
                              .collection('users')
                              .doc(myEmail)
                              .collection('chats')
                              .doc(friendEmail)
                              .collection('messages')
                              .doc(messageId)
                              .set(
                            {
                              'message': element.message,
                              'sender': myEmail,
                              'time': time,
                              'type': 'txt',
                              'id': messageId,
                            },
                          );
                          //adding message to friend database
                          _firestore
                              .collection('users')
                              .doc(friendEmail)
                              .collection('chats')
                              .doc(myEmail)
                              .set(
                            {
                              'email': myEmail,
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
                              .doc(friendEmail)
                              .collection('chats')
                              .doc(myEmail)
                              .collection('messages')
                              .doc(messageId)
                              .set(
                            {
                              'message': element.message,
                              'sender': myEmail,
                              'time': time,
                              'type': 'txt',
                              'id': messageId,
                            },
                          );
                        } else {
                          if (imageCount.containsKey(element.imageName)) {
                            imageCount[element.imageName] =
                                imageCount[element.imageName] +
                                    (widget.from == 'chat' ? 2 : 1);
                          } else {
                            imageCount[element.imageName] =
                                (widget.from == 'chat' ? 2 : 1);
                          }

                          String lastMessage = element.message.length <= 25
                              ? element.message
                              : element.message.substring(0, 25) + '...';
                          DateTime time = DateTime.now();
                          String messageId = Uuid().v4();
                          _firestore
                              .collection('users')
                              .doc(myEmail)
                              .collection('chats')
                              .doc(friendEmail)
                              .set(
                            {
                              'email': friendEmail,
                              'name': nameofChat[friendEmail],
                              'search_name':
                                  nameofChat[friendEmail].toLowerCase(),
                              'last_message': lastMessage,
                              'new_message': false,
                              'time': time,
                              'type': 'img',
                            },
                          );
                          _firestore
                              .collection('users')
                              .doc(myEmail)
                              .collection('chats')
                              .doc(friendEmail)
                              .collection('messages')
                              .doc(messageId)
                              .set(
                            {
                              'message': element.message,
                              'sender': myEmail,
                              'time': time,
                              'type': 'img',
                              'id': messageId,
                              'image_url': element.url,
                              'image_name': element.imageName,
                            },
                          );
                          //adding message to friend database
                          _firestore
                              .collection('users')
                              .doc(friendEmail)
                              .collection('chats')
                              .doc(myEmail)
                              .set(
                            {
                              'email': myEmail,
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
                              .doc(friendEmail)
                              .collection('chats')
                              .doc(myEmail)
                              .collection('messages')
                              .doc(messageId)
                              .set(
                            {
                              'message': element.message,
                              'sender': myEmail,
                              'time': time,
                              'type': 'img',
                              'id': messageId,
                              'image_url': element.url,
                              'image_name': element.imageName,
                            },
                          );
                        }
                      }
                    }

                    for (String groupId in groups) {
                      for (MessageInfo element in widget.selectedMessage) {
                        if (element.type == 'txt') {
                          //text type
                          String lastMessage = element.message.length <= 25
                              ? element.message
                              : element.message.substring(0, 25) + '...';
                          DateTime time = DateTime.now();
                          String messageId = Uuid().v4();
                          //adding to current user database
                          _firestore.collection('groups').doc(groupId).update(
                            {
                              'last_message': lastMessage,
                              'read': [],
                              'type': 'txt',
                              'time': time,
                            },
                          );
                          _firestore
                              .collection('groups')
                              .doc(groupId)
                              .collection('messages')
                              .doc(messageId)
                              .set(
                            {
                              'message': element.message,
                              'sender': _auth.currentUser.email,
                              'time': time,
                              'type': 'txt',
                              'name': myName,
                              'id': messageId,
                              'deleted_by': [],
                            },
                          );
                        } else {
                          if (imageCount.containsKey(element.imageName)) {
                            imageCount[element.imageName] =
                                imageCount[element.imageName] +
                                    sizeOfGroup[groupId];
                          } else {
                            imageCount[element.imageName] =
                                sizeOfGroup[groupId];
                          }

                          String lastMessage = element.message.length <= 25
                              ? element.message
                              : element.message.substring(0, 25) + '...';
                          DateTime time = DateTime.now();
                          String messageId = Uuid().v4();
                          _firestore.collection('groups').doc(groupId).update(
                            {
                              'last_message': lastMessage,
                              'read': [],
                              'type': 'img',
                              'time': time,
                            },
                          );
                          _firestore
                              .collection('groups')
                              .doc(groupId)
                              .collection('messages')
                              .doc(messageId)
                              .set(
                            {
                              'message': element.message,
                              'sender': _auth.currentUser.email,
                              'time': time,
                              'type': 'img',
                              'image_url': element.url,
                              'name': myName,
                              'id': messageId,
                              'image_name': element.imageName,
                              'deleted_by': [],
                            },
                          );
                        }
                      }
                    }

                    imageCount.forEach((key, counter) async {
                      int count = await _firestore
                          .collection('shared_images')
                          .doc(key)
                          .get()
                          .then((value) => value.data()['count']);
                      count += counter;
                      _firestore
                          .collection('shared_images')
                          .doc(key)
                          .set({'count': count});
                    });
                    await Flushbar(
                      message: "sending.....",
                      margin: EdgeInsets.all(8),
                      borderRadius: 8,
                      icon: Icon(
                        Icons.send,
                        color: Colors.blue[300],
                        size: 20,
                      ),
                      duration: Duration(seconds: 1),
                    ).show(context);
                    await Provider.of<SelectedUser>(context, listen: false)
                        .clearChat();
                    await Provider.of<SelectedUser>(context, listen: false)
                        .clearGroup();
                    setState(() {
                      spin = false;
                    });
                    Navigator.pop(context, true);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
