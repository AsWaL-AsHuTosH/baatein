import 'package:baatein/chat/group_chat_room.dart';
import 'package:baatein/chat/group_profile_view.dart';
import 'package:baatein/constants/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GroupChatCard extends StatelessWidget {
  final bool newMessage, isImage;
  final String lastMessage;
  final String groupName;
  final String groupId;
  final String groupAdmin;
  final time;
  GroupChatCard(
      {@required this.groupName,
      @required this.newMessage,
      @required this.lastMessage,
      @required this.groupId,
      @required this.time,
      @required this.isImage,
      @required this.groupAdmin});
  Widget message() {
    return isImage
        ? Icon(Icons.image)
        : Text(
            lastMessage,
            style: TextStyle(
                color: Colors.black45,
                fontSize: 15,
                fontWeight: FontWeight.normal),
          );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GroupChatRoom(
              admin: groupAdmin,
              groupId: groupId,
              groupName: groupName,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: newMessage
              ? LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  stops: [0.1, 0.5, 0.7, 0.9],
                  colors: [
                    Colors.green[500],
                    Colors.green[600],
                    Colors.green[700],
                    Colors.green[800],
                  ],
                )
              : LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  stops: [0.1, 0.5, 0.7, 0.9],
                  colors: [
                    Colors.red[800],
                    Colors.red[300],
                    Colors.red[300],
                    Colors.red[800],
                  ],
                ),
          borderRadius: BorderRadius.all(
            Radius.circular(15),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              blurRadius: 1.0,
              color: Colors.black,
              offset: Offset(0.0, 1.0),
            )
          ],
        ),
        margin: EdgeInsets.symmetric(vertical: 1.0, horizontal: 1.0),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () async {
                List<String> members = List.from(await FirebaseFirestore
                    .instance
                    .collection('groups')
                    .doc(groupId)
                    .get()
                    .then((value) => value.data()['members']));
                List<dynamic> mapList = await FirebaseFirestore.instance
                    .collection('groups')
                    .doc(groupId)
                    .get()
                    .then((value) => value.data()['members_name']);
                Map<String, dynamic> membersName = {};
                for (var map in mapList) membersName.addAll(map);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GroupProfileView(
                      groupId: groupId,
                      groupName: groupName,
                      groupAdmin: groupAdmin,
                      memebers: members,
                      membersName: membersName,
                    ),
                  ),
                );
              },
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('profile_pic')
                    .doc(groupId)
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
                    radius: 30,
                  );
                },
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  groupName,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 5,
                ),
                message(),
              ],
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    time,
                    style: TextStyle(
                        color: Colors.black45,
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Icon(
                    newMessage ? Icons.sms : null,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
