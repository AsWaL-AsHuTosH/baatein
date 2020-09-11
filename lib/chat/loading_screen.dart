import 'package:baatein/chat/home_screen.dart';
import 'package:baatein/login_reg/signin_screen.dart';
import 'package:baatein/provider/firebase_service.dart';
import 'package:baatein/provider/logged_in_user.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:provider/provider.dart';

class LoadingScreen extends StatefulWidget {
  static const String routeId = 'loading_screen';
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    checkLastUser();
  }

  void checkLastUser() async {
    FirebaseService firebase = Provider.of<FirebaseService>(context, listen:  false);
    LoggedInUser user = Provider.of<LoggedInUser>(context, listen: false);
    await firebase.initServices();
    if (await user.initUser()) 
      Navigator.popAndPushNamed(context, HomeScreen.routeId);
     else
      Navigator.popAndPushNamed(context, SignInScreen.routeId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: ScaleAnimatedTextKit(
          repeatForever: true,
          text: ['Baatein'],
          textStyle: TextStyle(
            fontSize: 80,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            fontFamily: 'DancingScript',
          ),
        ),
      ),
    );
  }
}
