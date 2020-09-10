import 'package:baatein/chat/chat_search_screen.dart';
import 'package:baatein/chat/friends_search_screen.dart';
import 'package:baatein/chat/group_search_screen.dart';
import 'package:baatein/chat/group_member_selection_screen.dart';
import 'package:baatein/chat/home_screen.dart';
import 'package:baatein/chat/loading_screen.dart';
import 'package:baatein/chat/request_search_screen.dart';
import 'package:baatein/provider/firebase_service.dart';
import 'package:baatein/provider/logged_in_user.dart';
import 'package:baatein/provider/selected_user.dart';
import 'package:baatein/login_reg/forgot_password.dart';
import 'package:baatein/login_reg/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login_reg/signin_screen.dart';

void main() => runApp(Baatein());

class Baatein extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SelectedUser>(
          create: (context) => SelectedUser(),
        ),
        Provider<LoggedInUser>(
          create: (context) => LoggedInUser(),
        ),
        Provider<FirebaseService>(create: (context) => FirebaseService(),),
      ],
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
          GroupMemberSelectionScreen.routeId: (context) => GroupMemberSelectionScreen(),
          GroupSearchScreen.routeId: (context) => GroupSearchScreen(),
          ForgotPasswordScreen.routeId: (context) => ForgotPasswordScreen(),
        },
        initialRoute: LoadingScreen.routeId,
        theme: ThemeData(
          primaryColor: Colors.blue,
          accentColor: Colors.white,
          canvasColor: Colors.transparent,
        ),
      ),
    );
  }
}
