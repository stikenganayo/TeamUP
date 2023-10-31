import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

import '../style.dart';
import '../screens/chat_list.dart';
import '../screens/search_screen.dart';

class FriendsGrid extends StatelessWidget {

  const FriendsGrid({Key? key,}) : super(key: key);

  Future<String> loadJsonData() async {
    return await rootBundle.loadString('assets/images/data/team_data.json');
  }

  @override
  Widget build(BuildContext context) {
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

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const SearchScreen(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue,
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  padding: const EdgeInsets.all(10),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 3,
                  children: List.generate(friendNames.length, (index) {
                    final name = friendNames[index];
                    const status = ''; // Replace with actual status from Data or JSON
                    const time = ''; // Replace with actual time from Data or JSON
                    return ChatView(
                      index: index,
                      name: name,
                      status: status,
                      time: time,
                    );
                  }),
                ),
              ],
            ),
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
                  const Text(" Online -> Now"),
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
