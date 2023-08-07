import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:snapchat_ui_clone/widgets/discover_view.dart';
import '../data.dart';
import 'chat_view.dart';

class FriendsGrid extends StatelessWidget {
  const FriendsGrid ({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context){
    return GridView.count(
        padding: const EdgeInsets.all(10),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 1,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 6,

        children: List.generate(Data.chatFriends.length, (index) => ChatView(
            index: index,
            name: Data.chatFriends[index].name,
            status: Data.chatFriends[index].status,
            time: Data.chatFriends[index].time,
        )));
  }
}