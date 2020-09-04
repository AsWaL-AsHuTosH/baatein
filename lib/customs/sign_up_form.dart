import 'package:flutter/material.dart';
import 'package:baatein/customs/round_text_field.dart';

class SignUpForm extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
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
            RoundTextField(
              labelText: 'Name',
              validator: nameValidataionCallback,
              controller: nameController,
              maxLength: 25,
            ),
            Divider(),
            RoundTextField(
              labelText: 'Email',
              validator: emailValidationCallback,
              controller: emailController,
            ),
            Divider(),
            RoundTextField(
              labelText: 'Password',
              validator: passwordValidationCallback,
              controller: passwordController,
              obscureText: true,
            ),
          ],
        ),
      ),
    );
  }
}
