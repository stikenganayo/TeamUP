import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapchat_ui_clone/screens/event_screen.dart';
import 'package:snapchat_ui_clone/screens/search_screen.dart';
import '../style.dart';
import '../widgets/friends.dart';
import '../widgets/top_bar.dart';
import '../widgets/team_stories.dart';
import 'add_challenge_screen.dart';
import 'add_event_screen.dart';
import 'create_team_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

class TeamScreen extends StatefulWidget {
  const TeamScreen({Key? key}) : super(key: key);

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  late User? currentUser;

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
        // Fetch the user document based on the current user's email
        QuerySnapshot userQuerySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: currentUser!.email)
            .limit(1)
            .get();

        if (userQuerySnapshot.docs.isNotEmpty) {
          DocumentSnapshot userSnapshot = userQuerySnapshot.docs.first;
          Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;

          // Print all data inside the current user's document
          print('User Data: $userData');

          // Check for team_ids in the user data
          if (userData.containsKey('team_ids')) {
            setState(() {});
          } else {
            print('Team_ids field not found in user document');
          }
        } else {
          print('User document not found for the current user');
        }
      } catch (e) {
        print('Error loading user document: $e');
      }
    }
  }

  Future<List<String>> _getTeamIds() async {
    try {
      // Fetch the user document based on the current user's email
      QuerySnapshot userQuerySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: currentUser!.email)
          .limit(1)
          .get();

      if (userQuerySnapshot.docs.isNotEmpty) {
        DocumentSnapshot userSnapshot = userQuerySnapshot.docs.first;
        Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;

        // Print all data inside the current user's document
        print('User Data: $userData');

        // Check for team_ids in the user data
        if (userData.containsKey('team_ids')) {
          List<String> teamIds = List.from(userData['team_ids']);
          // Reverse the order of team IDs
          List<String> reversedTeamIds = List.from(teamIds.reversed);
          // Print the array of team IDs to the console
          print('Team IDs: $reversedTeamIds');
          return reversedTeamIds;
        } else {
          print('Team_ids field not found in user document');
        }
      } else {
        print('User document not found for the current user');
      }
    } catch (e) {
      print('Error loading user document: $e');
    }

    return [];
  }


  Future<List<String>> _getTeamUsers(String teamId) async {
    try {
      // Fetch the team document based on the team ID
      DocumentSnapshot teamSnapshot = await FirebaseFirestore.instance
          .collection('teams')
          .doc(teamId)
          .get();

      if (teamSnapshot.exists) {
        Map<String, dynamic> teamData = teamSnapshot.data() as Map<String, dynamic>;

        // Check for the 'users' field and 'team_name' field in the team data
        if (teamData.containsKey('users') && teamData.containsKey('team_name')) {
          List<String> teamUsers = List.from(teamData['users']);
          String teamName = teamData['team_name'];

          // Print the array of team users and the team name to the console
          print('Team Users for $teamId: $teamUsers');
          print('Team Name for $teamId: $teamName');

          return [teamName];
        } else {
          print('Users or Team name field not found in team document');
        }
      } else {
        print('Team document not found for $teamId');
      }
    } catch (e) {
      print('Error loading team document: $e');
    }

    return [];
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
          const TopBar(isCameraPage: false, text: 'Team'),
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height -
                100 -
                (Platform.isIOS ? 90 : 60),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Style.sectionTitle('Team Stories'),
                  const Stories(), // Add the Stories widget here
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const SizedBox(width: 4),
                          ElevatedButton(
                            onPressed: () async {
                              // Show a loading indicator while creating a team
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                },
                              );

                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SearchScreen(initialTabIndex: 1),
                                ),
                              );

                              // Introduce a delay of 1 second before reloading the team list
                              await Future.delayed(Duration(seconds: 4));

                              // After creating a team and the delay, reload the team list
                              _loadCurrentUser();

                              // Close the loading indicator dialog
                              Navigator.pop(context);
                            },
                            child: Text('Create a team'),
                          ),

                          const SizedBox(width: 4),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CreateEvent(),
                                ),
                              );
                              // Handle the "Create an event/activity" button tap
                              // e.g., Navigator.push(context, MaterialPageRoute(builder: (context) => CreateEventActivityScreen()));
                            },
                            child: Text('Create an Event'),
                          ),
                          const SizedBox(width: 4),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CreateChallenge(),
                                ),
                              );
                              // Handle the "Create a team" button tap
                              // e.g., Navigator.push(context, MaterialPageRoute(builder: (context) => CreateTeamScreen()));
                            },
                            child: Text('Create an Activity'),
                          ),
                          const SizedBox(width: 4),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Style.sectionTitle('Teams'),
                  const SizedBox(height: 10),
                  // Display the current list of friends IDs

                  // Display the current list of team IDs
                  FutureBuilder<List<String>>(
                    future: _getTeamIds(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasError || snapshot.data == null) {
                          return ListTile(
                            title: Text('Error loading team IDs'),
                          );
                        } else {
                          // Display team IDs and users
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: snapshot.data!.map((teamId) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey[300]!),
                                      borderRadius: BorderRadius.all(Radius.circular(8)),
                                      // Add any padding or margin as needed
                                      // padding: EdgeInsets.all(8),
                                      // margin: EdgeInsets.all(8),
                                    ),
                                    child: FutureBuilder<List<String>>(
                                      future: _getTeamUsers(teamId),
                                      builder: (context, userSnapshot) {
                                        if (userSnapshot.connectionState ==
                                            ConnectionState.done) {
                                          if (userSnapshot.hasError ||
                                              userSnapshot.data == null) {
                                            return ListTile(
                                              title: Text('Error loading team users for $teamId'),
                                            );
                                          } else {
                                            // Display team name and team ID
                                            return ListTile(
                                              title: Text('${userSnapshot.data![0]}'),
                                              onTap: () {
                                                // Handle selected team
                                                Navigator.pop(context); // Close the dropdown
                                              },
                                            );
                                          }
                                        } else {
                                          // Display loading indicator while fetching data
                                          return ListTile(
                                            title: CircularProgressIndicator(),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              );
                            }).toList(),
                          );
                        }
                      } else {
                        // Display loading indicator while fetching data
                        return ListTile(
                          title: CircularProgressIndicator(),
                        );
                      }
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