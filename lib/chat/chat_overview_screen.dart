import 'package:baatein/customs/chat_card.dart';
import 'package:flutter/material.dart';

class ChatOverviewScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 1.0),
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: ListView(
        children: [
          ChatCard(),
          ChatCard(),
          ChatCard(),
          ChatCard(),
          ChatCard(newMessage: true,),
          ChatCard(),
          ChatCard(newMessage: true,),
          ChatCard(),
          ChatCard(),
          ChatCard(),
          ChatCard(),
          ChatCard(),
          ChatCard(),
          ChatCard(),
          ChatCard(),
          ChatCard(),
          ChatCard(),
          ChatCard(),
          ChatCard(),
        ],
      ),
    );
  }
}