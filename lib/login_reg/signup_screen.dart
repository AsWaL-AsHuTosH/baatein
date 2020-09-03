import 'package:baatein/chat/home_screen.dart';
import 'package:baatein/constants/constants.dart';
import 'package:baatein/customs/sign_up_form.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:baatein/customs/round_text_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class SignUpScreen extends StatefulWidget {
  static const String routeId = 'sign_up_screen';
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  bool spin = false;
  bool otherEmailError = true;
  String errorMessage;
  final Function passwordValidation = (val) {
    return val.length < 6
        ? "Password should be at least 6 characters long!"
        : null;
  };
  final Function nameVaidation = (val) {
    return val.trim().length < 3
        ? "Please enter atleast 3 character long name!"
        : null;
  };
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
                  height: 50,
                ),
                Padding(
                  padding: EdgeInsets.only(right: 10, bottom: 5),
                  child: Text(
                    'Sign Up',
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SignUpForm(
                          nameController: nameController,
                          emailController: emailController,
                          passwordController: passwordController,
                          nameValidataionCallback: nameVaidation,
                          emailValidationCallback: (val) {
                            if (otherEmailError) {
                              otherEmailError = false;
                              return errorMessage;
                            }
                            if (val == null || val.isEmpty)
                              return "Please enter a valid email address!";
                            return RegExp(
                                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                    .hasMatch(val)
                                ? null
                                : "Please enter a valid email address!";
                          },
                          passwordValidationCallback: passwordValidation,
                          formKey: _formKey,
                        ),
                        RoundTextButton(
                          text: 'Sign Up',
                          icon: Icons.arrow_forward_ios,
                          margin: 50,
                          color: Colors.red,
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
                                  .createUserWithEmailAndPassword(
                                      email: emailController.text.trim(),
                                      password: passwordController.text);
                              String email =
                                  FirebaseAuth.instance.currentUser.email;
                              FirebaseFirestore firestore =
                                  FirebaseFirestore.instance;
                              await firestore
                                  .collection('users')
                                  .doc(email)
                                  .set({
                                'name': nameController.text.trim(),
                                'search_name':
                                    nameController.text.trim().toLowerCase(),
                                'email': email
                              });
                              await firestore
                                  .collection('profile_pic')
                                  .doc(email)
                                  .collection('image')
                                  .doc('image_url')
                                  .set({'url': kNoProfilePic});
                              setState(() {
                                spin = false;
                              });
                              nameController.clear();
                              emailController.clear();
                              passwordController.clear();
                              Navigator.pushNamed(context, HomeScreen.routeId);
                            } catch (e) {
                              if (e.toString() == kEmailInUse) {
                                otherEmailError = true;
                                errorMessage = kEmailInUseWarning;
                              } else
                                assert(false);
                              setState(() {
                                spin = false;
                              });
                              _formKey.currentState.validate();
                            }
                          },
                        )
                      ],
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
