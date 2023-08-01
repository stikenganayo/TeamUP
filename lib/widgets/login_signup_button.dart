import 'package:flutter/material.dart';

class LoginAndSignUpButton extends StatelessWidget {
  final Color color;
  final onPress;
  final String text;

  LoginAndSignUpButton({
    required this.color,
    required this.onPress,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onPress,
        child: Container(
            height: 55,
            width: 260,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(50)
            ),
            child: Center(
                child: Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    )
                )
            )
        )
    );
  }
}
