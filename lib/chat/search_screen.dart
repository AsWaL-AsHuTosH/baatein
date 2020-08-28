import 'package:baatein/customs/round_text_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  static const routeId = 'search_screen';
  final TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Container(
        margin: EdgeInsets.only(top: 30),
          child: Column(
          children: [
            RoundTextField(color: Colors.black,controller: controller,),
            RaisedButton(
              onPressed: (){
                String myEmail = FirebaseAuth.instance.currentUser.email;
                FirebaseFirestore.instance.collection('requests').doc(controller.text).collection('request').doc(myEmail).set({'from': myEmail});
              },
              child: Text('SEND'),
            )
          ],
        ),
      ),
    );
  }
}
