import 'package:baatein/customs/request_tile.dart';
import 'package:baatein/customs/search_field.dart';
import 'package:baatein/provider/firebase_service.dart';
import 'package:baatein/provider/logged_in_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RequestSearchScreen extends StatefulWidget {
  static const String routeId = 'request_search_screen';
  @override
  _RequestSearchScreenState createState() => _RequestSearchScreenState();
}

class _RequestSearchScreenState extends State<RequestSearchScreen> {
  String data1;
  String data2;
  LoggedInUser _user;
  FirebaseService _firebase;
  
  @override
  void initState() {
    super.initState();
    initLoggedInUser();
    initFirebaseService();
  }

  void initFirebaseService() =>
      _firebase = Provider.of<FirebaseService>(context, listen: false);

  void initLoggedInUser() =>
      _user = Provider.of<LoggedInUser>(context, listen: false);
      
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).accentColor,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: SearchField(
                hintText: 'Search for existing request by name......',
                onChangeCallback: (value) {
                  setState(() {
                    if (value == null || value.isEmpty) {
                      data1 = 'a';
                      data2 = String.fromCharCode('z'.codeUnitAt(0) + 1);
                    } else {
                      data1 = value;
                      data1 = data1.trim().toLowerCase();
                      int lastChar = data1.codeUnitAt(data1.length - 1);
                      String last = String.fromCharCode(lastChar + 1);
                      data2 = data1.substring(0, data1.length - 1) + last;
                    }
                  });
                },
              ),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: _firebase.firestore
                  .collection('requests')
                  .doc(_user.email)
                  .collection('request')
                  .where('search_name', isGreaterThanOrEqualTo: data1)
                  .where('search_name', isLessThan: data2)
                  .orderBy('search_name')
                  .snapshots(),
              builder: (context, snapshot) {
                List<RequestTile> requestList = [];
                if (snapshot.hasData) {
                  final requests = snapshot.data.docs;
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
                return Expanded(
                    child: ListView(
                  children: requestList,
                ));
              },
            )
          ],
        ),
      ),
    );
  }
}
