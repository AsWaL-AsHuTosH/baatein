import 'package:flutter/material.dart';

class Message extends StatelessWidget {
  final String message;
  final bool isMe;
  final String time;
  Message({this.message, this.isMe, this.time});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.only(top: 5, bottom: 5, left: isMe? 20 : 5, right:  isMe? 5: 20),
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
        Text(time, style: TextStyle(color: Colors.grey, fontSize: 10),)
      ],
    );
  }
}
