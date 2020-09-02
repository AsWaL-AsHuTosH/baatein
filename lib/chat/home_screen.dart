import 'package:baatein/chat/chat_overview_screen.dart';
import 'package:baatein/chat/request_screen.dart';
import 'package:baatein/chat/friend_list_screen.dart';
import 'package:baatein/constants/constants.dart';
import 'package:baatein/customs/round_text_button.dart';
import 'package:baatein/login_reg/signin_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'profile_pic_edit.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flushbar/flushbar.dart';

class HomeScreen extends StatefulWidget {
  static const routeId = 'home_screen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final _auth = FirebaseAuth.instance;

  final _firestore = FirebaseFirestore.instance;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  TabController _tabController;

  String name = 'User';

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(vsync: this, length: 3);
    getMyName();
  }

  void getMyName() async {
    String myName = await _firestore
        .collection('users')
        .doc(_auth.currentUser.email)
        .get()
        .then((value) => value.data()['name']);
    setState(() {
      name = myName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).primaryColor,
      drawer: Drawer(
        child: Container(
          padding: EdgeInsets.only(top: 5),
          color: Theme.of(context).primaryColor,
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Baatein',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                      fontFamily: 'DancingScript',
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.only(top: 5),
                    color: Colors.white,
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfileEditScreen(
                                  editButtonCallback: () async {
                                    final ImagePicker picker = ImagePicker();
                                    final PickedFile pickedImage = await picker
                                        .getImage(source: ImageSource.gallery);
                                    if (pickedImage == null) return;
                                    final ref = FirebaseStorage.instance
                                        .ref()
                                        .child(FirebaseAuth
                                                .instance.currentUser.email +
                                            '.jpg');
                                    final File file = File(pickedImage.path);
                                    StorageUploadTask task = ref.putFile(file);
                                    StorageTaskSnapshot taskSnapshot =
                                        await task.onComplete;
                                    String url =
                                        await taskSnapshot.ref.getDownloadURL();
                                    _firestore
                                        .collection('profile_pic')
                                        .doc(_auth.currentUser.email)
                                        .collection('image')
                                        .doc('image_url')
                                        .set({'url': url});
                                    Flushbar(
                                      message:
                                          "Your profile picture is uploaded successfully.",
                                      backgroundGradient: LinearGradient(
                                          colors: [Colors.red, Colors.orange]),
                                      icon: Icon(
                                        Icons.check,
                                        color: Colors.green,
                                        size: 40,
                                      ),
                                      margin: EdgeInsets.all(8),
                                      borderRadius: 8,
                                      backgroundColor: Colors.red,
                                      duration: Duration(seconds: 3),
                                      boxShadows: [
                                        BoxShadow(
                                          color: Colors.lightBlueAccent,
                                          offset: Offset(0.0, 2.0),
                                          blurRadius: 3.0,
                                        )
                                      ],
                                    ).show(context);
                                  },
                                ),
                              ),
                            );
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
                              if (url == null) url = kNoProfilePic;
                              return CircleAvatar(
                                backgroundImage: NetworkImage(url),
                                radius: 50,
                              );
                            },
                          ),
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.person,
                            color: Colors.black,
                          ),
                          title: Text(
                            name,
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 10,
                              fontFamily: 'Source Sans Pro',
                              letterSpacing: 5.0,
                            ),
                          ),
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.email,
                            color: Colors.black,
                          ),
                          title: Text(
                            _auth.currentUser.email,
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 10,
                              fontFamily: 'Source Sans Pro',
                              letterSpacing: 2.0,
                            ),
                          ),
                        ),
                        SizedBox(
                          child: Divider(
                            color: Colors.grey,
                            indent: 15,
                            endIndent: 15,
                          ),
                        ),
                        RoundTextButton(
                          text: 'Log Out',
                          icon: Icons.input,
                          onPress: () {
                            _auth.signOut();
                            Navigator.popAndPushNamed(
                                context, SignInScreen.routeId);
                          },
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(3.0),
          child: GestureDetector(
            onTap: () => _scaffoldKey.currentState.openDrawer(),
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
                if (url == null) url = kNoProfilePic;
                return CircleAvatar(
                  backgroundImage: NetworkImage(url),
                  radius: 25,
                );
              },
            ),
          ),
        ),
        elevation: 5,
        backgroundColor: Theme.of(context).primaryColor,
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
        // actions: [
        //   Padding(
        //     padding: EdgeInsets.all(5.0),
        //     child: GestureDetector(
        //       onTap: () {
        //         Navigator.push(
        //           context,
        //           MaterialPageRoute(
        //             builder: (context) => SearchScreen(mainPath: ,),
        //           ),
        //         );
        //       },
        //       child: Icon(
        //         Icons.search,
        //         size: 30,
        //       ),
        //     ),
        //   ),
        // ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Chats'),
            Tab(text: 'Friends'),
            Tab(text: 'Requests'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ChatOverviewScreen(),
          FriendListScreen(),
          RequestScreen(),
        ],
      ),
    );
  }
}
