import 'package:baatein/customs/request_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'search_screen.dart';

class RequestScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, SearchScreen.routeId);
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(
          Icons.person_add,
          color: Colors.white,
        ),
      ),
      body: Container(
        color: Theme.of(context).accentColor,
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('requests')
              .doc(_auth.currentUser.email)
              .collection('request')
              .snapshots(),
          builder: (context, snaps) {
            List<RequestTile> requestList = [];
            if (snaps.hasData) {
              final requests = snaps.data.docs;
              for (var req in requests) {
                final sender = req.data()['from'];
                requestList.add(
                  RequestTile(
                    sender: sender,
                  ),
                );
              }
            }
            return ListView(children: requestList);
          },
        ),
      ),
    );
  }
}
