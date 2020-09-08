import 'package:baatein/chat/group_profile_view.dart';
import 'package:baatein/classes/SelectedUser.dart';
import 'package:baatein/constants/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GroupSelectionCard extends StatelessWidget {
  final String groupName;
  final String groupAdmin;
  final String groupId;
  final bool isSelected;
  GroupSelectionCard(
      {@required this.groupName,
      this.isSelected,
      @required this.groupAdmin,
      this.groupId});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: () async {
          SelectedUser ref = Provider.of<SelectedUser>(context, listen: false);
          if (ref.isAlreadySelectedGroup(id: groupId)) {
            ref.deSelectGroup(id: groupId);
            await FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser.email)
                .collection('groups')
                .doc(groupId)
                .update({
              'selected': false,
            });
            return;
          }
          ref.addSelectionGroup(
            id: groupId,
            name: groupName,
          );

          await FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser.email)
              .collection('groups')
              .doc(groupId)
              .update({
            'selected': true,
          });
        },
        child: Container(
          color: isSelected ? Colors.black12 : Colors.white,
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
                    if (snapshot.hasData) {
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
                  Text(
                    'Admin: $groupAdmin',
                    style: TextStyle(
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
