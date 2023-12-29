import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:snapchat_ui_clone/screens/event_screen.dart';
import 'package:snapchat_ui_clone/screens/search_screen.dart';
import '../style.dart';
import '../widgets/top_bar.dart';
import '../widgets/team_stories.dart';
import 'add_challenge_screen.dart';
import 'add_event_screen.dart';
import 'create_team_page.dart';
import 'dart:io';

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
          Map<String, dynamic> userData =
          userSnapshot.data() as Map<String, dynamic>;

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

  Future<String> _getTeamName(String teamId) async {
    try {
      // Fetch the team document based on the team ID
      DocumentSnapshot teamSnapshot = await FirebaseFirestore.instance
          .collection('teams')
          .doc(teamId)
          .get();

      if (teamSnapshot.exists) {
        Map<String, dynamic> teamData = teamSnapshot.data() as Map<String, dynamic>;

        // Check for the 'team_name' field in the team data
        if (teamData.containsKey('team_name')) {
          String teamName = teamData['team_name'];
          return teamName;
        } else {
          print('Team name field not found in team document');
        }
      } else {
        print('Team document not found for $teamId');
      }
    } catch (e) {
      print('Error loading team document: $e');
    }

    return 'Unknown Team';
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
        Map<String, dynamic> userData =
        userSnapshot.data() as Map<String, dynamic>;

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




  Future<List<String>> _getTeamPlayers(String teamId) async {
    try {
      // Fetch the team document based on the team ID
      DocumentSnapshot teamSnapshot = await FirebaseFirestore.instance
          .collection('teams')
          .doc(teamId)
          .get();

      if (teamSnapshot.exists) {
        Map<String, dynamic> teamData = teamSnapshot.data() as Map<String, dynamic>;

        // Check for the 'team_challenges' field and 'team_name' field in the team data
        if (teamData.containsKey('team_challenges') && teamData.containsKey('team_name')) {
          List<dynamic> teamChallenges = teamData['team_challenges'];
          String teamName = teamData['team_name'];

          // Print the array of team challenges and the team name to the console
          print('Team Challenges for $teamName: $teamChallenges');
          print('Team Name for $teamId: $teamName');

          // Assuming you want to get players from the first challenge
          if (teamChallenges.isNotEmpty &&
              teamChallenges[0].containsKey('players') &&
              teamChallenges[0]['players'] is List) {
            List<String> players = List.from(teamChallenges[0]['players']);
            return players;
          } else {
            print('Players field not found or not a list in team challenges');
          }
        } else {
          print('Team challenges or Team name field not found in team document');
        }
      } else {
        print('Team document not found for $teamId');
      }
    } catch (e) {
      print('Error loading team document: $e');
    }

    return [];
  }



  Future<List<String>> _getChallengeTitles(String teamId) async {
    try {
      // Fetch the team document based on the team ID
      DocumentSnapshot teamSnapshot = await FirebaseFirestore.instance
          .collection('teams')
          .doc(teamId)
          .get();

      if (teamSnapshot.exists) {
        Map<String, dynamic> teamData =
        teamSnapshot.data() as Map<String, dynamic>;

        // Print the team name directly from the teamData
        if (teamData.containsKey('team_challenges')) {
          List<dynamic> teamChallenges = teamData['team_challenges'];

          print('Team Challenges: $teamChallenges');

          // Extract challenge titles from all challenges
          List<String> challengeTitles = [];
          for (var challenge in teamChallenges) {
            if (challenge.containsKey('template_name') &&
                challenge['template_name'].isNotEmpty &&
                challenge['template_name'][0].containsKey('challengeTitle')) {
              String challengeTitle =
              challenge['template_name'][0]['challengeTitle'];
              challengeTitles.add(challengeTitle);
            }
          }

          return challengeTitles;
        } else {
          print('Team challenges field not found in team document');
        }
      } else {
        print('Team document not found for $teamId');
      }
    } catch (e) {
      print('Error loading team or challenge document: $e');
    }

    return []; // Default value if anything goes wrong
  }
  Future<List<String>> _getTeamPlayersForChallenge(String teamId, String challengeTitle) async {
    try {
      // Fetch the team document based on the team ID
      DocumentSnapshot teamSnapshot = await FirebaseFirestore.instance
          .collection('teams')
          .doc(teamId)
          .get();

      if (teamSnapshot.exists) {
        Map<String, dynamic> teamData = teamSnapshot.data() as Map<String, dynamic>;

        // Check for the 'team_challenges' field and 'team_name' field in the team data
        if (teamData.containsKey('team_challenges') && teamData.containsKey('team_name')) {
          List<dynamic> teamChallenges = teamData['team_challenges'];
          String teamName = teamData['team_name'];

          // Print the array of team challenges and the team name to the console
          print('Team Challenges for $teamName: $teamChallenges');
          print('Team Name for $teamId: $teamName');

          // Find the challenge with the matching title
          Map<String, dynamic>? selectedChallenge;
          for (var challenge in teamChallenges) {
            if (challenge.containsKey('template_name') &&
                challenge['template_name'] is List &&
                challenge['template_name'][0].containsKey('challengeTitle') &&
                challenge['template_name'][0]['challengeTitle'] == challengeTitle) {
              selectedChallenge = challenge;
              break;
            }
          }

          // Assuming you want to get players from the selected challenge
          if (selectedChallenge != null &&
              selectedChallenge.containsKey('players') &&
              selectedChallenge['players'] is List) {
            List<String> players = List.from(selectedChallenge['players']);
            return players;
          } else {
            print('Players field not found or not a list in the selected challenge');
          }
        } else {
          print('Team challenges or Team name field not found in team document');
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
                          const SizedBox(width: 16),
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
                                  builder: (context) =>
                                  const SearchScreen(initialTabIndex: 1),
                                ),
                              );

                              // Introduce a delay of 1 second before reloading the team list
                              await Future.delayed(Duration(seconds: 4));

                              // After creating a team and the delay, reload the team list
                              _loadCurrentUser();

                              // Close the loading indicator dialog
                              Navigator.pop(context);
                            },
                            child: Text('Create Team'),
                          ),
                          const SizedBox(width: 8),
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
                            child: Text('Create Event'),
                          ),
                          const SizedBox(width: 8),
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
                            child: Text('Create Challenge'),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Style.sectionTitle('Teams'),
                  const SizedBox(height: 10),
                  // Display the current list of friends IDs

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
                                  Row(
                                    children: [
                                      // Add an edit icon here
                                      GestureDetector(
                                        onTap: () {
                                          // Handle the edit action, e.g., navigate to edit team screen
                                          print('Edit team tapped for team: $teamId');
                                        },
                                        child: const Icon(Icons.chat),
                                      ),
                                      const SizedBox(width: 8), // Add some spacing between the icon and text
                                      FutureBuilder<String>(
                                        future: _getTeamName(teamId),
                                        builder: (context, teamNameSnapshot) {
                                          if (teamNameSnapshot.connectionState == ConnectionState.done) {
                                            if (teamNameSnapshot.hasError || teamNameSnapshot.data == null) {
                                              return Text('Unknown Team');
                                            } else {
                                              return Padding(
                                                padding: const EdgeInsets.only(left: 16),
                                                child: Text(
                                                  '${teamNameSnapshot.data}',
                                                  style: const TextStyle(
                                                    fontSize: 25, // Adjust the font size as needed
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black, // Adjust the text color as needed

                                                  ),
                                                ),
                                              );
                                            }
                                          } else {
                                            return CircularProgressIndicator();
                                          }
                                        },
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 8),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey[300]!),
                                      borderRadius: BorderRadius.all(Radius.circular(8)),
                                    ),
                                    child: ExpansionTile(
                                      title: Text('Challenges'),
                                      children: [
                                        FutureBuilder<List<String>>(
                                          future: _getChallengeTitles(teamId),
                                          builder: (context, challengeTitlesSnapshot) {
                                            if (challengeTitlesSnapshot.connectionState ==
                                                ConnectionState.done) {
                                              if (challengeTitlesSnapshot.hasError ||
                                                  challengeTitlesSnapshot.data == null) {
                                                return Text('Error loading team challenges for $teamId');
                                              } else {
                                                // Display list of challenge titles
                                                return Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: challengeTitlesSnapshot.data!.map((challengeTitle) {
                                                    return Container(
                                                      decoration: BoxDecoration(
                                                        border: Border.all(color: Colors.grey[300]!),
                                                        borderRadius: BorderRadius.all(Radius.circular(8)),
                                                      ),
                                                      child: ExpansionTile(
                                                        title: Text('$challengeTitle'),
                                                        children: [
                                                          FutureBuilder<List<String>>(
                                                            future: _getTeamPlayersForChallenge(teamId, challengeTitle),
                                                            builder: (context, userSnapshot) {
                                                              if (userSnapshot.connectionState ==
                                                                  ConnectionState.done) {
                                                                if (userSnapshot.hasError ||
                                                                    userSnapshot.data == null) {
                                                                  return Text('Error loading team users for $teamId');
                                                                } else {
                                                                  // Display list of users for the current challenge
                                                                  return Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: userSnapshot.data!.map((user) {
                                                                      return Padding(
                                                                        padding: const EdgeInsets.only(left: 16),
                                                                        child: Column(
                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                          children: [
                                                                            Text(user),
                                                                            Divider(), // Line between users
                                                                          ],
                                                                        ),
                                                                      );
                                                                    }).toList(),
                                                                  );
                                                                }
                                                              } else {
                                                                return CircularProgressIndicator();
                                                              }
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  }).toList(),
                                                );
                                              }
                                            } else {
                                              return CircularProgressIndicator();
                                            }
                                          },
                                        ),
                                      ],
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
