import 'package:baatein/customs/elivated_form.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:baatein/customs/round_text_button.dart';
import 'signup_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:baatein/chat/home_screen.dart';
import 'package:baatein/constants/constants.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class SignInScreen extends StatefulWidget {
  static const routeId = 'log_in_screen';
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool spin = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool otherEmailError = false;
  bool otherPasswordError = false;
  String errorMessage;
  @override
  void initState() {
    super.initState();
    Firebase.initializeApp();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: ModalProgressHUD(
        inAsyncCall: spin,
        child: SafeArea(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                stops: [0.1, 0.5, 0.7, 0.9],
                colors: [
                  Colors.red[800],
                  Colors.yellow[700],
                  Colors.yellow[600],
                  Colors.yellow[400],
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: Text(
                    'Baatein',
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      fontFamily: 'DancingScript',
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 10),
                          ElivatedForm(
                            emailController: emailController,
                            passwordController: passwordController,
                            emailValidationCallback: (val) {
                              if (otherEmailError) {
                                otherEmailError = false;
                                return errorMessage;
                              }
                              return RegExp(
                                          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                      .hasMatch(val)
                                  ? null
                                  : "Please enter a valid email address!";
                            },
                            passwordValidationCallback: (val) {
                              if (otherPasswordError) {
                                otherPasswordError = false;
                                return errorMessage;
                              }
                              return val.length < 6
                                  ? "Password should be at least 6 characters long!"
                                  : null;
                            },
                            formKey: _formKey,
                          ),
                          RoundTextButton(
                            text: 'Sign In',
                            icon: Icons.verified_user,
                            margin: 60,
                            color: Theme.of(context).primaryColor,
                            onPress: () async {
                              setState(() {
                                spin = true;
                              });
                              if (!_formKey.currentState.validate()) {
                                setState(() {
                                  spin = false;
                                });
                                return;
                              }
                              try {
                                await FirebaseAuth.instance
                                    .signInWithEmailAndPassword(
                                  email: emailController.text,
                                  password: passwordController.text,
                                );
                                setState(() {
                                  spin = false;
                                });
                                emailController.clear();
                                passwordController.clear();
                                Navigator.pushNamed(
                                    context, HomeScreen.routeId);
                              } catch (e) {
                                if (e.toString() == kInvalidUser) {
                                  otherEmailError = true;
                                  errorMessage = kInvalidUserWarning;
                                } else if (e.toString() == kWrongPassword) {
                                  otherPasswordError = true;
                                  errorMessage = kWrongPasswordWarning;
                                } else
                                  assert(false);
                                setState(() {
                                  spin = false;
                                });
                                print('lest go');
                                _formKey.currentState.validate();
                              }
                            },
                          ),
                          Divider(
                            color: Colors.transparent,
                          ),
                          RoundTextButton(
                            text: 'Create New Account',
                            icon: Icons.person_add,
                            color: Colors.green,
                            margin: 20,
                            onPress: () => Navigator.pushNamed(
                                context, SignUpScreen.routeId),
                          ),
                        ],
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.only(topLeft: Radius.circular(150)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
