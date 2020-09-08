import 'package:flutter/material.dart';

class Message extends StatelessWidget {
  final String message;
  final bool isMe, isSelected;
  final String time;
  final String id;
  final Function onLongPressCallback;
  final Function onTapCallback;
  
  Message({this.message, this.isMe, this.time, @required this.id, this.onLongPressCallback, this.onTapCallback, this.isSelected = false});
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
            margin: EdgeInsets.only(top: 5, bottom: 5, left: isMe? 20 : 5, right:  isMe? 5: 20),
            decoration: BoxDecoration(
              color:  isSelected ? Colors.greenAccent: isMe? Colors.teal : Colors.lightBlueAccent,
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
      ),
    );
  }
}
