import 'package:baatein/provider/firebase_service.dart';
import 'package:baatein/provider/logged_in_user.dart';
import 'package:baatein/provider/selected_user.dart';
import 'package:baatein/helper/message_info.dart';
import 'package:baatein/constants/constants.dart';
import 'package:baatein/customs/friend_selection_card.dart';
import 'package:baatein/customs/round_text_button.dart';
import 'package:baatein/customs/search_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class ChatForwardScreen extends StatefulWidget {
  final List<MessageInfo> selectedMessage;
  final String from;
  ChatForwardScreen({@required this.selectedMessage, this.from});
  @override
  _ChatForwardScreenState createState() => _ChatForwardScreenState();
}

class _ChatForwardScreenState extends State<ChatForwardScreen> {
  bool spin = false;
  String data1;
  String data2;
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
                  hintText: 'Type your friend name......',
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
              Provider.of<SelectedUser>(context, listen: true).isEmpty
                  ? Container()
                  : Container(
                      margin: EdgeInsets.all(4),
                      height: 60,
                      child: Consumer<SelectedUser>(
                        builder: (context, value, child) {
                          List<String> list = value.getListChat();
                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: list.length,
                            itemBuilder: (context, index) =>
                                StreamBuilder<QuerySnapshot>(
                              stream: _firebase.firestore
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
                                    radius: 30,
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
              Provider.of<SelectedUser>(context, listen: true).isEmpty
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
                stream: _firebase.firestore
                    .collection('users')
                    .doc(_user.email)
                    .collection('friends')
                    .where('search_name', isGreaterThanOrEqualTo: data1)
                    .where('search_name', isLessThan: data2)
                    .orderBy('search_name')
                    .snapshots(),
                builder: (context, snapshot) {
                  List<FriendSelectionCard> friendList = [];
                  if (snapshot.hasData) {
                    final friends = snapshot.data.docs;
                    if (friends != null) {
                      for (var friend in friends) {
                        String name = friend.data()['name'];
                        String email = friend.data()['email'];
                        bool isSelected = friend.data()['selected'];
                        friendList.add(
                          FriendSelectionCard(
                            friendName: name,
                            friendEmail: email,
                            isSelected: isSelected,
                            color: isSelected ? Colors.green : Colors.red,
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
                    LoggedInUser user = Provider.of<LoggedInUser>(context);
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
                      sizeOfGroup[id] = await _firebase.firestore
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
                          _firebase.firestore
                              .collection('users')
                              .doc(user.email)
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
                          _firebase.firestore
                              .collection('users')
                              .doc(user.email)
                              .collection('chats')
                              .doc(friendEmail)
                              .collection('messages')
                              .doc(messageId)
                              .set(
                            {
                              'message': element.message,
                              'sender': user.email,
                              'time': time,
                              'type': 'txt',
                              'id': messageId,
                            },
                          );
                          //adding message to friend database
                          _firebase.firestore
                              .collection('users')
                              .doc(friendEmail)
                              .collection('chats')
                              .doc(user.email)
                              .set(
                            {
                              'email': user.email,
                              'name': user.name,
                              'search_name': user.name.toLowerCase(),
                              'last_message': lastMessage,
                              'new_message': true,
                              'time': time,
                              'type': 'txt',
                            },
                          );
                          _firebase.firestore
                              .collection('users')
                              .doc(friendEmail)
                              .collection('chats')
                              .doc(user.email)
                              .collection('messages')
                              .doc(messageId)
                              .set(
                            {
                              'message': element.message,
                              'sender': user.email,
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
                          _firebase.firestore
                              .collection('users')
                              .doc(user.email)
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
                          _firebase.firestore
                              .collection('users')
                              .doc(user.email)
                              .collection('chats')
                              .doc(friendEmail)
                              .collection('messages')
                              .doc(messageId)
                              .set(
                            {
                              'message': element.message,
                              'sender': user.email,
                              'time': time,
                              'type': 'img',
                              'id': messageId,
                              'image_url': element.url,
                              'image_name': element.imageName,
                            },
                          );
                          //adding message to friend database
                          _firebase.firestore
                              .collection('users')
                              .doc(friendEmail)
                              .collection('chats')
                              .doc(user.email)
                              .set(
                            {
                              'email': user.email,
                              'name': user.name,
                              'search_name': user.name.toLowerCase(),
                              'last_message': lastMessage,
                              'new_message': true,
                              'time': time,
                              'type': 'img',
                            },
                          );
                          _firebase.firestore
                              .collection('users')
                              .doc(friendEmail)
                              .collection('chats')
                              .doc(user.email)
                              .collection('messages')
                              .doc(messageId)
                              .set(
                            {
                              'message': element.message,
                              'sender': user.email,
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
                          _firebase.firestore.collection('groups').doc(groupId).update(
                            {
                              'last_message': lastMessage,
                              'read': [],
                              'type': 'txt',
                              'time': time,
                            },
                          );
                          _firebase.firestore
                              .collection('groups')
                              .doc(groupId)
                              .collection('messages')
                              .doc(messageId)
                              .set(
                            {
                              'message': element.message,
                              'sender': _user.email,
                              'time': time,
                              'type': 'txt',
                              'name': user.name,
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
                          _firebase.firestore.collection('groups').doc(groupId).update(
                            {
                              'last_message': lastMessage,
                              'read': [],
                              'type': 'img',
                              'time': time,
                            },
                          );
                          _firebase.firestore
                              .collection('groups')
                              .doc(groupId)
                              .collection('messages')
                              .doc(messageId)
                              .set(
                            {
                              'message': element.message,
                              'sender': _user.email,
                              'time': time,
                              'type': 'img',
                              'image_url': element.url,
                              'name': user.name,
                              'id': messageId,
                              'image_name': element.imageName,
                              'deleted_by': [],
                            },
                          );
                        }
                      }
                    }

                    imageCount.forEach((key, counter) async {
                      int count = await _firebase.firestore
                          .collection('shared_images')
                          .doc(key)
                          .get()
                          .then((value) => value.data()['count']);
                      count += counter;
                      _firebase.firestore
                          .collection('shared_images')
                          .doc(key)
                          .set({'count': count});
                    });

                    await Flushbar(
                      message: "sending.....",
                      backgroundGradient:
                          LinearGradient(colors: [Colors.orange, Colors.red]),
                      icon: Icon(
                        Icons.flight_takeoff,
                        color: Colors.red[800],
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
