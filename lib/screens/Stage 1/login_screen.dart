import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:snapchat_ui_clone/screens/Stage%201/signup_screen.dart';

import '../../main.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  _signinWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn();
      var user = await googleSignIn.signIn();
      if (user != null) {
        print('User name: ${user.displayName}');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainPage()),
        );
      } else {
        print('Sign in failed');
      }
    } catch (e) {
      print('Google Sign-In Error: $e');
    }
  }

  void _signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      final token = result.accessToken!.token;
      print('Facebook token userID: ${result.accessToken!.grantedPermissions}');

      // final graphResponse = await http.get(Uri.parse('https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=$token'));
      //
      // if (graphResponse.statusCode == 200) {
      //   final profile = jsonDecode(graphResponse.body);
      //   print("Profile is equal to $profile");
      //
      //   // Continue processing the user data here.
      // } else {
      //   print('Failed to fetch user data: ${graphResponse.reasonPhrase}');
      // }
    } catch (e) {
      print('Facebook Sign-in Error: $e');
    }
  }








  Future<void> _signin() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        User? user = userCredential.user;

        if (user != null) {
          // Sign-in successful, you can navigate to the next screen
          print('Login Successful');
          // Replace 'MainPage' with the actual screen you want to navigate to
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainPage()),
          );
        } else {
          // Handle unsuccessful sign-in
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
      } catch (e) {
        // Handle any errors that occurred during the sign-in process
        print("Firebase Sign-In Error: $e");
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Login Failed"),
              content: Text("An error occurred during login."),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("OK"),
                )],
            );
          },
        );
      }
    }
  }

  void _navigateToSignUpScreen() {
    // Navigate to the SignUpScreen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignUpScreen()),
    );
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
                      height: 20, // Reduced the height
                    ),
                    Container(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20), // Added spacing
                            child: fieldsOnScreen(),
                          ),
                          LoginAndSignUpButton( // Moved the Login button here
                            color: Colors.blue,
                            text: "Log In",
                            onPress: _signin,
                          ),
                          SizedBox(height: 10), // Added spacing

                          GestureDetector(
                            onTap: _navigateToSignUpScreen,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Don't have an account? ",
                                  style: TextStyle(color: Colors.black87),
                                ),
                                Text(
                                  "Sign Up",
                                  style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 50), // Added spacing
                          LoginAndSignUpButton( // Moved the Login button here
                            color: Colors.blue,
                            text: "Sign In with Google",
                            onPress: _signinWithGoogle,
                          ),
                          const SizedBox(height: 10), // Added spacing

                          const SizedBox(height: 50), // Added spacing
                          LoginAndSignUpButton( // Moved the Login button here
                            color: Colors.blue,
                            text: "Sign In with Facebook",
                            onPress: _signInWithFacebook,
                          ),
                          const SizedBox(height: 10), // Added spacing
                        ],
                      ),
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
            decoration: InputDecoration(labelText: "Email"),
            validator: (val) =>
            val!.isEmpty ? "Enter a valid email" : null,
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
        ],
      ),
    );
  }
}

class LoginAndSignUpButton extends StatelessWidget {
  final Color color;
  final String text;
  final VoidCallback onPress;

  const LoginAndSignUpButton({
    required this.color,
    required this.text,
    required this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(primary: color),
      onPressed: onPress,
      child: Text(
        text,
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}