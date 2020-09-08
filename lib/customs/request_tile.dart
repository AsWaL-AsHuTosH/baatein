import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:baatein/chat/profile_view.dart';

class RequestTile extends StatelessWidget {
  final String senderEmail;
  final String senderName;
  final String day, time;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firesotre = FirebaseFirestore.instance;
  RequestTile(
      {@required this.senderEmail,
      @required this.senderName,
      this.day,
      this.time});
  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileView(
              isFriend: false,
              friendEmail: senderEmail,
              friendName: senderName,
            ),
          ),
        ),
        child: Container(
          margin: EdgeInsets.all(1.0),
          padding: EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('profile_pic')
                    .doc(senderEmail)
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
                    radius: 30,
                  );
                },
              ),
              SizedBox(
                width: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    senderName,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'ID: $senderEmail',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      letterSpacing: 0.5,
                      fontSize: 10.0,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  Divider(),
                  Text(
                    day,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      letterSpacing: 0.5,
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  Text(
                    time,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      letterSpacing: 0.5,
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
              Spacer(),
              IconButton(
                color: Colors.black,
                icon: Icon(
                  Icons.check,
                  color: Colors.green,
                ),
                onPressed: () async {
                  String myEmail = _auth.currentUser.email;
                  String myName = await FirebaseFirestore.instance
                      .collection('users')
                      .doc(myEmail)
                      .get()
                      .then((doc) => doc.data()['name']);
                  //adding friend to my list
                  _firesotre
                      .collection('users')
                      .doc(myEmail)
                      .collection('friends')
                      .doc(senderEmail)
                      .set({
                    'email': senderEmail,
                    'name': senderName,
                    'search_name': senderName.toLowerCase(),
                    'selected': false,
                  });
                  //adding friend to his/her list
                  _firesotre
                      .collection('users')
                      .doc(senderEmail)
                      .collection('friends')
                      .doc(myEmail)
                      .set({
                    'email': myEmail,
                    'name': myName,
                    'search_name': myName.toLowerCase(),
                    'selected': false,
                  });
                  //removing request
                  _firesotre
                      .collection('requests')
                      .doc(myEmail)
                      .collection('request')
                      .doc(senderEmail)
                      .delete();
                },
              ),
              SizedBox(
                width: 5,
              ),
              IconButton(
                icon: Icon(
                  Icons.clear,
                  color: Colors.red,
                ),
                onPressed: () {
                  //removing request
                  _firesotre
                      .collection('requests')
                      .doc(_auth.currentUser.email)
                      .collection('request')
                      .doc(senderEmail)
                      .delete();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
