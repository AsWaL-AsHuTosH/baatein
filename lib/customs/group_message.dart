import 'package:baatein/chat/profile_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GroupMessage extends StatelessWidget {
  final String message;
  final String senderName;
  final String senderEmail;
  final bool isMe, isSelected;
  final String time;
  final Function onLongpressCallback;
  final Function onTapCallback;
  GroupMessage({
    this.message,
    this.isMe,
    this.time,
    this.senderName,
    this.senderEmail,
    this.isSelected = false,
    this.onLongpressCallback,
    this.onTapCallback,
  });
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: onLongpressCallback,
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
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0),
                      bottomLeft: Radius.circular(20.0),
                      bottomRight: Radius.circular(0.0),
                    )
                  : BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0),
                      bottomLeft: Radius.circular(0.0),
                      bottomRight: Radius.circular(20.0),
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
                          onTap: () async {
                            bool isFriend = await FirebaseFirestore.instance
                                .collection('users')
                                .doc(FirebaseAuth.instance.currentUser.email)
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
                          },
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
                Text(
                  message,
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(color: Colors.grey, fontSize: 10),
          )
        ],
      ),
    );
  }
}
