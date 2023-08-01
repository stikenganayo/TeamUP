import 'package:flutter/material.dart';
import 'package:snapchat_ui_clone/widgets/subscription.dart';
import '../data.dart';

class Subscriptions extends StatelessWidget {
  const Subscriptions ({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context)  {
    List<Widget> children = List.generate(
        Data.subscriptions.length,
            (index) => Subscription(
            index: index,
            title: Data.subscriptions[index].name,
            description: Data.subscriptions[index].description));
    children.insert(0, const SizedBox(width: 10));
    children.add(const SizedBox (width: 10));
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      scrollDirection: Axis.horizontal,
      child: Row(
        children: children,
      ),
    );
  }
}