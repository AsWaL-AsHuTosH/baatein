import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchField extends StatelessWidget {
  final Function validator;
  final Color color = Colors.white;
  final TextEditingController controller;
  final GlobalKey<FormState> formKey;
  final String labelText, hintText;
  final Function onChangeCallback;
  SearchField({this.onChangeCallback,this.controller, this.formKey, this.validator, this.hintText = 'Enter friends email.', this.labelText = 'Freind\'s Email'});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
      color: Colors.white,
           borderRadius: BorderRadius.all(Radius.circular(10)),
        boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Colors.black, blurRadius: 1.0, offset: Offset(0.0, 1.0))
            ],
      ),
      child: Form(
          key:formKey,
          child: Padding(
          padding: EdgeInsets.symmetric(vertical: 4),
          child: TextFormField(
            onChanged: onChangeCallback,
            validator: validator,
            controller: controller,
            decoration: InputDecoration(
              errorStyle: TextStyle(
                fontSize: 10,
              ),
              hintText: hintText,
              hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
              labelText: labelText,
              labelStyle: TextStyle(
                fontSize: 15,
                  color: Colors.grey, backgroundColor: Colors.transparent),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(20),
                ),
                borderSide: BorderSide(color: color, width: 2.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(20),
                ),
                borderSide: BorderSide(color: color, width: 2.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(20),
                ),
                borderSide: BorderSide(color: color, width: 0.0),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(20),
                ),
                borderSide: BorderSide(color: color, width: 0.0),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
