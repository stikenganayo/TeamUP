import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Add this import
import 'package:firebase_auth/firebase_auth.dart';

import '../style.dart';
import '../screens/chat_list.dart'; // Import the ChatScreen widget from the chat_list.dart file
import '../screens/search_screen.dart';

class FriendsGrid extends StatefulWidget {
  const FriendsGrid({Key? key}) : super(key: key);

  @override
// Add an underscore to match the state class name
  _FriendsGridState createState() => _FriendsGridState();
}

class _FriendsGridState extends State<FriendsGrid> {
  User? currentUser;
  List<String> friendsList = [];
  List<String> filteredFriendsList = [];

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      print('Current User Email: ${currentUser!.email}');

      try {
        QuerySnapshot userQuerySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: currentUser!.email)
            .limit(1)
            .get();

        if (userQuerySnapshot.docs.isNotEmpty) {
          DocumentSnapshot userSnapshot = userQuerySnapshot.docs.first;
          Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;

          print('User Data: $userData');

          if (userData.containsKey('friends')) {
            setState(() {
              friendsList = List.from(userData['friends']);
              filteredFriendsList = List.from(friendsList);
            });

            print('Friends List: $friendsList');
          } else {
            print('Friends field not found in user document');
          }
        } else {
          print('User document not found for the current user');
        }
      } catch (e) {
        print('Error loading user document: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
            children: List.generate(filteredFriendsList.length, (index) {
              final name = filteredFriendsList[index].replaceAll('@gmail.com', '');
              const status = ''; // Replace with actual status from Data or JSON
              const time = ''; // Replace with actual time from Data or JSON
              return ChatView(
                index: index,
                name: name,
                status: status,
                time: time,
// Pass the filteredFriendsList as a parameter
                filteredFriendsList: filteredFriendsList,
              );
            }),
          ),
        ],
      ),
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
// Add a parameter for the filteredFriendsList
    required this.filteredFriendsList,
  }) : super(key: key);

  final int index;
  final String name;
  final String status;
  final String time;
// Add a field for the filteredFriendsList
  final List<String> filteredFriendsList;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
// Add an onTap callback to navigate to the ChatScreen widget
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              friendName: name,
// Pass the friend's email instead of an empty string
              friendEmail: filteredFriendsList[index],
            ),
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}