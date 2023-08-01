import 'package:flutter/material.dart';
import 'package:snapchat_ui_clone/widgets/login_signup_button.dart';

import '../widgets/txt_field.dart';

class ForgotPasswordScreen extends StatefulWidget {


  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = "";
  String error = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 40,
        bottom: 50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.blue,
                  size: 35,
                ),
                onPressed: () => Navigator.pop(context),
              )
            ),
            Container(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Text(
                      "Enter your email",
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    TxtFieldForScreen(
                      label: "Email",
                      obscure: false,
                      validator: (val) => val.isEmpty ? "Enter an email": null,
                      onChange: (val) {
                        setState(() {
                          return;
                        });
                      }, txtType: TextInputType.emailAddress,
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Text(
                      error,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 17,
                    )

                    )
                  ],
                ),
              ),
            ),
            SizedBox(height: 10,),
            LoginAndSignUpButton(
              color: Colors.blue,
              text: "Submit",
              onPress: () async {
                if (_formKey.currentState!.validate()) {}
              },
            )
          ]
        )
      )
    );
  }
}
