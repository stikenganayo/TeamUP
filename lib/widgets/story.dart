import 'package:flutter/material.dart';
import 'package:snapchat_ui_clone/style.dart';

class Story extends StatelessWidget {
  const Story ({Key? key, required this.index}) : super(key: key);
  final int index;

  @override
  Widget build(BuildContext context){
    return Padding(
      padding: const EdgeInsets.all(7),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 75,
            height: 75,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: Style.purpleNavbar,
            ),
          ),
          Container(
            width: 71,
            height: 71,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: Style.white,
            ),
          ),
          Container(
            width: 67,
            height: 67,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: Style.tempColors[index % Style.tempColors.length],
            ),
          ),
        ],
      ),
    );
  }
}