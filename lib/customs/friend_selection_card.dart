import 'package:baatein/classes/SelectedUser.dart';
import 'package:baatein/constants/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:baatein/chat/profile_view.dart';
import 'package:provider/provider.dart';

class FriendSelectionCard extends StatefulWidget {
  final String friendName;
  final String friendEmail;
  final bool isSelected;
  final MaterialColor color;
  final bool disableSelection;

  FriendSelectionCard({
    @required this.friendName,
    this.friendEmail,
    this.isSelected,
    this.color,
    this.disableSelection = false,
  });

  @override
  _FriendSelectionCardState createState() => _FriendSelectionCardState();
}

class _FriendSelectionCardState extends State<FriendSelectionCard> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: widget.disableSelection
            ? null
            : () async {
                SelectedUser ref =
                    Provider.of<SelectedUser>(context, listen: false);
                if (ref.isAlreadySelected(email: widget.friendEmail)) {
                  ref.deSelectChat(email: widget.friendEmail);
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser.email)
                      .collection('friends')
                      .doc(widget.friendEmail)
                      .update({
                    'selected': false,
                  });
                  return;
                }
                ref.addSelection(
                  email: widget.friendEmail,
                  name: widget.friendName,
                );

                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser.email)
                    .collection('friends')
                    .doc(widget.friendEmail)
                    .update({
                  'selected': true,
                });
              },
        child: Container(
          color: widget.disableSelection  || widget.isSelected ? Colors.black12 : Colors.white,
          padding: EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileView(
                      isFriend: true,
                      friendEmail: widget.friendEmail,
                      friendName: widget.friendName,
                    ),
                  ),
                ),
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
                    if (url == null) url = kNoProfilePic;
                    return CircleAvatar(
                      backgroundImage: NetworkImage(url),
                      radius: 30,
                    );
                  },
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.friendName,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.friendEmail,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        letterSpacing: 0.5,
                        fontSize: 10.0,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
