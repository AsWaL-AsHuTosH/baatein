import 'package:baatein/chat/add_member_screen.dart';
import 'package:baatein/chat/home_screen.dart';
import 'package:baatein/chat/image_view_screen.dart';
import 'package:baatein/chat/profile_pic_edit.dart';
import 'package:baatein/provider/firebase_service.dart';
import 'package:baatein/provider/logged_in_user.dart';
import 'package:baatein/provider/selected_user.dart';
import 'package:baatein/customs/friend_tile.dart';
import 'package:baatein/customs/round_text_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:baatein/constants/constants.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';

class GroupProfileView extends StatefulWidget {
  final String groupId, groupName, groupAdmin;
  final List<String> members;
  final Map<String, dynamic> membersName;

  GroupProfileView(
      {this.groupId,
      this.groupName,
      this.groupAdmin,
      @required this.members,
      @required this.membersName});

  @override
  _GroupProfileViewState createState() => _GroupProfileViewState();
}

class _GroupProfileViewState extends State<GroupProfileView> {
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

  bool spin = false;
  Future<void> increaseCount(String name) async {
    int count = await _firebase.firestore
        .collection('shared_images')
        .doc(name)
        .get()
        .then((value) => value.data()['count']);

    ++count;
    await _firebase.firestore
        .collection('shared_images')
        .doc(name)
        .update({'count': count});
  }

  Future<void> reduceCountKickLeave(String name) async {
    int count = await _firebase.firestore
        .collection('shared_images')
        .doc(name)
        .get()
        .then((value) => value.data()['count']);
    if (count - 1 <= 0) {
      await _firebase.firestore.collection('shared_images').doc(name).delete();
      await _firebase.storage.ref().child(name).delete();
    } else {
      --count;
      await _firebase.firestore
          .collection('shared_images')
          .doc(name)
          .update({'count': count});
    }
  }

