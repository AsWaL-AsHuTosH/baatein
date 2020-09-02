import 'package:baatein/chat/image_view_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileView extends StatelessWidget {
  final String friendEmail, friendName;
  ProfileView({this.friendEmail, this.friendName});
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
                      .doc(friendEmail)
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
                      .doc(friendEmail)
                      .collection('image')
                      .snapshots(),
                  builder: (context, snapshot) {
                    String url;
                    if (snapshot.hasData) {
                      final image = snapshot.data.docs;
                      url = image[0].data()['url'];
                    }
                    return CircleAvatar(
                      child: url != null ? null : Icon(Icons.person),
                      backgroundImage: url != null ? NetworkImage(url) : null,
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
                    friendName,
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
                    Icons.email,
                    color: Colors.black,
                  ),
                  title: Text(
                    friendEmail,
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 10,
                      fontFamily: 'Source Sans Pro',
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
              ),
              SizedBox(child: Divider(color: Colors.grey, endIndent: 30, indent: 30,),)
            ],
          ),
        ));
  }
}
