import 'package:baatein/helper/message_info.dart';
import 'package:flutter/material.dart';

class MessageInfoScrren extends StatelessWidget {
  final MessageInfo message;
  MessageInfoScrren({this.message});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Message Information'),
      ),
      body: Column(
        children: [
          ListTile(
            leading: Icon(
              Icons.person,
              color: Colors.black,
            ),
            title: Text(
              message.senderName,
              style: TextStyle(
                color: Colors.black54,
                fontSize: 13,
                fontFamily: 'Source Sans Pro',
                letterSpacing: 2.0,
              ),
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.mail,
              color: Colors.black,
            ),
            title: Text(
              message.senderEmail,
              style: TextStyle(
                color: Colors.black54,
                fontSize: 13,
                fontFamily: 'Source Sans Pro',
                letterSpacing: 2.0,
              ),
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.date_range,
              color: Colors.black,
            ),
            title: Text(
              message.date,
              style: TextStyle(
                color: Colors.black54,
                fontSize: 13,
                fontFamily: 'Source Sans Pro',
                letterSpacing: 2.0,
              ),
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.access_time,
              color: Colors.black,
            ),
            title: Text(
              message.timeString,
              style: TextStyle(
                color: Colors.black54,
                fontSize: 13,
                fontFamily: 'Source Sans Pro',
                letterSpacing: 2.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
