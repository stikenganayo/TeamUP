import 'package:flutter/cupertino.dart';

class TemporaryScreen extends StatelessWidget {
  const TemporaryScreen({Key? key, required this.color}) : super(key: key);
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(12),
      )
    );

  }
}