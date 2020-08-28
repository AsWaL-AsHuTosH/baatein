import 'package:flutter/material.dart';

class ChatCard extends StatelessWidget {
  final bool newMessage;
  final String name;
  ChatCard({this.name,this.newMessage = false});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: newMessage ? Color(0xffffccbc) : Colors.white,
        borderRadius: BorderRadius.all(
          Radius.circular(15),
        ),
      ),
      margin: EdgeInsets.symmetric(vertical: 1.0, horizontal: 1.0),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            child: Icon(Icons.person),
            radius: 30,
          ),
          SizedBox(
            width: 10,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                'hey!',
                style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 10,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  '3:45 pm',
                  style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 10,
                      fontWeight: FontWeight.bold),
                ),
                Icon(
                  newMessage ? Icons.sms : null,
                  color: Colors.red,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
