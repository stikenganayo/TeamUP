import 'package:flutter/material.dart';

import '../style.dart';

class DiscoverView extends StatelessWidget {
  const DiscoverView({Key? key,
    required this.index,
    required this.title,
    required this.description})
    : super(key: key);
  final int index;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context){
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Style.tempColors[index % Style.tempColors.length],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
            children: [
              Style.discoverTitle(title),
              const Spacer(),
              Style.discoverDesc(description),
            ],
          ),
      ));
  }
}