import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RequestTile extends StatelessWidget {
  final String sender;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firesotre = FirebaseFirestore.instance;
  RequestTile({@required this.sender});
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
          Expanded(
            child: Text(
              sender,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          Spacer(),
          GestureDetector(
            onTap: (){
              //adding friend to my list
              _firesotre.collection('users').doc(_auth.currentUser.email).collection('friends').add({'name' : sender});
              //adding friend to his/her list
              _firesotre.collection('users').doc(sender).collection('friends').add({'name' : _auth.currentUser.email});
              //removing request
              _firesotre.collection('requests').doc(_auth.currentUser.email).collection('request').doc(sender).delete();
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
            onTap: (){
              //removing request
              _firesotre.collection('requests').doc(_auth.currentUser.email).collection('request').doc(sender).delete();
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
