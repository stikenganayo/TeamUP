import 'dart:math';

import 'package:flutter/material.dart';
import 'package:snapchat_ui_clone/widgets/story.dart';
import '../style.dart';
import 'package:story_view/story_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Stories extends StatefulWidget {
  const Stories({Key? key}) : super(key: key);

  @override
  _StoriesState createState() => _StoriesState();
}

class _StoriesState extends State<Stories> {
  User? currentUser;
  List<String> friendsList = [];
  List<String> storyImageUrls = [];

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
            });

            print('Friends List: $friendsList');

            if (userData.containsKey('story')) {
              setState(() {
                storyImageUrls = List.from(userData['story']);
              });

              print('Story Image URLs: $storyImageUrls');
            } else {
              print('Story field not found in user document');
            }
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

  Future<List<Map<String, dynamic>>> _loadImagesAndNamesFromFirebase() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> usersSnapshot =
      await FirebaseFirestore.instance.collection('users').get();

      if (usersSnapshot.docs.isEmpty) {
        return []; // Return an empty list if no users are found
      }

      List<Map<String, dynamic>> firebaseData = List.generate(
        usersSnapshot.docs.length,
            (index) {
          // Check if the user's email is in the friendsList
          if (friendsList.contains(usersSnapshot.docs[index]['email'])) {
            String imageUrl = index < storyImageUrls.length ? storyImageUrls[index] : '';
            return {
              'imageUrl': imageUrl,
              'name': usersSnapshot.docs[index]['name'] as String,
            };
          } else {
            return {}; // Return an empty map for users not in friendsList
          }
        },
      );

      // Remove empty maps from the list
      firebaseData.removeWhere((element) => element.isEmpty);

      return firebaseData;
    } catch (error) {
      print('Error fetching data: $error');
      return []; // Return an empty list in case of an error
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _loadImagesAndNamesFromFirebase(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError || snapshot.data!.isEmpty) {
          return Text(snapshot.hasError ? 'Error: ${snapshot.error}' : 'No user data found');
        } else {
          List<Map<String, dynamic>> firebaseData = snapshot.data!;
          List<Widget> children = List.generate(
            firebaseData.length,
                (index) => GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DetailScreen(index.toString(), firebaseData)),
                );
              },
              child: Column(
                children: [
                  Story(index: index),
                  Style.friendName(firebaseData[index]['name'] as String),
                ],
              ),
            ),
          );

          children.insert(0, const SizedBox(width: 10));
          children.add(const SizedBox(width: 10));

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            child: Row(
              children: children,
            ),
          );
        }
      },
    );
  }
}

class DetailScreen extends StatelessWidget {
  final String index;
  final List<Map<String, dynamic>> firebaseData;
  final StoryController controller = StoryController();

  DetailScreen(this.index, this.firebaseData);

  Future<String> _loadUidFromFirebase(String name) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('name', isEqualTo: name)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.id; // Assuming 'id' holds the UID in the 'users' collection
      } else {
        print('User not found in Firestore');
        return '';
      }
    } catch (e) {
      print('Error loading UID document: $e');
      return '';
    }
  }

  Future<String> _loadImageFromFirebase(String uid) async {
    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid) // Use the fetched UID here
          .get();
      return docSnapshot.get('story') as String;
    } catch (e) {
      print('Error loading image document: $e');
      return '';
    }
  }
  Color _generateRandomColor() {
    final Random random = Random();
    return Color.fromRGBO(random.nextInt(256), random.nextInt(256), random.nextInt(256), 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _loadUidFromFirebase(firebaseData[int.parse(index)]['name']),
      builder: (context, uidSnapshot) {
        if (uidSnapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (uidSnapshot.hasError || !uidSnapshot.hasData) {
          return Text(uidSnapshot.hasError ? 'Error: ${uidSnapshot.error}' : 'No UID found');
        } else {
          String uid = uidSnapshot.data!;
          return FutureBuilder<String>(
            future: _loadImageFromFirebase(uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError || !snapshot.hasData) {
                return Text(snapshot.hasError ? 'Error: ${snapshot.error}' : 'No image found');
              } else {
                String imageUrl = snapshot.data!;
                return Scaffold(
                  body: Container(
                    margin: EdgeInsets.all(8),
                    child: StoryView(
                      controller: controller,
                      storyItems: [
                        StoryItem.text(
                          title:
                          "Hello, ${firebaseData[int.parse(index)]['name']}!\n\nYou are on a 10 day streak! \nKeep up the good work! \n\nYou have gained 100 Points this week! \nKeep it up!",
                          backgroundColor: _generateRandomColor(), // Use random color here
                          roundedTop: true,
                        ),
                        StoryItem.inlineImage(
                          url: imageUrl,
                          controller: controller,
                          caption: Text(
                            "Caption for the image",
                            style: TextStyle(
                              color: Colors.white,
                              backgroundColor: Colors.black54,
                              fontSize: 17,
                            ),
                          ),
                        ),
                        // Add more StoryItems as needed
                      ],
                      onStoryShow: (s) {
                        print("Showing a story");
                      },
                      onComplete: () {
                        print("Completed a cycle");
                        print('UID of ${firebaseData[int.parse(index)]['name']}: $uid');
                      },
                      progressPosition: ProgressPosition.bottom,
                      repeat: false,
                      inline: true,
                    ),
                  ),
                );
              }
            },
          );
        }
      },
    );
  }
}

