import 'package:baatein/chat/image_view_screen.dart';
import 'package:baatein/chat/profile_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GroupPhotoMessage extends StatelessWidget {
  final String photoUrl, message;
  final bool isMe, isSelected;
  final String time;
  final String senderName;
  final String senderEmail;
  final String id;
  final Function onLongPressCallback;
  final Function onTapCallback;
  GroupPhotoMessage({
    this.message,
    this.photoUrl,
    this.isMe,
    this.time,
    this.senderName,
    this.senderEmail,
    this.id,
    this.onLongPressCallback,
    this.onTapCallback,
    this.isSelected = false,
  });
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: onLongPressCallback,
      onTap: onTapCallback,
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.only(
                top: 5, bottom: 5, left: isMe ? 20 : 5, right: isMe ? 5 : 20),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.greenAccent
                  : isMe ? Colors.lightBlueAccent : Colors.white,
              borderRadius: isMe
                  ? BorderRadius.only(
                      topLeft: Radius.circular(10.0),
                      topRight: Radius.circular(10.0),
                      bottomLeft: Radius.circular(10.0),
                      bottomRight: Radius.circular(0.0),
                    )
                  : BorderRadius.only(
                      topLeft: Radius.circular(10.0),
                      topRight: Radius.circular(10.0),
                      bottomLeft: Radius.circular(0.0),
                      bottomRight: Radius.circular(10.0),
                    ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                    color: Colors.black,
                    blurRadius: 2.5,
                    offset: Offset(0.0, 1.0))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                isMe
                    ? Container(width: 0, height: 0)
                    : Material(
                        child: InkWell(
                          onTap: onTapCallback == null
                              ? () async {
                                  bool isFriend = await FirebaseFirestore
                                      .instance
                                      .collection('users')
                                      .doc(FirebaseAuth
                                          .instance.currentUser.email)
                                      .collection('friends')
                                      .doc(senderEmail)
                                      .get()
                                      .then((value) => value.exists);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProfileView(
                                        isFriend: isFriend,
                                        friendEmail: senderEmail,
                                        friendName: senderName,
                                      ),
                                    ),
                                  );
                                }
                              : null,
                          child: Text(
                            senderName,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87),
                          ),
                        ),
                      ),
                isMe
                    ? Container(width: 0, height: 0)
                    : SizedBox(
                        height: 5,
                      ),
                GestureDetector(
                  onTap: onTapCallback != null
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ImageViewScreen(
                                url: photoUrl,
                              ),
                            ),
                          );
                        },
                  child: Container(
                    constraints: BoxConstraints(maxHeight: 300, maxWidth: 300),
                    child: Image(
                      image: NetworkImage(photoUrl),
                    ),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  message,
                  textAlign: TextAlign.start,
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
          Padding(
            padding: isMe
                ? const EdgeInsets.only(right: 5)
                : const EdgeInsets.only(left: 5),
            child: Text(
              time,
              style: TextStyle(color: Colors.grey, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }
}
