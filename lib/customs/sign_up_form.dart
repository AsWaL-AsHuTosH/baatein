import 'package:flutter/material.dart';
import 'package:baatein/customs/round_text_field.dart';

class SignUpForm extends StatefulWidget {
  final Function emailValidationCallback,
      passwordValidationCallback,
      nameValidataionCallback;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController nameController;
  final GlobalKey<FormState> formKey;
  SignUpForm({
    @required this.nameValidataionCallback,
    @required this.emailValidationCallback,
    @required this.passwordValidationCallback,
    @required this.formKey,
    @required this.emailController,
    @required this.passwordController,
    this.nameController,
  });

  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  bool obscureText = true;
  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
        decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Colors.black,
                  blurRadius: 2.5,
                  offset: Offset(0.0, 1.0))
            ],
            borderRadius: BorderRadius.all(Radius.circular(10))),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: RoundTextField(
                    labelText: 'Name',
                    validator: widget.nameValidataionCallback,
                    controller: widget.nameController,
                    maxLength: 25,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Icon(Icons.person, color: Colors.grey),
                ),
              ],
            ),
            Divider(),
            Row(
              children: [
                Expanded(
                  child: RoundTextField(
                    labelText: 'Email',
                    validator: widget.emailValidationCallback,
                    controller: widget.emailController,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Icon(Icons.mail, color: Colors.grey),
                ),
              ],
            ),
            Divider(),
            Row(
              children: [
                Expanded(
                  child: RoundTextField(
                    labelText: 'Password',
                    validator: widget.passwordValidationCallback,
                    controller: widget.passwordController,
                    obscureText: obscureText,
                  ),
                ),
                 IconButton(
                  icon: Icon(obscureText ? Icons.lock : Icons.lock_open,
                      color: Colors.grey),
                  onPressed: () {
                    setState(
                      () {
                        setState(
                          () {
                            obscureText = !obscureText;
                          },
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
