import 'package:flutter/material.dart';
import 'dart:convert';

import '../../main.dart';
import '../../widgets/login_signup_button.dart';
import '../forgot_password.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  String? enteredEmail;
  String? enteredPassword;

  List<Map<String, dynamic>>? userData;

  Future<void> loadUserData() async {
    final jsonData =
    await DefaultAssetBundle.of(context).loadString('assets/images/data/team_data.json');
    final data = json.decode(jsonData);

    final dataList = data['data'];
    userData = dataList
        .map<Map<String, dynamic>>(
          (user) => {
        'user': user['user'],
        'description': user['description'],
      },
    )
        .toList();
  }

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.blue,
                          size: 32,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(
                      height: 80,
                    ),
                    Container(
                      child: Column(
                        children: [
                          fieldsOnScreen(),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Container(
                child: Column(
                  children: [
                    FutureBuilder(
                      future: loadUserData(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return LoginAndSignUpButton(
                            color: Colors.blue,
                            text: "Log In",
                            onPress: () {
                              if (_formKey.currentState!.validate()) {
                                // Capture entered email and password
                                enteredEmail = emailController.text;
                                enteredPassword = passwordController.text;

                                // Check if the user exists and password matches
                                bool validUser = false;
                                bool validPassword = false;

                                for (final user in userData!) {
                                  if (user['user'] == enteredEmail) {
                                    validUser = true;
                                    if (user['description'] == enteredPassword) {
                                      validPassword = true;
                                      break; // No need to check further
                                    }
                                  }
                                }

                                if (validUser && validPassword) {
                                  // Set login successful and navigate
                                  // You can navigate to the MainPage here

                                  print('Login Successful');
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => MainPage()),
                                  );

                                } else {
                                  // Display an error message
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text("Login Failed"),
                                        content: Text("Invalid username or password"),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text("OK"),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                              }
                            },
                          );
                        } else {
                          // Display a loading indicator
                          return CircularProgressIndicator();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget fieldsOnScreen() {
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
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(labelText: "Username"),
            validator: (val) => val!.isEmpty ? "Enter a valid username" : null,
          ),
          const SizedBox(
            height: 10,
          ),
          TextFormField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(labelText: "Password"),
            validator: (val) =>
            val!.length < 6 ? "Password must be at least 6 characters" : null,
          ),
          const SizedBox(
            height: 20,
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ForgotPasswordScreen(),
                ),
              );
            },
            child: Text(
              "Forgot your password?",
              style: TextStyle(color: Colors.blue[800]),
            ),
          ),
        ],
      ),
    );
  }
}
