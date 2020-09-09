import 'package:flutter/material.dart';
import 'package:baatein/customs/round_text_field.dart';

class ElivatedForm extends StatefulWidget {
  final Function emailValidationCallback, passwordValidationCallback;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final GlobalKey<FormState> formKey;
  ElivatedForm({
    @required this.emailValidationCallback,
    @required this.passwordValidationCallback,
    @required this.formKey,
    @required this.emailController,
    @required this.passwordController,
  });

  @override
  _ElivatedFormState createState() => _ElivatedFormState();
}

class _ElivatedFormState extends State<ElivatedForm> {
  bool obscureText = true;
  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
