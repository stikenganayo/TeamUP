import 'package:flutter/material.dart';

import '../style.dart';

class Subscription extends StatelessWidget {
  const Subscription(
      {Key? key,
      required this.index,
      required this.title,
      required this.description})
      : super(key: key);
  final int index;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context)  {
    final width = MediaQuery.of(context).size.width / 3.5;
    final height = width * 1.5;
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Style.tempColors[(index + 5) % Style.tempColors.length],
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Style.subscriptionTitle(title),
              const Spacer(),
              Style.subscriptionDesc(description),
            ],
          ),
        ),
      ),
    );
  }
}