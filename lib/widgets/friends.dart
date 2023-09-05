import 'package:flutter/material.dart';
import '../data.dart';
import '../style.dart';
import '../screens/chat_list.dart';

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



class ChatView extends StatelessWidget {
  const ChatView({
    Key? key,
    required this.index,
    required this.name,
    required this.status,
    required this.time,
  }) : super(key: key);

  final int index;
  final String name;
  final String status;
  final String time;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to the ChatScreen when clicked
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChatScreen(friendName: name),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}