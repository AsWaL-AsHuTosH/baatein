import 'package:baatein/provider/firebase_service.dart';
import 'package:baatein/provider/logged_in_user.dart';
import 'package:baatein/provider/selected_user.dart';
import 'package:baatein/constants/constants.dart';
import 'package:baatein/customs/friend_selection_card.dart';
import 'package:baatein/customs/round_text_button.dart';
import 'package:baatein/customs/search_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';

class AddMemberScreen extends StatefulWidget {
  final Set<String> already;
  final String groupId, groupName, groupAdmin;
  AddMemberScreen(
      {this.already, @required this.groupId, this.groupName, this.groupAdmin});
  @override
  _AddMemberScreenState createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  LoggedInUser _user;
  FirebaseService _firebase;
  String data1;
  String data2;
  bool spin = false;

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
                        bool disableSelection = widget.already.contains(email);
                        MaterialColor color;
                        if (disableSelection)
                          color = Colors.grey;
                        else
                          color = isSelected ? Colors.green : Colors.red;
                        friendList.add(
                          FriendSelectionCard(
                            friendName: name,
                            friendEmail: email,
                            isSelected: isSelected,
                            color: color,
                            disableSelection: disableSelection,
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
                padding: const EdgeInsets.all(30.0),
                child: RoundTextButton(
                  text: 'Done',
                  icon: Icons.check,
                  onPress: () async {
                    setState(() {
                      spin = true;
                    });
                    if (Provider.of<SelectedUser>(context, listen: false)
                        .isEmpty) {
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
                    } else {
                      final List<String> memberList =
                          Provider.of<SelectedUser>(context, listen: false)
                              .getListChat();
                      int size = await _firebase.firestore
                          .collection('groups')
                          .doc(widget.groupId)
                          .get()
                          .then((value) => value.data()['size']);
                      size += memberList.length;
                      final List<Map<String, String>> nameList =
                          Provider.of<SelectedUser>(context, listen: false)
                              .getNameList();
                      await _firebase.firestore
                          .collection('groups')
                          .doc(widget.groupId)
                          .update({
                        'members': FieldValue.arrayUnion(memberList),
                        'members_name': FieldValue.arrayUnion(nameList),
                        'size': size,
                      });
                      //increasing image count.
                      var messages = await _firebase.firestore
                          .collection('groups')
                          .doc(widget.groupId)
                          .collection('messages')
                          .get()
                          .then((value) => value != null ? value.docs : null);

                      if (messages != null) {
                        for (var message in messages) {
                          if (message.data()['type'] == 'img') {
                            String name = message.data()['image_name'];
                            int count = await _firebase.firestore
                                .collection('shared_images')
                                .doc(name)
                                .get()
                                .then((value) => value.data()['count']);
                            count += memberList.length;
                            await _firebase.firestore
                                .collection('shared_images')
                                .doc(name)
                                .update({'count': count});
                          }
                        }
                      }
                      //Adding group to each memeber collection
                      for (String email in memberList)
                        await _firebase.firestore
                            .collection('users')
                            .doc(email)
                            .collection('groups')
                            .doc(widget.groupId)
                            .set({
                          'name': widget.groupName,
                          'search_name': widget.groupName.toLowerCase(),
                          'id': widget.groupId,
                          'selected': false,
                          'admin': widget.groupAdmin,
                        });
                      await Provider.of<SelectedUser>(context, listen: false)
                          .clearChat();
                      setState(() {
                        spin = false;
                      });
                      Navigator.pop(context, true);
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
