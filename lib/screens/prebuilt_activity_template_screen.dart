import 'package:flutter/material.dart';
import 'package:snapchat_ui_clone/screens/selection_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PrebuiltActivityTemplateScreen extends StatefulWidget {
  const PrebuiltActivityTemplateScreen({Key? key}) : super(key: key);

  @override
  _PrebuiltActivityTemplateScreenState createState() =>
      _PrebuiltActivityTemplateScreenState();
}

class _PrebuiltActivityTemplateScreenState
    extends State<PrebuiltActivityTemplateScreen> {
  bool canPostEvent = false;

  late User? currentUser;
  List<String> selectedFriends = [];
  List<String> selectedTeams = [];
  String selectedTemplate = '';
  String selectedTemplateDescription = '';

  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      print('Current User ID: ${currentUser!.uid}');
    } else {
      print('Current User is null');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 20),

                // Display template description
                if (selectedTemplateDescription.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      selectedTemplateDescription,
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.black,
                      ),
                    ),
                  ),

                const SizedBox(height: 20),

                // List view with checkboxes
                ListView(
                  shrinkWrap: true,
                  children: [
                    _buildTemplateItem('Budget Tracker'),
                    _buildTemplateItem('Fitness Tracker'),
                    _buildTemplateItem('Nutrition Tracker'),
                  ],
                ),

                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SelectionScreen(),
                      ),
                    ).then((result) {
                      if (result != null && result is Map<String, dynamic>) {
                        setState(() {
                          selectedFriends.clear();
                          if (result.containsKey('friends') &&
                              result['friends'] is List<String>) {
                            selectedFriends.addAll(result['friends']);
                          }

                          selectedTeams.clear();
                          if (result.containsKey('teams') &&
                              result['teams'] is List<String>) {
                            selectedTeams.addAll(result['teams']);
                          }

                          // Update the canPostEvent flag
                          canPostEvent = selectedTemplate.isNotEmpty &&
                              (selectedFriends.isNotEmpty || selectedTeams.isNotEmpty);
                        });
                      }
                    });
                  },
                  child: const Text('Challenge who?'),
                ),
                const SizedBox(height: 20),

                // Display selected friends and teams
                if (selectedFriends.isNotEmpty || selectedTeams.isNotEmpty)
                  Column(
                    children: [
                      Text(
                        'Posting to:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          ...selectedFriends.map(
                                (friendName) => Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Chip(
                                label: Text(friendName),
                                backgroundColor: Colors.grey,
                              ),
                            ),
                          ),
                          ...selectedTeams.map(
                                (teamName) => Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Chip(
                                label: Text(teamName),
                                backgroundColor: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: canPostEvent
                      ? () async {
                    if (_isDisposed) return; // Check if the widget is disposed
                    try {
                      await postEvent();
                      if (!_isDisposed) {
                        Navigator.pop(
                            context); // Close the screen if not disposed
                      }
                    } catch (e) {
                      if (!_isDisposed) {
                        print('Error posting event: $e');
                      }
                    }
                  }
                      : null,
                  child: const Text('Post Challenge'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTemplateItem(String templateName) {
    return CheckboxListTile(
      title: Text(templateName),
      value: selectedTemplate == templateName,
      onChanged: (value) {
        setState(() {
          selectedTemplate = value! ? templateName : '';
          // Update the canPostEvent flag
          canPostEvent = selectedTemplate.isNotEmpty &&
              (selectedFriends.isNotEmpty || selectedTeams.isNotEmpty);

          // Update the template description
          if (selectedTemplate == 'Budget Tracker') {
            selectedTemplateDescription =
            'With the Budget Tracker Challenge, your team will be tasked individually to track your expenses on a daily basis, and will be rewarded with streaks for maintaining consistency.';
          } else {
            selectedTemplateDescription = '';
          }
        });
      },
    );
  }


Future<void> postEvent() async {
    try {
      currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        print('Current User Email: ${currentUser!.email}');

        // Fetch user data based on the provided email
        QuerySnapshot userQuerySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: currentUser!.email)
            .limit(1)
            .get();

        if (mounted && userQuerySnapshot.docs.isNotEmpty) {
          DocumentSnapshot userSnapshot = userQuerySnapshot.docs.first;
          Map<String, dynamic> userData =
          userSnapshot.data() as Map<String, dynamic>;

          // Create a reference to the 'events' collection
          CollectionReference eventsCollection =
          FirebaseFirestore.instance.collection('challenge_templates');

          if (mounted) {
            // Add the event data as a new document in the 'events' collection
            DocumentReference challengeDocRef = await eventsCollection.add({
              'CurrentUserEmail': currentUser!.email,
              'CurrentUserName': userData['name'], // Store the user's name
              'selectedFriends': selectedFriends,
              'selectedTeams': selectedTeams,
              'template_name': selectedTemplate, // Store the template_name
              'frequency': "Track expenses every day"
            });



            print('Challenge Posted:');
            print('Selected Friends: $selectedFriends');
            print('Selected Teams: $selectedTeams');

            // Iterate through selectedFriends and update user's events
            for (String friendName in selectedFriends) {
              // Find friend's ID in the 'users' collection
              QuerySnapshot friendQuerySnapshot = await FirebaseFirestore.instance
                  .collection('users')
                  .where('name', isEqualTo: friendName)
                  .limit(1)
                  .get();

              if (mounted && friendQuerySnapshot.docs.isNotEmpty) {
                DocumentSnapshot friendSnapshot =
                    friendQuerySnapshot.docs.first;
                String friendId = friendSnapshot.id;

                // Update the user's document with the event data
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(friendId)
                    .update({
                  'user_challenges': FieldValue.arrayUnion([
                    {
                      'status': 'pending',
                      'challengeDocRef': challengeDocRef.id, // Store the eventDocRef
                      'template_name': selectedTemplate, // Store the template_name
                    }
                  ])
                });
              }
            }
            // Iterate through selectedTeams and update users' events
            for (String teamName in selectedTeams) {
              // Find team's ID in the 'teams' collection
              QuerySnapshot teamQuerySnapshot = await FirebaseFirestore.instance
                  .collection('teams')
                  .where('team_name', isEqualTo: teamName)
                  .limit(1)
                  .get();

              if (mounted && teamQuerySnapshot.docs.isNotEmpty) {
                DocumentSnapshot teamSnapshot = teamQuerySnapshot.docs.first;
                String teamId = teamSnapshot.id;

                // Get the list of users in the selected team
                List<String> teamMembers =
                List<String>.from(teamSnapshot['users'] ?? []);

                // Print the users in the selected team
                print('Users in $teamName:');
                for (String teamMember in teamMembers) {
                  print('- $teamMember');
                }

                // Update the team's document with the event data
                await FirebaseFirestore.instance
                    .collection('teams')
                    .doc(teamId)
                    .update({
                  'team_challenges': FieldValue.arrayUnion([
                    {
                      'status': 'pending',
                      'challengeDocRef': challengeDocRef.id, // Store the eventDocRef
                      'template_name': selectedTemplate, // Store the template_name
                    }
                  ])
                });

                // Iterate through each user and update their 'team_events'
                for (String teamMember in teamMembers) {
                  // Find the user's ID in the 'users' collection
                  QuerySnapshot userQuerySnapshot = await FirebaseFirestore.instance
                      .collection('users')
                      .where('name', isEqualTo: teamMember)
                      .limit(1)
                      .get();

                  if (userQuerySnapshot.docs.isNotEmpty) {
                    DocumentSnapshot userSnapshot = userQuerySnapshot.docs.first;
                    String userId = userSnapshot.id;

                    // Update the user's document with the event data
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(userId)
                        .update({
                      'team_challenges': FieldValue.arrayUnion([
                        {
                          'status': 'pending',
                          'challengeDocRef': challengeDocRef.id, // Store the eventDocRef
                          'template_name': selectedTemplate, // Store the template_name
                        }
                      ])
                    });
                  }
                }
              }
            }
          }
        } else {
          if (!_isDisposed) {
            print('User document not found for the current user');
          }
        }
      } else {
        if (!_isDisposed) {
          print('Current User is null');
        }
      }
    } catch (e, stackTrace) {
      if (!_isDisposed) {
        print('Error posting event: $e');
        print('StackTrace: $stackTrace');
      }
    }
  }
}
