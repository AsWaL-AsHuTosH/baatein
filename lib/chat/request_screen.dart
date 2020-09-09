import 'package:baatein/customs/request_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RequestScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String myEmail = FirebaseAuth.instance.currentUser.email;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Theme.of(context).accentColor,
        child: Column(
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('requests')
                  .doc(myEmail)
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
