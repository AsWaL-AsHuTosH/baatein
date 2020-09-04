import 'package:baatein/chat/image_view_screen.dart';
import 'package:baatein/customs/friend_tile.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:baatein/constants/constants.dart';

class GroupProfileView extends StatelessWidget {
  final String groupId, groupName, groupAdmin;
  final List<String> memebers;
  final Map<String,dynamic> membersName;

  GroupProfileView({this.groupId, this.groupName, this.groupAdmin, @required this.memebers, @required this.membersName});
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
                    if(url == null)
                      url = kNoGroupPic;
                    return CircleAvatar(
                      backgroundImage:NetworkImage(url),
                      radius: 80,
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 70.0),
                child: ListTile(
                  leading: Icon(
                    Icons.person,
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
                padding: const EdgeInsets.only(left : 70.0),
                child: ListTile(
                  leading: Icon(
                    Icons.person_pin,
                    color: Colors.black,
                  ),
                  title: Text(
                    groupAdmin,
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 10,
                      fontFamily: 'Source Sans Pro',
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
              ),
              SizedBox(child: Divider(color: Colors.grey, endIndent: 30, indent: 30,),),
              Expanded(child: ListView.builder(itemBuilder: (context, index) => FriendTile(friendName: membersName[memebers[index]],disableMainOnTap: true, friendEmail: memebers[index],),itemCount: memebers.length,)),
            ],
          ),
        ));
  }
}
