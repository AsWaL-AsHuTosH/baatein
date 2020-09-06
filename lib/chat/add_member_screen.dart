import 'package:baatein/classes/SelectedUser.dart';
import 'package:baatein/constants/constants.dart';
import 'package:baatein/customs/friend_selection_card.dart';
import 'package:baatein/customs/round_text_button.dart';
import 'package:baatein/customs/search_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';

class AddMemberScreen extends StatefulWidget {
  final Set<String> already;
  final String groupId;
  AddMemberScreen({this.already, @required this.groupId});
  @override
  _AddMemberScreenState createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  String data1;
  String data2;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool spin = false;
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
                  labelText: null,
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
                        bool disableSelection = widget.already.contains(email);
                        MaterialColor color;
                        if(disableSelection)
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
                    if( Provider.of<SelectedUser>(context, listen: false).isEmpty){
                      Flushbar(
                        message: "No member selected!",
                        backgroundGradient:
                            LinearGradient(colors: [Colors.grey, Colors.grey]),
                        icon: Icon(
                          Icons.error,
                          color: Colors.red[800],
                          size: 20,
                        ),
                        margin: EdgeInsets.all(4),
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
                      setState(() {
                        spin = false;
                      });
                      return;
                    }else{
                      FirebaseFirestore _firestore = FirebaseFirestore.instance;
                      final List<String> memberList =
                          Provider.of<SelectedUser>(context, listen: false)
                              .getListChat();
                      int size = await _firestore.collection('groups').doc(widget.groupId).get().then((value) => value.data()['size']);
                      size += memberList.length;
                      final List<Map<String, String>> nameList =
                          Provider.of<SelectedUser>(context, listen: false)
                              .getNameList();
                      await _firestore.collection('groups').doc(widget.groupId).update({
                        'members': FieldValue.arrayUnion(memberList),
                        'members_name': FieldValue.arrayUnion(nameList),
                        'size':size,
                      });
                      await Provider.of<SelectedUser>(context, listen: false).clearChat();
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
