import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:snapchat_ui_clone/widgets/login_signup_button.dart';

import '../widgets/txt_field.dart';
import 'forgot_password.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen> {

  final _formKey = GlobalKey<FormState>();
  String email = "";
  String password = "";


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      //resizeToAvoidBottomPadding: false,
      body: Padding(
        padding: const EdgeInsets.only(
          top: 30,
          bottom: 40,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      child: IconButton(icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.blue,
                        size: 32,

                      ), onPressed: () =>
                        Navigator.pop(context)),
                    ),
                    const SizedBox(
                      height: 80,
                    ),
                    Container(
                      child: Column(
                        children: [
                          fieldsOnScreen()
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Container(
                child: Column(children: [
                  LoginAndSignUpButton(
                    color: Colors.blue,
                    text: "Log In",
                    onPress: () async {
                      if(_formKey.currentState!.validate()){}
                    },
                  ),
                ],),
              )
            ],
          ),
        ),
      ),

    );

  }

  fieldsOnScreen() {
    return Container(
      child: Column(
        children: [
          const Text(
            "Log In",
            style: TextStyle(
              color: Colors.black87,
              fontSize: 25,
              fontWeight: FontWeight.w700,
            ),
          ),

          TxtFieldForScreen(
            txtType: TextInputType.emailAddress,
            label: "Email",
            obscure: false,
            validator: (val) => val.isEmpty ? "Enter an email" : null,
            onChange: (val) {
              setState(() {
                return;
              });

            },
          ), const SizedBox(
            height: 10,
            ),
            TxtFieldForScreen(
            txtType: TextInputType.visiblePassword,
            label: "Password",
            obscure: true,
            validator: (val) => val.length <6 ? "password must be 6+ characters" : null,
            onChange: (val) {
              setState(() {
                return;
              });
            },
          ),
          const SizedBox(
            height: 20,

          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ForgotPasswordScreen())

                );
            },
            child: Text(
              "Forgot your password?",
              style: TextStyle(color: Colors.blue[8]),
            )
          )
        ],
      ),
    );
  }
}



