import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../style.dart';
import '../widgets/stories.dart';
import '../widgets/top_bar.dart';
import 'dart:io';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late User? currentUser;
  List<String> friendsList = [];

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
        // Fetch the user document based on the current user's email UID
        String currentUserEmailUid = currentUser!.email ?? "";
        QuerySnapshot currentUserQuerySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: currentUserEmailUid)
            .limit(1)
            .get();

        if (currentUserQuerySnapshot.docs.isNotEmpty) {
          DocumentSnapshot currentUserSnapshot = currentUserQuerySnapshot.docs.first;
          Map<String, dynamic> userData = currentUserSnapshot.data() as Map<String, dynamic>;

          // Print all data inside the current user's document
          print('User Data: $userData');

          if (userData.containsKey('friends')) {
            setState(() {
              friendsList = List<String>.from(userData['friends']);
            });

            // Print the array of friends to the console
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
    } else {
      print('Current user is null');
    }
  }

  Future<String?> _getFriendName(String friendEmail) async {
    try {
      // Fetch the friend's document based on the email
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: friendEmail)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot friendSnapshot = querySnapshot.docs.first;
        if (friendSnapshot.exists) {
          Map<String, dynamic> friendData = friendSnapshot.data() as Map<String, dynamic>;
          if (friendData.containsKey('name')) {
            // Print the friend's UID to the console
            print('Friend UID: ${friendSnapshot.id}');

            // Return the friend's name
            return friendData['name'];
          }
        }
      }
    } catch (e) {
      print('Error loading friend document: $e');
    }

    // Return null if friend's name is not found
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Style.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          const TopBar(isCameraPage: false, text: 'Friends'),
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height - 100 - (Platform.isIOS ? 90 : 60),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Style.sectionTitle('Friend Stories'),
                  const Stories(),
                  const SizedBox(height: 40),

                  Style.sectionTitle('Friends'),

                  // Display the list of friends directly below the "Friends" title
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: friendsList.length,
                    itemBuilder: (context, index) {
                      return FutureBuilder<String?>(
                        future: _getFriendName(friendsList[index]),
                        builder: (context, friendSnapshot) {
                          if (friendSnapshot.connectionState == ConnectionState.done) {
                            if (friendSnapshot.hasError || friendSnapshot.data == null) {
                              return const Card(
                                child: ListTile(
                                  title: Text('Error loading friend name'),
                                ),
                              );
                            } else {
                              // Display friend's name on the screen within a Card
                              return Card(
                                child: ListTile(
                                  title: Text(friendSnapshot.data!),
                                  // Add any other details you want to display for each friend
                                ),
                              );
                            }
                          } else {
                            // Display a loading indicator while fetching data
                            return const Card(
                              child: ListTile(
                                title: CircularProgressIndicator(),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
