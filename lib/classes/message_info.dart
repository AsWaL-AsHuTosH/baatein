import 'package:flutter/cupertino.dart';

class MessageInfo {
  final DateTime time;
  final String message;
  final String type;
  final String url;
  final String imageName;
  final String date;
  final String timeString;
  final String senderEmail, senderName;
  MessageInfo({this.message, this.time, this.type, this.url, this.imageName, @required this.date, @required this.senderEmail,@required this.timeString, @required this.senderName});
}

Comparator<MessageInfo> comp = (a, b) => a.time.compareTo(b.time);
