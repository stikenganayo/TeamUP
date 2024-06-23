import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ShareImageScreen extends StatefulWidget {
  final String imagePath;

  ShareImageScreen({required this.imagePath});

  @override
  _ShareImageScreenState createState() => _ShareImageScreenState();
}

class _ShareImageScreenState extends State<ShareImageScreen> {
  late User currentUser; // Define currentUser variable
  List<String> friendsList = []; // List to hold friends' names
  List<String> teamsList = []; // List to hold teams' names
  Map<String, bool?> _selectedOptions = {}; // Track the selected options

  @override
  void initState() {
    super.initState();
    _loadCurrentUser(); // Call function to load current user
    _loadFriendsList(); // Call function to load friends list
    _loadTeamsList(); // Call function to load teams list
  }

  // Function to load current user
  void _loadCurrentUser() {
    currentUser = FirebaseAuth.instance.currentUser!;
  }

  // Function to load friends list
  void _loadFriendsList() async {
    try {
      String? currentUserEmail = currentUser.email;
      if (currentUserEmail != null) {
        QuerySnapshot userQuerySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: currentUserEmail)
            .limit(1)
            .get();

        if (userQuerySnapshot.docs.isNotEmpty) {
          DocumentSnapshot userSnapshot = userQuerySnapshot.docs.first;
          Map<String, dynamic> userData =
          userSnapshot.data() as Map<String, dynamic>;

          // Check for 'friends' field in user document
          if (userData.containsKey('friends')) {
            List<dynamic> friends = userData['friends'];

            // Fetch names of friends
            List<String> names = [];
            for (String friendEmail in friends) {
              QuerySnapshot friendQuerySnapshot = await FirebaseFirestore
                  .instance
                  .collection('users')
                  .where('email', isEqualTo: friendEmail)
                  .limit(1)
                  .get();

              if (friendQuerySnapshot.docs.isNotEmpty) {
                DocumentSnapshot friendSnapshot =
                    friendQuerySnapshot.docs.first;
                Map<String, dynamic> friendData =
                friendSnapshot.data() as Map<String, dynamic>;

                // Add the name of the friend to the list
                if (friendData.containsKey('name')) {
                  String friendName = friendData['name'] as String;
                  names.add(friendName);
                } else {
                  print(
                      'Name field not found for friend with email: $friendEmail');
                }
              } else {
                print(
                    'User document not found for friend with email: $friendEmail');
              }
            }

            setState(() {
              friendsList = names;
            });
          } else {
            print('User has no friends.');
          }
        } else {
          print('User document not found for current user');
        }
      } else {
        print('Current user email is null');
      }
    } catch (e) {
      print('Error loading user friends: $e');
    }
  }

  // Function to load teams list
  void _loadTeamsList() async {
    try {
      List<String> teams = await _getUserTeams();
      setState(() {
        teamsList = teams;
      });
    } catch (e) {
      print('Error loading user teams: $e');
    }
  }

  Future<List<String>> _getUserTeams() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        String currentUserEmail = currentUser.email!;
        QuerySnapshot userQuerySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: currentUserEmail)
            .limit(1)
            .get();

        if (userQuerySnapshot.docs.isNotEmpty) {
          DocumentSnapshot userSnapshot = userQuerySnapshot.docs.first;
          Map<String, dynamic> userData =
          userSnapshot.data() as Map<String, dynamic>;

          if (userData.containsKey('team_ids')) {
            List<dynamic> teamIds = userData['team_ids'];
            List<String> teamNames = [];

            for (String teamId in teamIds) {
              DocumentSnapshot teamSnapshot =
              await FirebaseFirestore.instance.collection('teams').doc(teamId).get();

              if (teamSnapshot.exists) {
                Map<String, dynamic> teamData =
                teamSnapshot.data() as Map<String, dynamic>;
                if (teamData.containsKey('team_name')) {
                  teamNames.add(teamData['team_name']);
                }
              }
            }
            return teamNames;
          } else {
            print('Team_ids field not found in user document');
            return [];
          }
        } else {
          print('User document not found for the current user');
          return [];
        }
      } else {
        print('Current user is null');
        return [];
      }
    } catch (e) {
      print('Error fetching user teams: $e');
      return [];
    }
  }

  void _sendMessageToFriend(BuildContext context, String friendName, String imagePath) async {
    try {
      // Get the current user's email
      String? currentUserEmail = FirebaseAuth.instance.currentUser?.email;

      if (currentUserEmail != null) {
        // Remove the "@gmail.com" part
        String currentUserEmailWithoutDomain =
            currentUserEmail.split('@').first;

        // Check if 'Public Story' is selected
        if (_selectedOptions.containsKey('Public Story') && _selectedOptions['Public Story'] == true) {
          await _postToStory(context); // Await _postToStory method if 'Public Story' is selected
        }

        // Send message to selected friends
        List<String> selectedFriends = _selectedOptions.keys.where((option) => _selectedOptions[option] == true && option != 'Public Story').toList();
        if (selectedFriends.isNotEmpty) {
          selectedFriends.forEach((friendName) async {
            await _sendMessageToFriendAsync(context, friendName, imagePath); // Pass imagePath instead of message
          });
          // Optionally, you can add logic here to notify the user that messages were sent.
          print('Messages sent with image path: $imagePath');
        }

        Navigator.pop(context);

        // Optionally, you can add logic here to handle other selected options like teams, community, etc.
        // ...

      } else {
        print('Current user email is null');
      }
    } catch (e) {
      print('Error sending message: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to send message. Please try again.'),
      ));
    }
  }

