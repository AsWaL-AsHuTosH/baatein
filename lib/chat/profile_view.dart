import 'package:baatein/chat/home_screen.dart';
import 'package:baatein/chat/image_view_screen.dart';
import 'package:baatein/customs/round_text_button.dart';
import 'package:baatein/provider/firebase_service.dart';
import 'package:baatein/provider/logged_in_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_time_format/date_time_format.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';

class ProfileView extends StatefulWidget {
  final String friendEmail, friendName;
  final bool isFriend;
  ProfileView({this.friendEmail, this.friendName, @required this.isFriend});

  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  LoggedInUser _user;
  FirebaseService _firebase;
  bool spin = false;

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
        body: ModalProgressHUD(
          inAsyncCall: spin,
          child: Container(
            padding: EdgeInsets.only(top: 10),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () async {
                    String url = await _firebase.firestore
                        .collection('profile_pic')
                        .doc(widget.friendEmail)
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
                    stream: _firebase.firestore
                        .collection('profile_pic')
                        .doc(widget.friendEmail)
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
                StreamBuilder<QuerySnapshot>(
                  stream: _firebase.firestore
                      .collection('presence')
                      .doc(widget.friendEmail)
                      .collection('status')
                      .snapshots(),
                  builder: (context, snapshot) {
                    bool isOnline = false;
                    if (snapshot.hasData && snapshot.data != null) {
                      isOnline = snapshot.data.docs[0].data()['is_online'];
                    }
                    return isOnline
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Online',
                              style: TextStyle(
                                  fontFamily: 'Source Sans Pro',
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold),
                            ),
                          )
                        : Container(
                            width: 0,
                            height: 0,
                          );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 70.0),
                  child: ListTile(
                    leading: Icon(
                      Icons.person,
                      color: Colors.black,
                    ),
                    title: Text(
                      widget.friendName,
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
                      Icons.email,
                      color: Colors.black,
                    ),
                    title: Text(
                      widget.friendEmail,
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
                widget.isFriend
                    ? RoundTextButton(
                        color: Colors.red,
                        text: 'Unfriend',
                        icon: Icons.remove,
                        onPress: () async {
                          //show dialog
                          bool ok = await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(
                                  'Are you sure to unfriend ${widget.friendName}?'),
                              content: Text('This will also delete your chat.'),
                              actions: [
                                FlatButton(
                                  child: Text('Unfriend'),
                                  onPressed: () {
                                    Navigator.pop(context, true);
                                  },
                                ),
                                FlatButton(
                                  child: Text('Cancel'),
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                ),
                              ],
                            ),
                          );

                          if (ok != null && ok == true) {
                            setState(() {
                              spin = true;
                            });
                            // removing from friends collection both side
                            String myEmail = _user.email;
                            _firebase.firestore
                                .collection('users')
                                .doc(myEmail)
                                .collection('friends')
                                .doc(widget.friendEmail)
                                .delete();
                            _firebase.firestore
                                .collection('users')
                                .doc(widget.friendEmail)
                                .collection('friends')
                                .doc(myEmail)
                                .delete();

                            var myChat = await _firebase.firestore
                                .collection('users')
                                .doc(myEmail)
                                .collection('chats')
                                .doc(widget.friendEmail)
                                .collection('messages')
                                .get()
                                .then((value) =>
                                    value != null ? value.docs : null);
                            if (myChat != null) {
                              for (var message in myChat) {
                                if (message.data()['type'] == 'img') {
                                  String name = message.data()['image_name'];
                                  int count = await _firebase.firestore
                                      .collection('shared_images')
                                      .doc(name)
                                      .get()
                                      .then((value) => value.data()['count']);

                                  --count;
                                  if (count <= 0) {
                                    await _firebase.firestore
                                        .collection('shared_images')
                                        .doc(name)
                                        .delete();
                                    await FirebaseStorage.instance
                                        .ref()
                                        .child(name)
                                        .delete();
                                  } else {
                                    await _firebase.firestore
                                        .collection('shared_images')
                                        .doc(name)
                                        .update({'count': count});
                                  }
                                }

                                await _firebase.firestore
                                    .collection('users')
                                    .doc(myEmail)
                                    .collection('chats')
                                    .doc(widget.friendEmail)
                                    .collection('messages')
                                    .doc(message.id)
                                    .delete();
                              }
                            }

                            var friendChat = await _firebase.firestore
                                .collection('users')
                                .doc(widget.friendEmail)
                                .collection('chats')
                                .doc(myEmail)
                                .collection('messages')
                                .get()
                                .then((value) =>
                                    value != null ? value.docs : null);

                            if (friendChat != null) {
                              for (var message in friendChat) {
                                if (message.data()['type'] == 'img') {
                                  String name = message.data()['image_name'];
                                  int count = await _firebase.firestore
                                      .collection('shared_images')
                                      .doc(name)
                                      .get()
                                      .then((value) => value.data()['count']);

                                  --count;
                                  if (count <= 0) {
                                    await _firebase.firestore
                                        .collection('shared_images')
                                        .doc(name)
                                        .delete();
                                    await FirebaseStorage.instance
                                        .ref()
                                        .child(name)
                                        .delete();
                                  } else {
                                    await _firebase.firestore
                                        .collection('shared_images')
                                        .doc(name)
                                        .update({'count': count});
                                  }
                                }

                                await _firebase.firestore
                                    .collection('users')
                                    .doc(widget.friendEmail)
                                    .collection('chats')
                                    .doc(myEmail)
                                    .collection('messages')
                                    .doc(message.id)
                                    .delete();
                              }
                            }

                            await _firebase.firestore
                                .collection('users')
                                .doc(widget.friendEmail)
                                .collection('chats')
                                .doc(myEmail)
                                .delete();

                            await _firebase.firestore
                                .collection('users')
                                .doc(myEmail)
                                .collection('chats')
                                .doc(widget.friendEmail)
                                .delete();

                            await Flushbar(
                              message:
                                  "You are no longer friend with ${widget.friendName}.",
                              margin: EdgeInsets.all(8),
                              borderRadius: 8,
                              icon: Icon(
                                Icons.directions_walk,
                                color: Colors.blue[300],
                                size: 20,
                              ),
                              duration: Duration(seconds: 1),
                            ).show(context);

                            setState(() {
                              spin = false;
                            });
                            Navigator.popUntil(
                              context,
                              ModalRoute.withName(HomeScreen.routeId),
                            );
                          }
                        },
                      )
                    : FirebaseAuth.instance.currentUser.email !=
                            widget.friendEmail
                        ? RoundTextButton(
                            text: 'Send Request',
                            icon: Icons.person_add,
                            color: Colors.green,
                            onPress: () async {
                              setState(() {
                                spin = true;
                              });
                              if (await _firebase.firestore
                                  .collection('requests')
                                  .doc(FirebaseAuth.instance.currentUser.email)
                                  .collection('request')
                                  .doc(widget.friendEmail)
                                  .get()
                                  .then(
                                      (value) => value.exists ? true : false)) {
                                await Flushbar(
                                  message:
                                      "You already have request from same user!",
                                  margin: EdgeInsets.all(8),
                                  borderRadius: 8,
                                  icon: Icon(
                                    Icons.error,
                                    color: Colors.blue[300],
                                    size: 20,
                                  ),
                                  duration: Duration(seconds: 1),
                                ).show(context);

                                setState(() {
                                  spin = false;
                                });
                                return;
                              }
                              DateTime stamp = DateTime.now();
                              String day = DateTimeFormat.format(stamp,
                                  format: 'D, M d, Y');
                              String time =
                                  DateTimeFormat.format(stamp, format: 'h:i a');
                              String myEmail =
                                  FirebaseAuth.instance.currentUser.email;
                              String myName = await _firebase.firestore
                                  .collection('users')
                                  .doc(myEmail)
                                  .get()
                                  .then((doc) => doc.data()['name']);
                              _firebase.firestore
                                  .collection('requests')
                                  .doc(widget.friendEmail)
                                  .collection('request')
                                  .doc(myEmail)
                                  .set({
                                'from': myEmail,
                                'name': myName,
                                'search_name': myName.toLowerCase(),
                                'time': time,
                                'day': day
                              });

                              await Flushbar(
                                message: "Your reuest is sent successfully.",
                                margin: EdgeInsets.all(8),
                                borderRadius: 8,
                                icon: Icon(
                                  Icons.check_circle,
                                  color: Colors.blue[300],
                                  size: 20,
                                ),
                                duration: Duration(seconds: 1),
                              ).show(context);

                              setState(() {
                                spin = false;
                              });
                              Navigator.pop(context);
                            },
                          )
                        : Container(
                            width: 0,
                            height: 0,
                          ),
              ],
            ),
          ),
        ));
  }
}
