import 'package:baatein/chat/chat_overview_screen.dart';
import 'package:baatein/chat/chat_search_screen.dart';
import 'package:baatein/chat/friends_search_screen.dart';
import 'package:baatein/chat/group_chat_screen.dart';
import 'package:baatein/chat/group_search_screen.dart';
import 'package:baatein/chat/request_screen.dart';
import 'package:baatein/chat/friend_list_screen.dart';
import 'package:baatein/chat/request_search_screen.dart';
import 'package:baatein/constants/constants.dart';
import 'package:baatein/customs/round_text_button.dart';
import 'package:baatein/login_reg/signin_screen.dart';
import 'package:baatein/provider/firebase_service.dart';
import 'package:baatein/provider/logged_in_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'profile_pic_edit.dart';

class HomeScreen extends StatefulWidget {
  static const routeId = 'home_screen';
  static const List<String> screen = [
    ChatSearchScreen.routeId,
    GroupSearchScreen.routeId,
    FreindSearchScreen.routeId,
    RequestSearchScreen.routeId
  ];
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TabController _tabController;
  LoggedInUser _user;
  FirebaseService _firebase;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = new TabController(vsync: this, length: 4);
    initLoggedInUser();
    initFirebaseService();
    setMeOnline(true);
  }

  void initFirebaseService() =>
      _firebase = Provider.of<FirebaseService>(context, listen: false);

  void initLoggedInUser() =>
      _user = Provider.of<LoggedInUser>(context, listen: false);

  Future<void> setMeOnline(bool value) async {
    await _firebase.firestore
        .collection('presence')
        .doc(_user.email)
        .collection('status')
        .doc('is_online')
        .update({'is_online': value});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed)
      setMeOnline(true);
    else
      setMeOnline(false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool ok = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Sign Out'),
            content: Text('Do you want to Sign Out?'),
            actions: [
              FlatButton(
                child: Text('Yes'),
                onPressed: () => Navigator.pop(context, true),
              ),
              FlatButton(
                child: Text('No'),
                onPressed: () => Navigator.pop(context, false),
              ),
            ],
          ),
        );
        if (ok != null && ok == true) {
          await setMeOnline(false);
          await _firebase.auth.signOut();
          _user.clear();
          Navigator.pushNamedAndRemoveUntil(
              context, SignInScreen.routeId, (Route<dynamic> route) => false);
          return true;
        } else {
          return false;
        }
      },
      child: Scaffold(
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
                    child: Center(
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
                                    docId: _user.email,
                                  ),
                                ),
                              );
                            },
                            child: StreamBuilder<QuerySnapshot>(
                              stream: _firebase.firestore
                                  .collection('profile_pic')
                                  .doc(_user.email)
                                  .collection('image')
                                  .snapshots(),
                              builder: (context, snapshot) {
                                String url;
                                try {
                                  if (snapshot.hasData) {
                                    final image = snapshot.data.docs;
                                    url = image[0].data()['url'];
                                  }
                                } catch (e) {
                                  return CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(kNoProfilePic),
                                    radius: 50,
                                  );
                                }
                                if (url == null) url = kNoProfilePic;
                                return CircleAvatar(
                                  backgroundImage: NetworkImage(url),
                                  radius: 50,
                                );
                              },
                            ),
                          ),
                          StreamBuilder<QuerySnapshot>(
                            stream: _firebase.firestore
                                .collection('presence')
                                .doc(_user.email)
                                .collection('status')
                                .snapshots(),
                            builder: (context, snapshot) {
                              bool isOnline = false;
                              if (snapshot.hasData && snapshot.data != null) {
                                isOnline =
                                    snapshot.data.docs[0].data()['is_online'];
                              }
                              return isOnline
                                  ? Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'Online',
                                        style: TextStyle(
                                            fontFamily: 'Source Sans Pro',
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    )
                                  : Container(
                                      width: 0,
                                      height: 0,
                                    );
                            },
                          ),
                          ListTile(
                            leading: Icon(
                              Icons.person,
                              color: Colors.black,
                            ),
                            title: Text(
                              _user.name,
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
                              _user.email,
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
                            text: 'Sign Out',
                            icon: Icons.input,
                            onPress: () async {
                              await setMeOnline(false);
                              await _firebase.auth.signOut();
                               _user.clear();
                              Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  SignInScreen.routeId,
                                  (Route<dynamic> route) => false);
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
          actions: [
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () => Navigator.pushNamed(context,
                  HomeScreen.screen[_tabController.animation.value.round()]),
            )
          ],
          leading: InkWell(
            onTap: () => _scaffoldKey.currentState.openDrawer(),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: StreamBuilder<QuerySnapshot>(
                stream: _firebase.firestore
                    .collection('profile_pic')
                    .doc(_user.email)
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
                  );
                },
              ),
            ),
          ),
          elevation: 5,
          backgroundColor: Theme.of(context).primaryColor,
          title: Padding(
            padding: const EdgeInsets.only(left: 80.0),
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
            isScrollable: true,
            controller: _tabController,
            tabs: [
              Tab(text: 'Chats'),
              Tab(text: 'Groups'),
              Tab(text: 'Friends'),
              Tab(text: 'Requests'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            ChatOverviewScreen(),
            GroupChatScreen(),
            FriendListScreen(),
            RequestScreen(),
          ],
        ),
      ),
    );
  }
}
