import 'package:baatein/chat/group_setup_screen.dart';
import 'package:baatein/classes/SelectedUser.dart';
import 'package:baatein/constants/constants.dart';
import 'package:baatein/customs/friend_selection_card.dart';
import 'package:baatein/customs/round_text_button.dart';
import 'package:baatein/customs/search_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

class GroupSelectionScreen extends StatefulWidget {
  static const String routeId = 'group_selection_screen';
  @override
  _GroupSelectionScreenState createState() => _GroupSelectionScreenState();
}

class _GroupSelectionScreenState extends State<GroupSelectionScreen> {
  String data1;
  String data2;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).accentColor,
      body: SafeArea(
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 2.0),
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
              stream: _firestore
                  .collection('users')
                  .doc(_auth.currentUser.email)
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
              padding: const EdgeInsets.all(30.0),
              child: RoundTextButton(
                text: 'Setup Group',
                icon: Icons.group,
                onPress: () async {
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
                    return;
                  }
                  bool ok = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GroupSetup(
                          selected:
                              Provider.of<SelectedUser>(context, listen: false)
                                  .getListChat()),
                    ),
                  );
                  if (ok == null || ok == false) {
                    Navigator.pop(context, false);
                  } else {
                    Navigator.pop(context, true);
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
