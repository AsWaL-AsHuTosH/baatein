import 'package:baatein/chat/chat_search_screen.dart';
import 'package:baatein/chat/friends_search_screen.dart';
import 'package:baatein/chat/group_search_screen.dart';
import 'package:baatein/chat/group_selection_screen.dart';
import 'package:baatein/chat/home_screen.dart';
import 'package:baatein/chat/loading_screen.dart';
import 'package:baatein/chat/request_search_screen.dart';
import 'package:baatein/classes/SelectedUser.dart';
import 'package:baatein/login_reg/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login_reg/signin_screen.dart';

void main() {
  runApp(Baatein());
}

class Baatein extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => SelectedUser(),
        child: MaterialApp(
        debugShowCheckedModeBanner: false,
        routes: {
          SignInScreen.routeId: (context) => SignInScreen(),
          SignUpScreen.routeId: (context) => SignUpScreen(),
          HomeScreen.routeId: (context) => HomeScreen(),
          LoadingScreen.routeId: (context) => LoadingScreen(),
          ChatSearchScreen.routeId: (context) => ChatSearchScreen(),
          FreindSearchScreen.routeId: (context) => FreindSearchScreen(),
          RequestSearchScreen.routeId: (context) => RequestSearchScreen(),
          GroupSelectionScreen.routeId: (context) => GroupSelectionScreen(),
          GroupSearchScreen.routeId: (context) => GroupSearchScreen(),
        },
        initialRoute: LoadingScreen.routeId,
        theme: ThemeData(
          primaryColor: Color(0xfff44336),
          accentColor: Colors.white,
          canvasColor: Colors.transparent,
        ),
      ),
    );
  }
}
