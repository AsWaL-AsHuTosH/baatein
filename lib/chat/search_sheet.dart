import 'package:baatein/customs/round_text_button.dart';
import 'package:baatein/customs/search_field.dart';
import 'package:baatein/provider/firebase_service.dart';
import 'package:baatein/provider/logged_in_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:date_time_format/date_time_format.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';

class SearchSheet extends StatefulWidget {
  @override
  _SearchSheetState createState() => _SearchSheetState();
}

class _SearchSheetState extends State<SearchSheet> {
  bool otherError = false, spin = false;
  String errorMessage;
  final TextEditingController controller = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  LoggedInUser _user;
  FirebaseService _firebase;
  
  @override
  void initState() {
    super.initState();
    initLoggedInUser();
    initFirebaseService();
  }

  void initFirebaseService() =>
      _firebase = Provider.of<FirebaseService>(context, listen: false);

  void initLoggedInUser() =>
      _user = Provider.of<LoggedInUser>(context, listen: false);
      
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: ModalProgressHUD(
        inAsyncCall: spin,
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
                trailing: false,
                controller: controller,
                formKey: _formKey,
                validator: (val) {
                  if (otherError) {
                    otherError = false;
                    return errorMessage;
                  }
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
                  setState(() {
                    spin = true;
                  });
                  if (_formKey.currentState.validate()) {
                    if (controller.text.trim() == _user.email) {
                      otherError = true;
                      errorMessage = 'You can\'t send request to yourself!';
                    } else if (await _firebase.firestore
                        .collection('users')
                        .doc(controller.text.trim())
                        .get()
                        .then((value) => !value.exists)) {
                      otherError = true;
                      errorMessage =
                          'There is no user record corresponding to provided email!';
                    } else if (await _firebase.firestore
                        .collection('users')
                        .doc(_user.email)
                        .collection('friends')
                        .doc(controller.text.trim())
                        .get()
                        .then((value) => value.exists)) {
                      otherError = true;
                      errorMessage = 'You are already friends!';
                    } else if (await _firebase.firestore
                        .collection('requests')
                        .doc(FirebaseAuth.instance.currentUser.email)
                        .collection('request')
                        .doc(controller.text.trim())
                        .get()
                        .then((value) => value.exists ? true : false)) {
                      otherError = true;
                      errorMessage = 'You have a request from same email!';
                    }
                    if (otherError) {
                      setState(() {
                        spin = false;
                      });
                      _formKey.currentState.validate();
                      return;
                    }
                    DateTime stamp = DateTime.now();
                    String day =
                        DateTimeFormat.format(stamp, format: 'D, M d, Y');
                    String time = DateTimeFormat.format(stamp, format: 'h:i a');
                    String myEmail = FirebaseAuth.instance.currentUser.email;
                    String myName = await _firebase.firestore
                        .collection('users')
                        .doc(myEmail)
                        .get()
                        .then((doc) => doc.data()['name']);
                    _firebase.firestore
                        .collection('requests')
                        .doc(controller.text.trim())
                        .collection('request')
                        .doc(myEmail)
                        .set({
                      'from': myEmail,
                      'name': myName,
                      'search_name': myName.toLowerCase(),
                      'time': time,
                      'day': day
                    });
                    setState(() {
                      spin = false;
                    });
                    Navigator.pop(context, true);
                  } else {
                    setState(() {
                      spin = false;
                    });
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