// Function to send the image as a message to a friend
  Future<void> _sendMessageToFriendAsync(BuildContext context, String friendName, String imagePath) async {
    try {
      // Get the current user's email
      String? currentUserEmail = FirebaseAuth.instance.currentUser?.email;

      if (currentUserEmail != null) {
        // Remove the "@gmail.com" part
        String currentUserEmailWithoutDomain =
            currentUserEmail.split('@').first;

        // Fetch the friend's document based on the friend's name
        QuerySnapshot friendQuerySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('name', isEqualTo: friendName)
            .limit(1)
            .get();

        if (friendQuerySnapshot.docs.isNotEmpty) {
          DocumentSnapshot friendSnapshot = friendQuerySnapshot.docs.first;
          String friendUserId = friendSnapshot.id;

          // Fetch the current user's document based on the current user's email
          QuerySnapshot currentUserQuerySnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: currentUserEmail)
              .limit(1)
              .get();

          if (currentUserQuerySnapshot.docs.isNotEmpty) {
            DocumentSnapshot currentUserSnapshot =
                currentUserQuerySnapshot.docs.first;
            String currentUserId = currentUserSnapshot.id;

            // Create a map representing the message data
            Map<String, dynamic> messageData = {
              'sender': currentUserEmailWithoutDomain, // Store sender's email without domain
              'message': imagePath, // Use imagePath instead of message
              'receiver': friendName, // Store timestamp for sorting
              'imagePath': imagePath, // Add the imagePath to messageData
            };

            // Update the friend's document to add the message with the current user's name
            await FirebaseFirestore.instance
                .collection('users')
                .doc(friendUserId)
                .update({
              'message_with_${currentUserEmailWithoutDomain}':
              FieldValue.arrayUnion([messageData]),
            });

            // Update the current user's document to add the message with the friend's name
            await FirebaseFirestore.instance
                .collection('users')
                .doc(currentUserId)
                .update({
              'message_with_${friendName}':
              FieldValue.arrayUnion([messageData]),
            });
          } else {
            print('Current user document not found');
          }
        } else {
          print('Friend document not found for $friendName');
        }
      } else {
        print('Current user email is null');
      }
    } catch (e) {
      print('Error sending message: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to send message. Please try again.'),
      ));
    }
  }

