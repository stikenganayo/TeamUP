import 'package:flutter/material.dart';

import '../style.dart';

class ChatView extends StatelessWidget {
  const ChatView({Key? key,
    required this.index,
    required this.name,
    required this.status,
    required this.time

    // required this.description
  })
      : super(key: key);
  final int index;
  final String name;
  final String status;
  final String time;
  // final String description;

  @override
  Widget build(BuildContext context){
    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          // color: Style.tempColors[index % Style.tempColors.length],
          color: Colors.lightBlueAccent,

        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Style.friendName(name),
              const Spacer(),
              Row(
                children: [
                  Style.statusName(status),
                  const Text(" -> "),
                  Style.statusName(time),
                ],
              )

            ],
          ),
        ));
  }
}