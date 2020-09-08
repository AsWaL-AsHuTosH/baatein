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
  final String time;
  final Function spinTrue, spinFalse;
  GroupChatCard({
    @required this.groupName,
    @required this.newMessage,
    @required this.lastMessage,
    @required this.groupId,
    @required this.time,
    @required this.isImage,
    @required this.groupAdmin,
    @required this.spinFalse,
    @required this.spinTrue,
  });
  Widget message() {
    return isImage
        ? Icon(Icons.image)
        : Text(
            lastMessage,
            style: TextStyle(
              color: newMessage ? Colors.black : Colors.black45,
              fontSize: 15,
              fontWeight: newMessage ? FontWeight.bold : FontWeight.normal,
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
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
          margin: EdgeInsets.symmetric(vertical: 1.0, horizontal: 1.0),
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () async {
                  FocusScope.of(context).unfocus();
                  spinTrue();
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
                  spinFalse();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GroupProfileView(
                        groupId: groupId,
                        groupName: groupName,
                        groupAdmin: groupAdmin,
                        members: members,
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
                          color: newMessage ? Colors.black : Colors.black45,
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Icon(
                      newMessage ? Icons.sms : null,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
