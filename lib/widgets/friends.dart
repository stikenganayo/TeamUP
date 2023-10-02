import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import this for rootBundle
import '../style.dart';
import '../screens/chat_list.dart';

class FriendsGrid extends StatelessWidget {
  const FriendsGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Load JSON data from the file
    Future<String> loadJsonData() async {
      return await rootBundle.loadString('assets/images/data/team_data.json');
    }

    return FutureBuilder(
      future: loadJsonData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final jsonData = jsonDecode(snapshot.data.toString());
          final List<String> friendNames = [];

          for (final team in jsonData['data']) {
            for (final subTeam in team['UserTeams'].values) {
              for (final teammate in subTeam['teammates']) {
                friendNames.add(teammate['name']);
              }
            }
          }

          return GridView.count(
            padding: const EdgeInsets.all(10),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 1,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 6,
            children: List.generate(friendNames.length, (index) {
              final name = friendNames[index];
              // You can get the status and time from Data.chatFriends or from the JSON file as needed
              const status = ''; // Replace with actual status from Data or JSON
              const time = ''; // Replace with actual time from Data or JSON
              return ChatView(
                index: index,
                name: name,
                status: status,
                time: time,
              );
            }),
          );
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
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
