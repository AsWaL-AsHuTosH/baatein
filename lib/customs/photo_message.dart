import 'package:baatein/chat/image_view_screen.dart';
import 'package:flutter/material.dart';

class PhotoMessage extends StatelessWidget {
  final String photoUrl, message;
  final bool isMe, isSelected;
  final String time;
  final String id;
  final Function onLongPressCallback;
  final Function onTapCallback;
  PhotoMessage(
      {this.message,
      this.photoUrl,
      this.isMe,
      this.time,
      this.id,
      this.isSelected = false,
      this.onLongPressCallback,
      this.onTapCallback});
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
