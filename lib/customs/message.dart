import 'package:flutter/material.dart';

class Message extends StatelessWidget {
  final String message;
  final bool isMe;
  Message({this.message, this.isMe});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.all(5.0),
          decoration: BoxDecoration(
            color: isMe? Colors.lightBlueAccent : Colors.grey,
            borderRadius: isMe? BorderRadius.only(
              topLeft: Radius.circular(30.0),
              topRight: Radius.circular(30.0),
              bottomLeft: Radius.circular(30.0),
              bottomRight: Radius.circular(0.0),
            ) : 
            BorderRadius.only(
              topLeft: Radius.circular(30.0),
              topRight: Radius.circular(30.0),
              bottomLeft: Radius.circular(0.0),
              bottomRight: Radius.circular(30.0),
            ),
             boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Colors.black, blurRadius: 2.5, offset: Offset(0.0, 1.0))
            ],
          ),
          child: Text(message),
        ),
      ],
    );
  }
}
