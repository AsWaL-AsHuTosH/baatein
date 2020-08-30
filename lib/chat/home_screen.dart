import 'package:baatein/chat/chat_overview_screen.dart';
import 'package:baatein/chat/request_screen.dart';
import 'package:baatein/chat/search_screen.dart';
import 'package:baatein/chat/friend_list_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  static const routeId = 'home_screen';
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          elevation: 5,
          backgroundColor: Theme.of(context).primaryColor,
          automaticallyImplyLeading: false,
          title: Center(
            child: Text(
              'Baatein',
              style: TextStyle(
                fontFamily: 'DancingScript',
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          actions: [
            Padding(
              padding: EdgeInsets.all(5.0),
              child: GestureDetector(
                onTap: () {
                  _auth.signOut();
                  Navigator.pop(context);
                },
                child: Icon(Icons.input),
              ),
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: 'Chats'),
              Tab(text: 'Friends'),
              Tab(text: 'Requests'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ChatOverviewScreen(),
            FriendListScreen(),
            RequestScreen(),
          ],
        ),
      ),
    );
  }
}