// Function to post the image to the user's story
  Future<void> _postToStory(BuildContext context) async {
    try {
      User currentUser = FirebaseAuth.instance.currentUser!;
      String currentUserEmail = currentUser.email!;

      // Get the current image URL
      String imageUrl = widget.imagePath;

      // Update the current user's document to add the image URL to the story
      await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: currentUserEmail)
          .limit(1)
          .get()
          .then((querySnapshot) async {
        if (querySnapshot.docs.isNotEmpty) {
          String userId = querySnapshot.docs.first.id;
          await FirebaseFirestore.instance.collection('users').doc(userId).update({
            'story': FieldValue.arrayUnion([imageUrl]), // Wrap the imageUrl in an array
          }).then((value) {
          }).catchError((error) {
            print("Error updating document: $error");
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Failed to post to story. Please try again.'),
            ));
          });
        }
      });
    } catch (e) {
      print('Error posting to story: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to post to story. Please try again.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Share'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Send to',
                    style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8.0),
                  buildExpansionTile(
                    leadingIcon: Icons.person,
                    title: 'Friends Chat',
                    options: friendsList,
                  ),
                  buildExpansionTile(
                    leadingIcon: Icons.group,
                    title: 'Teams Chat',
                    options: teamsList,
                  ),
                  buildExpansionTile(
                    leadingIcon: Icons.event,
                    title: 'Community Chat',
                    options: ['Harbour Landing', 'Oilers Fans', 'The Greens on Gardiner', 'Hillsdale Community'],
                  ),
                  buildExpansionTile(
                    leadingIcon: Icons.assignment,
                    title: 'Coach Chat',
                    options: ['Dwayne "THE ROCK" Johnson'],
                  ),
                  SizedBox(height: 24.0),
                  Text(
                    'Post to',
                    style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8.0),
                  buildExpansionTile(
                    leadingIcon: Icons.account_circle,
                    title: 'Story',
                    options: ['Public Story', 'Private Story'],
                  ),
                  buildExpansionTile(
                    leadingIcon: Icons.group,
                    title: 'Teams Challenge',
                    options: teamsList,
                  ),
                  buildExpansionTile(
                    leadingIcon: Icons.event,
                    title: 'Community Challenge',
                    options: ['gym session', 'pizza night', 'ronis birthday', 'bushwakkers'],
                  ),
                  buildExpansionTile(
                    leadingIcon: Icons.assignment,
                    title: 'Coach Challenge',
                    options: ['Dwayne "THE ROCK" Johnson'],
                  ),
                   SizedBox(height: 16.0), // additional padding at the bottom
                ],
              ),
            ),
          ),
      if (_selectedOptions.isNotEmpty) // Show Selected Options widget conditionally
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            color: Colors.white,
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Selected Options:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.0),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _selectedOptions.entries
                        .where((entry) => entry.value ?? false) // Ensure value is not null
                        .map((entry) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Chip(label: Text(entry.key)),
                    ))
                        .toList(),
                  ),
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    // Implement share functionality here
                    List<String> selectedOptions = _selectedOptions.keys
                        .where((key) => _selectedOptions[key] ?? false)
                        .toList();
                    if (selectedOptions.isNotEmpty) {
                      selectedOptions.forEach((option) {
                        _sendMessageToFriend(context, option, widget.imagePath);
                      });
                      // Optionally, you can add logic here to notify the user that messages were sent.
                      print('Messages sent with image path: ${widget.imagePath}');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Please select at least one option to share.'),
                      ));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Make the button blue
                  ),
                  child: Text('SHARE'),
                ),
              ],
            ),
          ),
        ),
    ],
    ),
    );
  }

  Widget buildExpansionTile({
    required IconData leadingIcon,
    required String title,
    required List<String> options,
  }) {
    return Card(
      child: ExpansionTile(
        leading: Icon(leadingIcon),
        title: Text(title),
        children: options
            .map((option) => CheckboxListTile(
          title: Text(option),
          value: _selectedOptions.containsKey(option)
              ? _selectedOptions[option] ?? false // Ensure value is not null
              : false,
          onChanged: (bool? value) {
            setState(() {
              _selectedOptions[option] = value; // value can be null, but it's handled correctly here
            });
          },
          // Instead of showing two different icons, show only one check icon based on the current selection.
          // If _selectedOptions[option] is true, show a check mark, otherwise show nothing (null).
          secondary: _selectedOptions.containsKey(option) &&
              _selectedOptions[option]!
              ? Icon(Icons.check_circle, color: Colors.green)
              : null,
        ))
            .toList(),
      ),
    );
  }
}

