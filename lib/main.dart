import 'package:baatein/chat/home_screen.dart';
import 'package:baatein/login_reg/signup_screen.dart';
import 'package:flutter/material.dart';
import 'login_reg/signin_screen.dart';

void main() {
  runApp(Baatein());
}

class Baatein extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        SignInScreen.routeId: (context) => SignInScreen(),
        SignUpScreen.routeId: (context) => SignUpScreen(),
        HomeScreen.routeId: (context) => HomeScreen(),
      },
      initialRoute: SignInScreen.routeId,
      theme: ThemeData(
        primaryColor: Color(0xfff44336),
        accentColor: Colors.white,
      ),
    );
  }
}
