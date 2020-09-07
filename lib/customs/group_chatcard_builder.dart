import 'package:baatein/customs/group_chat_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_time_format/date_time_format.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GroupChatCardBuilder extends StatelessWidget {
  final String groupId;
  final Function spinTrue, spinFalse;
  GroupChatCardBuilder({this.groupId,@required this.spinFalse,@required this.spinTrue});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('groups')
          .where('id', isEqualTo: groupId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.data == null || snapshot.data.docs.isEmpty)
          return Container(
            width: 0,
            height: 0,
          );
        var group = snapshot.data.docs[0];
        String name = group.data()['name'];
        String admin = group.data()['admin'];
        String id = group.data()['id'];
        bool isImage = group.data()['type'] == 'img';
        String lastMessage = group.data()['last_message'];
        Timestamp stamp = group.data()['time'];
        String time = DateTimeFormat.format(stamp.toDate(), format: 'h:i a');
        bool newMessage;
        var data = group.data()['read'];
        if (data == null)
          newMessage = true;
        else
          newMessage = !List.from(data)
              .contains(FirebaseAuth.instance.currentUser.email);
        return GroupChatCard(
          spinFalse: spinFalse,
          spinTrue: spinTrue,
          groupAdmin: admin,
          groupId: id,
          groupName: name,
          isImage: isImage,
          lastMessage: lastMessage == null ? '' : lastMessage,
          newMessage: newMessage,
          time: time,
        );
      },
    );
  }
}
