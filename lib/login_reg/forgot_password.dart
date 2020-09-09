import 'package:baatein/constants/constants.dart';
import 'package:baatein/customs/search_field.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:baatein/customs/round_text_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class ForgotPasswordScreen extends StatefulWidget {
  static const routeId = 'forgot_pass_screen';
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  bool spin = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  bool otherError = false;
  String errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                          SearchField(
                            trailing: false,
                            hintText: 'Enter your email.',
                            validator: (val) {
                              if (otherError) {
                                otherError = false;
                                return errorMessage;
                              }
                              return RegExp(
                                          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                      .hasMatch(val)
                                  ? null
                                  : "Please enter a valid email address!";
                            },
                            formKey: _formKey,
                            controller: emailController,
                          ),
                          RoundTextButton(
                            text: 'Reset Password',
                            icon: Icons.lock,
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
                                    .sendPasswordResetEmail(
                                        email: emailController.text.trim());
                                await Flushbar(
                                  message:
                                      "Your password reset email has been sent to ${emailController.text.trim()}",
                                  margin: EdgeInsets.all(8),
                                  borderRadius: 8,
                                  icon: Icon(
                                    Icons.error,
                                    color: Colors.blue[300],
                                    size: 20,
                                  ),
                                  duration: Duration(seconds: 2),
                                ).show(context);
                                setState(() {
                                  spin = false;
                                });
                                emailController.clear();
                                Navigator.pop(context);
                              } catch (e) {
                                if (e.toString() == kInvalidUser) {
                                  otherError = true;
                                  errorMessage = kInvalidUserWarning;
                                } else
                                  assert(false);
                                setState(() {
                                  spin = false;
                                });
                                _formKey.currentState.validate();
                              }
                            },
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
