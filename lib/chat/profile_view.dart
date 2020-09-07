import 'package:baatein/chat/home_screen.dart';
import 'package:baatein/chat/image_view_screen.dart';
import 'package:baatein/customs/round_text_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class ProfileView extends StatefulWidget {
  final String friendEmail, friendName;
  final bool isFriend;
  ProfileView({this.friendEmail, this.friendName, @required this.isFriend});

  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  bool spin = false;
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
                    String url = await FirebaseFirestore.instance
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
                    stream: FirebaseFirestore.instance
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
                            FirebaseFirestore _firestore =
                                FirebaseFirestore.instance;
                            FirebaseAuth _auth = FirebaseAuth.instance;
                            String myEmail = _auth.currentUser.email;
                            _firestore
                                .collection('users')
                                .doc(myEmail)
                                .collection('friends')
                                .doc(widget.friendEmail)
                                .delete();
                            _firestore
                                .collection('users')
                                .doc(widget.friendEmail)
                                .collection('friends')
                                .doc(myEmail)
                                .delete();

                            var myChat = await _firestore
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
                                  int count = await FirebaseFirestore.instance
                                      .collection('shared_images')
                                      .doc(name)
                                      .get()
                                      .then((value) => value.data()['count']);

                                  --count;
                                  if (count <= 0) {
                                    await FirebaseFirestore.instance
                                        .collection('shared_images')
                                        .doc(name)
                                        .delete();
                                    await FirebaseStorage.instance
                                        .ref()
                                        .child(name)
                                        .delete();
                                  } else {
                                    await FirebaseFirestore.instance
                                        .collection('shared_images')
                                        .doc(name)
                                        .update({'count': count});
                                  }
                                }

                                await _firestore
                                    .collection('users')
                                    .doc(myEmail)
                                    .collection('chats')
                                    .doc(widget.friendEmail)
                                    .collection('messages')
                                    .doc(message.id)
                                    .delete();
                              }
                            }

                            var friendChat = await _firestore
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
                                  int count = await FirebaseFirestore.instance
                                      .collection('shared_images')
                                      .doc(name)
                                      .get()
                                      .then((value) => value.data()['count']);

                                  --count;
                                  if (count <= 0) {
                                    await FirebaseFirestore.instance
                                        .collection('shared_images')
                                        .doc(name)
                                        .delete();
                                    await FirebaseStorage.instance
                                        .ref()
                                        .child(name)
                                        .delete();
                                  } else {
                                    await FirebaseFirestore.instance
                                        .collection('shared_images')
                                        .doc(name)
                                        .update({'count': count});
                                  }
                                }

                                await _firestore
                                    .collection('users')
                                    .doc(widget.friendEmail)
                                    .collection('chats')
                                    .doc(myEmail)
                                    .collection('messages')
                                    .doc(message.id)
                                    .delete();
                              }
                            }

                            await _firestore
                                .collection('users')
                                .doc(widget.friendEmail)
                                .collection('chats')
                                .doc(myEmail)
                                .delete();

                            await _firestore
                                .collection('users')
                                .doc(myEmail)
                                .collection('chats')
                                .doc(widget.friendEmail)
                                .delete();

                            await Flushbar(
                              message:
                                  "You are no longer friend with ${widget.friendName}.",
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
                              duration: Duration(seconds: 2),
                              boxShadows: [
                                BoxShadow(
                                  color: Colors.lightBlueAccent,
                                  offset: Offset(0.0, 2.0),
                                  blurRadius: 3.0,
                                )
                              ],
                            ).show(context);
                            setState(() {
                              spin = false;
                            });
                            Navigator.popUntil(context,
                                ModalRoute.withName(HomeScreen.routeId));
                          }
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