  Future<void> reduceCount(String name) async {
    int count = await _firebase.firestore
        .collection('shared_images')
        .doc(name)
        .get()
        .then((value) => value.data()['count']);
    if (count - widget.members.length <= 0) {
      await _firebase.firestore.collection('shared_images').doc(name).delete();
      await _firebase.storage.ref().child(name).delete();
    } else {
      count -= widget.members.length;
      await _firebase.firestore
          .collection('shared_images')
          .doc(name)
          .update({'count': count});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Padding(
            padding: const EdgeInsets.only(left: 63.0),
            child: Text(
              'Baatein',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
                fontFamily: 'DancingScript',
                color: Colors.white,
              ),
            ),
          ),
        ),
        body: ModalProgressHUD(
          inAsyncCall: spin,
          child: Container(
            padding: EdgeInsets.only(top: 10),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _user.email == widget.groupAdmin
                      ? () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfileEditScreen(
                                docId: widget.groupId,
                              ),
                            ),
                          );
                        }
                      : () async {
                          String url = await _firebase.firestore
                              .collection('profile_pic')
                              .doc(widget.groupId)
                              .collection('image')
                              .doc('image_url')
                              .get()
                              .then((value) => value.data()['url']);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ImageViewScreen(
                                url: url,
                              ),
                            ),
                          );
                        },
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _firebase.firestore
                        .collection('profile_pic')
                        .doc(widget.groupId)
                        .collection('image')
                        .snapshots(),
                    builder: (context, snapshot) {
                      String url;
                      if (snapshot.hasData &&
                          snapshot.data != null &&
                          snapshot.data.docs.isNotEmpty) {
                        final image = snapshot.data.docs;
                        url = image[0].data()['url'];
                      }
                      if (url == null) url = kNoGroupPic;
                      return CircleAvatar(
                        backgroundImage: NetworkImage(url),
                        backgroundColor: Colors.grey,
                        radius: 80,
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 70.0),
                  child: ListTile(
                    leading: Icon(
                      Icons.group,
                      color: Colors.black,
                    ),
                    title: Text(
                      widget.groupName,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 10,
                        fontFamily: 'Source Sans Pro',
                        letterSpacing: 5.0,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 70.0),
                  child: ListTile(
                    leading: Icon(
                      Icons.person_pin,
                      color: Colors.black,
                    ),
                    title: Text(
                      widget.membersName[widget.groupAdmin] +
                          '\n${widget.groupAdmin}',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 10,
                        fontFamily: 'Source Sans Pro',
                        letterSpacing: 2.0,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  child: Divider(
                    color: Colors.grey,
                    endIndent: 30,
                    indent: 30,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      if (_user.email == widget.groupAdmin) {
                        if (widget.members[index] == widget.groupAdmin) {
                          return FriendTile(
                            friendName:
                                widget.membersName[widget.members[index]],
                            readOnly: true,
                            friendEmail: widget.members[index],
                            special: true,
                          );
                        }
                        return FriendTile(
                          friendName: widget.membersName[widget.members[index]],
                          readOnly: true,
                          friendEmail: widget.members[index],
                          kick: true,
                          kickCallback: () async {
                            bool ok = await showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(
                                    'Are you sure to kick ${widget.membersName[widget.members[index]]}?'),
                                actions: [
                                  FlatButton(
                                    child: Text('Kick'),
                                    onPressed: () async {
                                      Navigator.pop(context, true);
                                    },
                                  ),
                                  FlatButton(
                                    child: Text('Cancel'),
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                  ),
                                ],
                              ),
                            );
                            if (ok != null && ok == true) {
                              setState(() {
                                spin = true;
                              });
                              String email = widget.members[index];
                              int size = await _firebase.firestore
                                  .collection('groups')
                                  .doc(widget.groupId)
                                  .get()
                                  .then((value) => value.data()['size']);
                              --size;

                              // REDUCING IMAGE COUNT OF ALL IMAGES IN SHARED IN GROUP.
                              var messages = await _firebase.firestore
                                  .collection('groups')
                                  .doc(widget.groupId)
                                  .collection('messages')
                                  .get()
                                  .then((value) =>
                                      value != null ? value.docs : null);
                              if (messages != null) {
                                for (var message in messages) {
                                  if (message.data()['type'] == 'img') {
                                    String name = message.data()['image_name'];
                                    if (!List.from(message.data()['deleted_by'])
                                        .contains(email))
                                      reduceCountKickLeave(name);
                                  }
                                }
                              }

                              await _firebase.firestore
                                  .collection('groups')
                                  .doc(widget.groupId)
                                  .update({
                                'members': FieldValue.arrayRemove([email]),
                                'size': size,
                              });
                              await _firebase.firestore
                                  .collection('groups')
                                  .doc(widget.groupId)
                                  .update({
                                'members_name': FieldValue.arrayRemove([
                                  {email: widget.membersName[email]}
                                ])
                              });
                              await _firebase.firestore
                                  .collection('users')
                                  .doc(email)
                                  .collection('groups')
                                  .doc(widget.groupId)
                                  .delete();

                              await Flushbar(
                                message:
                                    "${widget.membersName[widget.members[index]]} is no longer a member of group.",
                                margin: EdgeInsets.all(8),
                                borderRadius: 8,
                                icon: Icon(
                                  Icons.done,
                                  color: Colors.blue[300],
                                  size: 20,
                                ),
                                duration: Duration(seconds: 1),
                              ).show(context);

                              setState(() {
                                String email = widget.members[index];
                                widget.members.remove(email);
                                widget.membersName.remove(email);
                              });
                              setState(() {
                                spin = false;
                              });
                            }
                          },
                        );
                      } else {
                        if (widget.members[index] == widget.groupAdmin) {
                          return FriendTile(
                            friendName:
                                widget.membersName[widget.members[index]],
                            readOnly: true,
                            friendEmail: widget.members[index],
                            special: true,
                          );
                        }
                        return FriendTile(
                          friendName: widget.membersName[widget.members[index]],
                          readOnly: true,
                          friendEmail: widget.members[index],
                        );
                      }
                    },
                    itemCount: widget.members.length,
                  ),
                ),
                _user.email == widget.groupAdmin
                    ? Container(
                        width: 0,
                        height: 0,
                      )
                    : Padding(
                        padding: const EdgeInsets.only(
                            bottom: 8.0, left: 10, right: 10),
                        child: RoundTextButton(
                          text: 'Leave Group',
                          icon: Icons.directions_walk,
                          onPress: () async {
                            bool ok = await showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Are you sure to leave the group?'),
                                content: Text(
                                    'You will have no access to group once you leave.'),
                                actions: [
                                  FlatButton(
                                    child: Text('Leave'),
                                    onPressed: () async {
                                      Navigator.pop(context, true);
                                    },
                                  ),
                                  FlatButton(
                                    child: Text('Cancel'),
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                  ),
                                ],
                              ),
                            );

                            if (ok != null && ok == true) {
                              setState(() {
                                spin = true;
                              });
                              String email = _user.email;

                              var messages = await _firebase.firestore
                                  .collection('groups')
                                  .doc(widget.groupId)
                                  .collection('messages')
                                  .get()
                                  .then((value) =>
                                      value != null ? value.docs : null);
                              if (messages != null) {
                                for (var message in messages) {
                                  if (message.data()['type'] == 'img') {
                                    String name = message.data()['image_name'];
                                    if (!List.from(message.data()['deleted_by'])
                                        .contains(email))
                                      reduceCountKickLeave(name);
                                  }
                                }
                              }
                              await _firebase.firestore
                                  .collection('groups')
                                  .doc(widget.groupId)
                                  .update({
                                'members': FieldValue.arrayRemove([email])
                              });
                              await _firebase.firestore
                                  .collection('groups')
                                  .doc(widget.groupId)
                                  .update({
                                'members_name': FieldValue.arrayRemove([
                                  {email: widget.membersName[email]}
                                ])
                              });
                              await _firebase.firestore
                                  .collection('users')
                                  .doc(email)
                                  .collection('groups')
                                  .doc(widget.groupId)
                                  .delete();

                              int size = await _firebase.firestore
                                  .collection('groups')
                                  .doc(widget.groupId)
                                  .get()
                                  .then((value) => value.data()['size']);
                              --size;
                              await _firebase.firestore
                                  .collection('groups')
                                  .doc(widget.groupId)
                                  .update({
                                'members': FieldValue.arrayRemove([email]),
                                'size': size,
                              });
                              setState(() {
                                spin = false;
                              });

                              await Flushbar(
                                message:
                                    "You are no longer a memeber of '${widget.groupName}'.",
                                margin: EdgeInsets.all(8),
                                borderRadius: 8,
                                icon: Icon(
                                  Icons.directions_walk,
                                  color: Colors.blue[300],
                                  size: 20,
                                ),
                                duration: Duration(seconds: 1),
                              ).show(context);

                              Navigator.popUntil(context,
                                  ModalRoute.withName(HomeScreen.routeId));
                            }
                          },
                        ),
                      ),
                _user.email == widget.groupAdmin
                    ? Padding(
                        padding: const EdgeInsets.only(
                            bottom: 8.0, left: 8, right: 8),
                        child: RoundTextButton(
                          text: 'Add Members',
                          icon: Icons.person_add,
                          onPress: () async {
                            Set<String> memberSet = {};
                            widget.members.forEach((element) {
                              memberSet.add(element);
                            });
                            bool ok = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddMemberScreen(
                                  already: memberSet,
                                  groupId: widget.groupId,
                                  groupName: widget.groupName,
                                  groupAdmin: widget.groupAdmin,
                                ),
                              ),
                            );

                            if (ok != null || ok == true) {
                              await Flushbar(
                                message: "New members added successfully.",
                                margin: EdgeInsets.all(8),
                                borderRadius: 8,
                                icon: Icon(
                                  Icons.directions_walk,
                                  color: Colors.blue[300],
                                  size: 20,
                                ),
                                duration: Duration(seconds: 1),
                              ).show(context);
                              Navigator.pop(context);
                            }

                            await Provider.of<SelectedUser>(context,
                                    listen: false)
                                .clearChat();
                          },
                        ),
                      )
                    : Container(
                        width: 0,
                        height: 0,
                      ),
                _user.email == widget.groupAdmin
                    ? Padding(
                        padding: const EdgeInsets.only(
                            bottom: 8.0, left: 8, right: 8),
                        child: RoundTextButton(
                          text: 'Delete Group',
                          icon: Icons.delete,
                          color: Colors.red,
                          onPress: () async {
                            bool ok = await showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title:
                                    Text('Are you sure to delete the group?'),
                                content: Text(
                                    'This will delete your group permanently.'),
                                actions: [
                                  FlatButton(
                                    child: Text('Delete'),
                                    onPressed: () {
                                      Navigator.pop(context, true);
                                    },
                                  ),
                                  FlatButton(
                                    child: Text('Cancel'),
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                  ),
                                ],
                              ),
                            );

                            if (ok != null && ok == true) {
                              setState(() {
                                spin = true;
                              });
                              // REDUCING IMAGE COUNT OF ALL IMAGES IN SHARED IN GROUP.
                              var messages = await _firebase.firestore
                                  .collection('groups')
                                  .doc(widget.groupId)
                                  .collection('messages')
                                  .get()
                                  .then((value) =>
                                      value != null ? value.docs : null);
                              if (messages != null) {
                                for (var message in messages) {
                                  if (message.data()['type'] == 'img') {
                                    String name = message.data()['image_name'];
                                    await reduceCount(name);
                                  }
                                  await _firebase.firestore
                                      .collection('groups')
                                      .doc(widget.groupId)
                                      .collection('messages')
                                      .doc(message.id)
                                      .delete();
                                }
                              }
                              for (String email in widget.members)
                                await _firebase.firestore
                                    .collection('users')
                                    .doc(email)
                                    .collection('groups')
                                    .doc(widget.groupId)
                                    .delete();

                              await _firebase.firestore
                                  .collection('groups')
                                  .doc(widget.groupId)
                                  .delete();

                              if (await _firebase.firestore
                                      .collection('profile_pic')
                                      .doc(widget.groupId)
                                      .collection('image')
                                      .doc('image_url')
                                      .get()
                                      .then((value) => value.data()['url']) !=
                                  kNoGroupPic) {
                                await _firebase.storage
                                    .ref()
                                    .child(widget.groupId + '.jpg')
                                    .delete();
                              }
                              await _firebase.firestore
                                  .collection('profile_pic')
                                  .doc(widget.groupId)
                                  .collection('image')
                                  .doc('image_url')
                                  .delete();
                              await _firebase.firestore
                                  .collection('profile_pic')
                                  .doc(widget.groupId)
                                  .delete();

                              setState(() {
                                spin = false;
                              });

                              await Flushbar(
                                message:
                                    "${widget.groupName} is no longer available.",
                                margin: EdgeInsets.all(8),
                                borderRadius: 8,
                                icon: Icon(
                                  Icons.directions_walk,
                                  color: Colors.blue[300],
                                  size: 20,
                                ),
                                duration: Duration(seconds: 1),
                              ).show(context);

                              Navigator.popUntil(context,
                                  ModalRoute.withName(HomeScreen.routeId));
                            }
                          },
                        ),
                      )
                    : Container(
                        width: 0,
                        height: 0,
                      ),
              ],
            ),
          ),
        ));
  }
}
