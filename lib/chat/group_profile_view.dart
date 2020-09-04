import 'package:baatein/chat/add_member_screen.dart';
import 'package:baatein/chat/home_screen.dart';
import 'package:baatein/chat/image_view_screen.dart';
import 'package:baatein/customs/friend_tile.dart';
import 'package:baatein/customs/round_text_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:baatein/constants/constants.dart';

class GroupProfileView extends StatelessWidget {
  final String groupId, groupName, groupAdmin;
  final List<String> memebers;
  final Map<String, dynamic> membersName;

  GroupProfileView(
      {this.groupId,
      this.groupName,
      this.groupAdmin,
      @required this.memebers,
      @required this.membersName});
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
                onTap: () async {
                  String url = await FirebaseFirestore.instance
                      .collection('profile_pic')
                      .doc(groupId)
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
                    groupName,
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
                    membersName[groupAdmin] + '\n$groupAdmin',
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
                    if (memebers[index] == groupAdmin) {
                      return FriendTile(
                        friendName: membersName[memebers[index]],
                        readOnly: true,
                        friendEmail: memebers[index],
                        special: true,
                      );
                    }
                    return FriendTile(
                      friendName: membersName[memebers[index]],
                      readOnly: true,
                      friendEmail: memebers[index],
                    );
                  },
                  itemCount: memebers.length,
                ),
              ),
              FirebaseAuth.instance.currentUser.email == groupAdmin
                  ? Container(
                      width: 0,
                      height: 0,
                    )
                  : Padding(
                      padding:
                          const EdgeInsets.only(bottom: 8.0, left: 8, right: 8),
                      child: RoundTextButton(
                        text: 'Leave Group',
                        icon: Icons.directions_walk,
                        onPress: () async {
                          String email =
                              FirebaseAuth.instance.currentUser.email;
                          await FirebaseFirestore.instance
                              .collection('groups')
                              .doc(groupId)
                              .update({
                            'members': FieldValue.arrayRemove([email])
                          });
                          await FirebaseFirestore.instance
                              .collection('groups')
                              .doc(groupId)
                              .update({
                            'members_name': FieldValue.arrayRemove([
                              {email: membersName[email]}
                            ])
                          });
                          await Flushbar(
                            message:
                                "You are no longer a memeber of $groupName.",
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
                            duration: Duration(seconds: 1),
                            boxShadows: [
                              BoxShadow(
                                color: Colors.lightBlueAccent,
                                offset: Offset(0.0, 2.0),
                                blurRadius: 3.0,
                              )
                            ],
                          ).show(context);
                          Navigator.popUntil(
                              context, ModalRoute.withName(HomeScreen.routeId));
                        },
                      ),
                    ),
              FirebaseAuth.instance.currentUser.email == groupAdmin
                  ? Padding(
                      padding:
                          const EdgeInsets.only(bottom: 8.0, left: 8, right: 8),
                      child: RoundTextButton(
                        text: 'Add Members',
                        icon: Icons.person_add,
                        onPress: () async {
                          Set<String> memberSet = {};
                          memebers.forEach((element) {
                            memberSet.add(element);
                          });
                          bool ok = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddMemberScreen(
                                already: memberSet,
                                groupId: groupId,
                              ),
                            ),
                          );

                          if (ok != null || ok == true) {
                            await Flushbar(
                              message:
                                  "New members added successfully.",
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
                            Navigator.pop(context);
                          }
                        },
                      ),
                    )
                  : Container(
                      width: 0,
                      height: 0,
                    ),
              FirebaseAuth.instance.currentUser.email == groupAdmin
                  ? Padding(
                      padding:
                          const EdgeInsets.only(bottom: 8.0, left: 8, right: 8),
                      child: RoundTextButton(
                        text: 'Delete Group',
                        icon: Icons.delete,
                        color: Colors.red,
                        onPress: () async {
                          String email =
                              FirebaseAuth.instance.currentUser.email;
                          await FirebaseFirestore.instance
                              .collection('groups')
                              .doc(groupId)
                              .update({
                            'members': FieldValue.arrayRemove([email])
                          });
                          await FirebaseFirestore.instance
                              .collection('groups')
                              .doc(groupId)
                              .update({
                            'members_name': FieldValue.arrayRemove([
                              {email: membersName[email]}
                            ])
                          });
                          await Flushbar(
                            message:
                                "You are no longer a memeber of $groupName.",
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
                            duration: Duration(seconds: 1),
                            boxShadows: [
                              BoxShadow(
                                color: Colors.lightBlueAccent,
                                offset: Offset(0.0, 2.0),
                                blurRadius: 3.0,
                              )
                            ],
                          ).show(context);
                          Navigator.popUntil(
                              context, ModalRoute.withName(HomeScreen.routeId));
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
