import 'package:baatein/customs/elivated_form.dart';
import 'package:baatein/login_reg/forgot_password.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:baatein/customs/round_text_button.dart';
import 'signup_screen.dart';
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
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool ok = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Exit'),
            content: Text('Do you want to exit?'),
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
        if (ok != null && ok == true)
          return true;
        else
          return false;
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: ModalProgressHUD(
          inAsyncCall: spin,
          child: SafeArea(
            child: Container(
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
                            FlatButton(
                              child: Text(
                                'Forgot Password?',
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                    letterSpacing: 1),
                              ),
                              onPressed: () {
                                Navigator.pushNamed(
                                    context, ForgotPasswordScreen.routeId);
                              },
                            ),
                            RoundTextButton(
                              text: 'Sign In',
                              icon: Icons.verified_user,
                              margin: 60,
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
                                  _formKey.currentState.validate();
                                }
                              },
                            ),
                            Divider(
                              color: Colors.transparent,
                            ),
                            Hero(
                              tag: 'sign_up_button',
                              child: RoundTextButton(
                                text: 'Create New Account',
                                icon: Icons.person_add,
                                color: Colors.green,
                                margin: 20,
                                onPress: () => Navigator.popAndPushNamed(
                                    context, SignUpScreen.routeId),
                              ),
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
      ),
    );
  }
}
