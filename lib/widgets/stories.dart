import 'package:flutter/material.dart';
import 'package:snapchat_ui_clone/widgets/story.dart';
import '../data.dart';
import '../style.dart';

class Stories extends StatelessWidget {
  const Stories({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context){
    List<Widget>? children = List.generate(
        Data.friends.length,
            (index) => Column(
          children: [
            Story(index: index),
            Style.friendName(Data.friends[index].name),
          ],
        ));
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