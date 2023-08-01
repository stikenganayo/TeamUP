import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TxtFieldForScreen extends StatelessWidget {
  final String label;
  //final Function(String) validator;
  final Function(String) onChange;
  final TextInputType txtType;
  final bool obscure;

  var validator;

  TxtFieldForScreen({Key? key,
    required this.label,
    required this.obscure,
    required this.onChange,
    required this.txtType,
    required this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 35,
        right: 35,

      ),
      child: TextFormField(
        keyboardType: txtType,
        obscureText: obscure,
        validator: validator,
        onChanged: onChange,
        decoration: InputDecoration(
            labelText: label,
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            )
        ),
      ),
    );
  }
}