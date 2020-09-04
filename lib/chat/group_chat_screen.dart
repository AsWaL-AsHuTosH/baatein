import 'package:baatein/chat/friends_search_screen.dart';
import 'package:baatein/chat/group_selection_screen.dart';
import 'package:baatein/classes/SelectedUser.dart';
import 'package:baatein/customs/group_chat_card.dart';
import 'package:baatein/customs/round_text_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_time_format/date_time_format.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

class GroupChatScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.search, color: Colors.white),
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: () =>
              Navigator.pushNamed(context, FreindSearchScreen.routeId)),
      body: Container(
        color: Theme.of(context).accentColor,
        child: Column(
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('groups')
                  .where('members', arrayContains: _auth.currentUser.email)
                  .snapshots(),
              builder: (context, snaps) {
                List<GroupChatCard> groupList = [];
                if (snaps.hasData) {
                  final groups = snaps.data.docs;
                  if (groups != null) {
                    for (var group in groups) {
                      String name = group.data()['name'];
                      String admin = group.data()['admin'];
                      String id = group.data()['id'];
                      bool isImage = group.data()['type'] == 'img';
                      String lastMessage = group.data()['last_message'];
                      Timestamp stamp = group.data()['time'];
                      String time;
                        if(stamp != null)
                             time  =  DateTimeFormat.format(stamp.toDate(), format: 'h:i a');
                        else 
                            time = '';
                      bool newMessage;
                      var data = group.data()['read'];
                      if(data == null)
                        newMessage = true;
                      else
                        newMessage = !List.from(data).contains(_auth.currentUser.email);
                      groupList.add(
                        GroupChatCard(
                          groupAdmin: admin,
                          groupId: id,
                          groupName: name,
                          isImage: isImage,
                          lastMessage: lastMessage == null ? '' : lastMessage,
                          newMessage: newMessage,
                          time: time,
                        ),
                      );
                    }
                  }
                }
                return Expanded(
                  child: ListView(
                    children: groupList,
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.only(right: 80.0, bottom: 18),
              child: RoundTextButton(
                text: 'Create Group',
                icon: Icons.group,
                onPress: () async {
                  var ok = await Navigator.pushNamed(
                      context, GroupSelectionScreen.routeId);
                  if (ok != null && ok == true) {
                    Flushbar(
                      message: "Group created successfully.",
                      backgroundGradient:
                          LinearGradient(colors: [Colors.red, Colors.orange]),
                      icon: Icon(
                        Icons.check,
                        color: Colors.green,
                        size: 40,
                      ),
                      margin: EdgeInsets.all(8),
                      borderRadius: 8,
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 3),
                      boxShadows: [
                        BoxShadow(
                          color: Colors.lightBlueAccent,
                          offset: Offset(0.0, 2.0),
                          blurRadius: 3.0,
                        )
                      ],
                    ).show(context);
                    return;
                  }
                  for(String email in Provider.of<SelectedUser>(context, listen: false).getList()){
                    await _firestore.collection('users').doc(_auth.currentUser.email).collection('friends').doc(email).update({'selected': false});
                  }
                  Provider.of<SelectedUser>(context, listen: false).clear();     
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
