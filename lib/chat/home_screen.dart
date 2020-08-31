import 'package:baatein/chat/chat_overview_screen.dart';
import 'package:baatein/chat/request_screen.dart';
import 'package:baatein/chat/search_screen.dart';
import 'package:baatein/chat/friend_list_screen.dart';
import 'package:baatein/login_reg/signin_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class HomeScreen extends StatelessWidget {
  static const routeId = 'home_screen';
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.all(3.0),
            child: GestureDetector(
              onTap: () async {
                final ImagePicker picker = ImagePicker();
                final PickedFile pickedImage =
                    await picker.getImage(source: ImageSource.gallery);
                if (pickedImage == null) return;
                final ref = FirebaseStorage.instance
                    .ref()
                    .child(FirebaseAuth.instance.currentUser.email + '.jpg');
                final File file = File(pickedImage.path);
                StorageUploadTask task = ref.putFile(file);
                StorageTaskSnapshot taskSnapshot = await task.onComplete;
                String url = await taskSnapshot.ref.getDownloadURL();
                await _firestore
                    .collection('profile_pic')
                    .doc(_auth.currentUser.email)
                    .collection('image')
                    .doc('image_url')
                    .set({'url': url});
              },
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('profile_pic')
                    .doc(_auth.currentUser.email)
                    .collection('image')
                    .snapshots(),
                builder: (context, snapshot) {
                  String url;
                  if (snapshot.hasData) {
                    final image = snapshot.data.docs;
                    url = image[0].data()['url'];
                  }
                  return CircleAvatar(
                    child: url != null ? null : Icon(Icons.person),
                    backgroundImage: url != null ? NetworkImage(url) : null,
                    radius: 30,
                  );
                },
              ),
            ),
          ),
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
                  Navigator.popAndPushNamed(context, SignInScreen.routeId);
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
