import 'package:flutter/material.dart';

class Message extends StatelessWidget {
  final String message;
  final bool isMe, isSelected;
  final String time;
  final String id;
  final Function onLongPressCallback;
  final Function onTapCallback;

  Message(
      {this.message,
      this.isMe,
      this.time,
      @required this.id,
      this.onLongPressCallback,
      this.onTapCallback,
      this.isSelected = false});
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
                      topLeft: Radius.circular(30.0),
                      topRight: Radius.circular(30.0),
                      bottomLeft: Radius.circular(30.0),
                      bottomRight: Radius.circular(0.0),
                    )
                  : BorderRadius.only(
                      topLeft: Radius.circular(30.0),
                      topRight: Radius.circular(30.0),
                      bottomLeft: Radius.circular(0.0),
                      bottomRight: Radius.circular(30.0),
                    ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                    color: Colors.grey,
                    blurRadius: 5.0,
                    offset: Offset(0.0, 1.0))
              ],
            ),
            child: Text(message),
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
