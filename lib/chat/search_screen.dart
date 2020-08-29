import 'package:baatein/customs/round_text_button.dart';
import 'package:baatein/customs/round_text_field.dart';
import 'package:baatein/customs/search_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:date_time_format/date_time_format.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(40.0),
            topLeft: Radius.circular(40.0),
          ),
        ),
        margin: EdgeInsets.only(top: 30),
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            SearchField(
              controller: controller,
              formKey: _formKey,
              validator: (val) {
                return RegExp(
                            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                        .hasMatch(val)
                    ? null
                    : "Please enter a valid email address!";
              },
            ),
            SizedBox(
              height: 10,
            ),
            RoundTextButton(
              color: Colors.blue,
              text: 'Send Request',
              icon: Icons.send,
              onPress: () async {
                if (_formKey.currentState.validate()) {
                  DateTime stamp = DateTime.now();
                  String day =
                      DateTimeFormat.format(stamp, format: 'D, M d, Y');
                  String time = DateTimeFormat.format(stamp, format: 'h:i a');
                  String myEmail = FirebaseAuth.instance.currentUser.email;
                  String myName = await FirebaseFirestore.instance
                      .collection('users')
                      .doc(myEmail)
                      .get()
                      .then((doc) => doc.data()['name']);
                  FirebaseFirestore.instance
                      .collection('requests')
                      .doc(controller.text.trim())
                      .collection('request')
                      .doc(myEmail)
                      .set({
                    'from': myEmail,
                    'name': myName,
                    'time': time,
                    'day': day
                  });
                  Navigator.pop(context);
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
