import 'package:flutter/material.dart';
import 'package:snapchat_ui_clone/screens/Stage%201/login_screen.dart';
import 'package:snapchat_ui_clone/screens/Stage%201/signup_screen.dart';

import '../../widgets/auth_button.dart';

class AuthenticationScreen extends StatefulWidget {
  @override
  _AuthenticationScreenState createState() => _AuthenticationScreenState();
}
class _AuthenticationScreenState extends State<AuthenticationScreen>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(height: 100),
          Container(
            alignment: Alignment.center,
            child: Image.asset('assets/images/TeamUPLogo.png'),
            height: 160,
          ),
          const SizedBox(height: 10),
          Container(
            child: Column(
              children: [
                AuthButton(
                  color: Colors.lightBlueAccent,
                  text: "LOG IN",
                  onPress: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()));
                  },
                ),
                AuthButton(
                  color: Colors.indigo,
                  text: "SIGN UP",
                  onPress: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignUpScreen()));
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );

  }
}


