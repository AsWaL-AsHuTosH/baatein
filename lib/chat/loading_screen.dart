import 'package:baatein/chat/home_screen.dart';
import 'package:baatein/login_reg/signin_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

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

  //TODO Improve Loading UI
  @override
  Widget build(BuildContext context) {
    return SpinKitFadingCircle(
      color: Colors.white,
    );
  }
}
