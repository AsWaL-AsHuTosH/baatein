import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RequestTile extends StatelessWidget {
  final String senderEmail;
  final String name;
  final String day, time;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firesotre = FirebaseFirestore.instance;
  RequestTile({@required this.senderEmail, @required this.name, this.day, this.time});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(1.0),
      padding: EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            child: Icon(Icons.person),
            radius: 30,
          ),
          SizedBox(
            width: 10,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
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
          GestureDetector(
            onTap: () async {
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
                  .add({'email': senderEmail, 'name': name});
              //adding friend to his/her list
              _firesotre
                  .collection('users')
                  .doc(senderEmail)
                  .collection('friends')
                  .add({'email': myEmail, 'name': myName});
              //removing request
              _firesotre
                  .collection('requests')
                  .doc(myEmail)
                  .collection('request')
                  .doc(senderEmail)
                  .delete();
            },
            child: CircleAvatar(
              backgroundColor: Colors.green,
              child: Icon(
                Icons.check,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(
            width: 5,
          ),
          GestureDetector(
            onTap: () {
              //removing request
              _firesotre
                  .collection('requests')
                  .doc(_auth.currentUser.email)
                  .collection('request')
                  .doc(senderEmail)
                  .delete();
            },
            child: CircleAvatar(
              backgroundColor: Colors.red,
              child: Icon(
                Icons.clear,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
      decoration: BoxDecoration(
        color: Color(0xffffccbc),
        borderRadius: BorderRadius.all(
          Radius.circular(15),
        ),
      ),
    );
  }
}
