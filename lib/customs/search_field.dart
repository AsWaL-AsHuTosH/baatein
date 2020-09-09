import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchField extends StatelessWidget {
  final Function validator;
  final Color color = Colors.white;
  final TextEditingController controller;
  final GlobalKey<FormState> formKey;
  final String hintText;
  final Function onChangeCallback;
  final int maxLength;
  final bool trailing;
  SearchField({
    this.trailing = true,
    this.onChangeCallback,
    this.controller,
    this.formKey,
    this.validator,
    this.hintText = 'Enter friends email.',
    this.maxLength,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          ListTile(
            trailing: trailing
                ? IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {},
                  )
                : null,
            title: Form(
              key: formKey,
              child: TextFormField(
                textAlign: TextAlign.center,
                maxLength: maxLength,
                onChanged: onChangeCallback,
                validator: validator,
                controller: controller,
                decoration: InputDecoration(
                  counterText: "",
                  errorStyle: TextStyle(
                    fontSize: 10,
                  ),
                  hintText: hintText,
                  hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(0),
                    ),
                    borderSide: BorderSide(color: color, width: 2.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(0),
                    ),
                    borderSide: BorderSide(color: color, width: 2.5),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(0),
                    ),
                    borderSide: BorderSide(color: color, width: 0.0),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(0),
                    ),
                    borderSide: BorderSide(color: color, width: 0.0),
                  ),
                ),
              ),
            ),
          ),
          Divider(
            color: Colors.grey,
            indent: 10,
            endIndent: 10,
          )
        ],
      ),
    );
  }
}
