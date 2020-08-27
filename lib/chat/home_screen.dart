import 'package:baatein/chat/chat_overview_screen.dart';
import 'package:baatein/chat/feed_screen.dart';
import 'package:baatein/chat/status_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  static const routeId = 'home_screen';
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _auth = FirebaseAuth.instance;
  User loggedInUser;
  @override
  void initState() {
    super.initState();
    loggedInUser = _auth.currentUser;
    print(loggedInUser.email);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          elevation: 0,
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
          bottom: TabBar(
            tabs: [
              Tab(text: 'Chats'),
              Tab(text: 'Status'),
              Tab(text: 'Requests'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ChatOverviewScreen(),
            StatusScreen(),
            FeedScreen(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: () {
            _auth.signOut();
            Navigator.pop(context);
          },
          child: Icon(
            Icons.message,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
