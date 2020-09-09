import 'package:baatein/chat/home_screen.dart';
import 'package:baatein/login_reg/signin_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

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
    await Firebase.initializeApp();
    if (FirebaseAuth.instance.currentUser != null) 
      Navigator.popAndPushNamed(context, HomeScreen.routeId);
     else 
      Navigator.popAndPushNamed(context, SignInScreen.routeId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child:ScaleAnimatedTextKit( 
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
