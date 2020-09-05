import 'dart:io';

import 'package:baatein/chat/add_member_screen.dart';
import 'package:baatein/chat/home_screen.dart';
import 'package:baatein/chat/image_view_screen.dart';
import 'package:baatein/chat/profile_pic_edit.dart';
import 'package:baatein/classes/SelectedUser.dart';
import 'package:baatein/customs/friend_tile.dart';
import 'package:baatein/customs/round_text_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:baatein/constants/constants.dart';
import 'package:image_picker/image_picker.dart';
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
        body: Container(
          padding: EdgeInsets.only(top: 10),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap:
                    FirebaseAuth.instance.currentUser.email == widget.groupAdmin
                        ? () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfileEditScreen(
                                  docId: widget.groupId,
                                  editButtonCallback: () async {
                                    final ImagePicker picker = ImagePicker();
                                    final PickedFile pickedImage = await picker
                                        .getImage(source: ImageSource.gallery);
                                    if (pickedImage == null) return;
                                    final ref = FirebaseStorage.instance
                                        .ref()
                                        .child(widget.groupId +
                                            '.jpg');
                                    final File file = File(pickedImage.path);
                                    StorageUploadTask task = ref.putFile(file);
                                    StorageTaskSnapshot taskSnapshot =
                                        await task.onComplete;
                                    String url =
                                        await taskSnapshot.ref.getDownloadURL();
                                    FirebaseFirestore.instance
                                        .collection('profile_pic')
                                        .doc(widget.groupId)
                                        .collection('image')
                                        .doc('image_url')
                                        .update({'url': url});
                                    Flushbar(
                                      message:
                                          "Group profile picture is updated successfully.",
                                      backgroundGradient: LinearGradient(
                                          colors: [Colors.red, Colors.orange]),
                                      icon: Icon(
                                        Icons.check,
                                        color: Colors.green,
                                        size: 40,
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
                                  },
                                ),
                              ),
                            );
                          }
                        : () async {
                            String url = await FirebaseFirestore.instance
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
                    if (FirebaseAuth.instance.currentUser.email ==
                        widget.groupAdmin) {
                      if (widget.members[index] == widget.groupAdmin) {
                        return FriendTile(
                          friendName: widget.membersName[widget.members[index]],
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
                                    String email = widget.members[index];
                                    await FirebaseFirestore.instance
                                        .collection('groups')
                                        .doc(widget.groupId)
                                        .update({
                                      'members': FieldValue.arrayRemove([email])
                                    });
                                    await FirebaseFirestore.instance
                                        .collection('groups')
                                        .doc(widget.groupId)
                                        .update({
                                      'members_name': FieldValue.arrayRemove([
                                        {email: widget.membersName[email]}
                                      ])
                                    });
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
                            await Flushbar(
                              message:
                                  "${widget.membersName[widget.members[index]]} is no longer a member of group.",
                              backgroundGradient: LinearGradient(
                                  colors: [Colors.red, Colors.orange]),
                              icon: Icon(
                                Icons.done,
                                color: Colors.green,
                                size: 40,
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
                              String email = widget.members[index];
                              widget.members.remove(email);
                              widget.membersName.remove(email);
                            });
                          }
                        },
                      );
                    } else {
                      if (widget.members[index] == widget.groupAdmin) {
                        return FriendTile(
                          friendName: widget.membersName[widget.members[index]],
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
              FirebaseAuth.instance.currentUser.email == widget.groupAdmin
                  ? Container(
                      width: 0,
                      height: 0,
                    )
                  : Padding(
                      padding:
                          const EdgeInsets.only(bottom: 8.0, left: 10, right: 10),
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
                                    String email =
                                        FirebaseAuth.instance.currentUser.email;
                                    await FirebaseFirestore.instance
                                        .collection('groups')
                                        .doc(widget.groupId)
                                        .update({
                                      'members': FieldValue.arrayRemove([email])
                                    });
                                    await FirebaseFirestore.instance
                                        .collection('groups')
                                        .doc(widget.groupId)
                                        .update({
                                      'members_name': FieldValue.arrayRemove([
                                        {email: widget.membersName[email]}
                                      ])
                                    });
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
                            await Flushbar(
                              message:
                                  "You are no longer a memeber of '${widget.groupName}'.",
                              backgroundGradient: LinearGradient(
                                  colors: [Colors.red, Colors.orange]),
                              icon: Icon(
                                Icons.directions_walk,
                                color: Colors.green,
                                size: 40,
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
                            Navigator.popUntil(context,
                                ModalRoute.withName(HomeScreen.routeId));
                          }
                        },
                      ),
                    ),
              FirebaseAuth.instance.currentUser.email == widget.groupAdmin
                  ? Padding(
                      padding:
                          const EdgeInsets.only(bottom: 8.0, left: 8, right: 8),
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
                              ),
                            ),
                          );

                          if (ok != null || ok == true) {
                            await Flushbar(
                              message: "New members added successfully.",
                              backgroundGradient: LinearGradient(
                                  colors: [Colors.red, Colors.orange]),
                              icon: Icon(
                                Icons.check,
                                color: Colors.green,
                                size: 40,
                              ),
                              margin: EdgeInsets.all(8),
                              borderRadius: 8,
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 1),
                              boxShadows: [
                                BoxShadow(
                                  color: Colors.lightBlueAccent,
                                  offset: Offset(0.0, 2.0),
                                  blurRadius: 3.0,
                                )
                              ],
                            ).show(context);
                            Navigator.pop(context);
                          }
                          for (String email in Provider.of<SelectedUser>(
                                  context,
                                  listen: false)
                              .getList()) {
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(FirebaseAuth.instance.currentUser.email)
                                .collection('friends')
                                .doc(email)
                                .update({'selected': false});
                          }
                          Provider.of<SelectedUser>(context, listen: false)
                              .clear();
                        },
                      ),
                    )
                  : Container(
                      width: 0,
                      height: 0,
                    ),
              FirebaseAuth.instance.currentUser.email == widget.groupAdmin
                  ? Padding(
                      padding:
                          const EdgeInsets.only(bottom: 8.0, left: 8, right: 8),
                      child: RoundTextButton(
                        text: 'Delete Group',
                        icon: Icons.delete,
                        color: Colors.red,
                        onPress: () async {
                          bool ok = await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Are you sure to delete the group?'),
                              content: Text(
                                  'This will delete your group permanently.'),
                              actions: [
                                FlatButton(
                                  child: Text('Delete'),
                                  onPressed: () async {
                                    await FirebaseFirestore.instance
                                        .collection('groups')
                                        .doc(widget.groupId)
                                        .delete();
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
                            await Flushbar(
                              message:
                                  "${widget.groupName} is no longer available.",
                              backgroundGradient: LinearGradient(
                                  colors: [Colors.red, Colors.orange]),
                              icon: Icon(
                                Icons.directions_walk,
                                color: Colors.green,
                                size: 40,
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
        ));
  }
}
