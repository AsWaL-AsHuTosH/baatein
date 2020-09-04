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

  FriendSelectionCard({
    @required this.friendName,
    this.friendEmail,
    this.isSelected,
    this.color,
  });

  @override
  _FriendSelectionCardState createState() => _FriendSelectionCardState();
}

class _FriendSelectionCardState extends State<FriendSelectionCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        SelectedUser ref = Provider.of<SelectedUser>(context, listen: false);
        if (ref.isAlreadySelected(email: widget.friendEmail)) {
          ref.deSelect(email: widget.friendEmail);
          await FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser.email)
              .collection('friends')
              .doc(widget.friendEmail)
              .set({
            'email': widget.friendEmail,
            'name': widget.friendName,
            'search_name': widget.friendName.toLowerCase(),
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
            .set({
          'email': widget.friendEmail,
          'name': widget.friendName,
          'search_name': widget.friendName.toLowerCase(),
          'selected': true,
        });
      },
      child: Container(
        margin: EdgeInsets.all(3.0),
        padding: EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileView(
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            stops: [0.1, 0.5, 0.7, 0.9],
            colors: [
              widget.color[300],
              widget.color[400],
              widget.color[600],
              widget.color[800],
            ],
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(15),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              blurRadius: 1.0,
              color: Colors.black,
              offset: Offset(0.0, 1.0),
            )
          ],
        ),
      ),
    );
  }
}
