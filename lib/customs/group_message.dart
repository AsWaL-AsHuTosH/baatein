import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GroupMessage extends StatelessWidget {
  final String message;
  final String senderName;
  final String senderEmail;
  final bool isMe;
  final String time;
  GroupMessage(
      {this.message, this.isMe, this.time, this.senderName, this.senderEmail});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.only(
              top: 5, bottom: 5, left: isMe ? 20 : 5, right: isMe ? 5 : 20),
          decoration: BoxDecoration(
            color: isMe ? Colors.lightBlueAccent : Colors.grey,
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
              isMe ? Container(width: 0, height: 0) : Text(senderName),
              isMe
                  ? Container(width: 0, height: 0)
                  : FractionallySizedBox(child: Divider(color: Colors.white), widthFactor: 0.33,),
              Text(message),
            ],
          ),
        ),
        Text(
          time,
          style: TextStyle(color: Colors.grey, fontSize: 10),
        )
      ],
    );
  }
}