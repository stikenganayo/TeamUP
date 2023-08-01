import 'package:flutter/material.dart';

class AuthButton extends StatelessWidget{
  final Color color;
  final String text;
  final onPress;

  const AuthButton({Key? key,
    required this.color, required this.text, required this.onPress

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
        height: 120,
        color: color,
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}