import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  String error = "";
  String username = "";
  String password = "";
  String email = "";

  // Create a reference to your Firestore instance.
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> registerUser(String email, String password) async {
    User? user;
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      user = userCredential.user;
    } catch (e) {

    }
    return user;
  }



  _signUp() async {
    var valid = _formKey.currentState?.validate();
    User? user;
    if (!valid!) {
      return;
    } else {
      user = await registerUser(email, password);
      if(user != null) {
        // Add user data to Firestore
        _firestore.collection('users').add({
          'name': username,
          'email': email,
          'password': password,
        }).then((value) {
          if (value != null) {
            print(value);
            // After successfully adding the user to Firestore, you can navigate to the next screen.
            // For example:
            // Navigator.pushReplacement(
            //   context,
            //   MaterialPageRoute(builder: (context) => NextScreen()),
            // );
          }
        });
      }

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.only(top: 30, bottom: 40),
        child: Form(
          key: _formKey,
          child: Column(
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
                      height: 50,
                    ),
                    fieldsOnScreen(),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              signUpButton(),
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
            "Sign Up",
            style: TextStyle(
              color: Colors.black87,
              fontSize: 25,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextFormField(
            keyboardType: TextInputType.text,
            decoration: const InputDecoration(labelText: "Username"),
            validator: (val) => val!.length < 2 ? "Minimum 2 characters are needed" : null,
            onChanged: (val) {
              setState(() {
                username = val;
              });
            },
          ),
          TextFormField(
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(labelText: "Email"),
            validator: (val) => val!.isEmpty ? "Enter an email" : null,
            onChanged: (val) {
              setState(() {
                email = val;
              });
            },
          ),
          const SizedBox(
            height: 10,
          ),
          TextFormField(
            keyboardType: TextInputType.visiblePassword,
            obscureText: true,
            decoration: InputDecoration(labelText: "Password"),
            validator: (val) => val!.length < 6 ? "Password must be 6+ characters" : null,
            onChanged: (val) {
              setState(() {
                password = val;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget signUpButton() {
    return Container(
      child: Column(
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Colors.blue,
            ),
            onPressed: _signUp,
            child: Text("Sign Up & Accept"),
          ),
        ],
      ),
    );
  }
}
