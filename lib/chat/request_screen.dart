import 'package:baatein/chat/request_search_screen.dart';
import 'package:baatein/customs/request_tile.dart';
import 'package:baatein/customs/round_text_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'search_sheet.dart';
import 'package:flushbar/flushbar.dart';

class RequestScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, RequestSearchScreen.routeId),
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(
          Icons.search,
          color: Colors.white,
        ),
      ),
      body: Container(
        color: Theme.of(context).accentColor,
        child: Column(
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('requests')
                  .doc(_auth.currentUser.email)
                  .collection('request')
                  .orderBy('day')
                  .snapshots(),
              builder: (context, snaps) {
                List<RequestTile> requestList = [];
                if (snaps.hasData) {
                  final requests = snaps.data.docs;
                  if (requests != null) {
                    for (var req in requests) {
                      final String senderEmail = req.data()['from'];
                      final String senderName = req.data()['name'];
                      final String time = req.data()['time'];
                      final String day = req.data()['day'];
                      requestList.add(
                        RequestTile(
                          senderEmail: senderEmail,
                          senderName: senderName,
                          time: time,
                          day: day,
                        ),
                      );
                    }
                  }
                }
                return Expanded(child: ListView(children: requestList));
              },
            ),
           
          ],
        ),
      ),
    );
  }
}
