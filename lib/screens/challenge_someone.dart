import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_challenge_screen.dart';
import 'challenge_define.dart';

class ChallengeInputScreen extends StatefulWidget {
  @override
  _ChallengeInputScreenState createState() => _ChallengeInputScreenState();
}

class _ChallengeInputScreenState extends State<ChallengeInputScreen> {
  List<ChallengeListItem> challengeList = [
    ChallengeListItem(
      challengeTitle: "",
      titleController: TextEditingController(),
    ),
  ];
  TextEditingController challengeHeaderController = TextEditingController();
  TextEditingController challengeDescriptionController = TextEditingController();
  List<String> selectedTeams = [];
  List<String> availableTeams = [];
  List<String> selectedFriends = [];
  List<String> availableFriends = [];
  User? currentUser;
  bool challengeStranger = false; // Track whether the user wants to challenge a stranger

  @override
  void initState() {
    super.initState();
    _fetchTeams();
    _fetchFriends();
  }

  Future<void> _fetchTeams() async {
    try {
      QuerySnapshot teamsSnapshot = await FirebaseFirestore.instance.collection('teams').get();
      List<String> teams = teamsSnapshot.docs.map((doc) => doc['team_name'] as String).toList();
      setState(() {
        availableTeams = teams;
      });
    } catch (e) {
      print('Error fetching teams: $e');
    }
  }

  Future<void> _fetchFriends() async {
    try {
      String? userName = await _loadCurrentUserName();
      if (userName != null) {
        QuerySnapshot userQuerySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('name', isEqualTo: userName)
            .limit(1)
            .get();

        if (userQuerySnapshot.docs.isNotEmpty) {
          DocumentSnapshot userSnapshot = userQuerySnapshot.docs.first;
          Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;

          if (userData.containsKey('friends')) {
            List<dynamic> friends = userData['friends'];

            List<String> fetchedFriends = [];
            if (currentUser != null) {
              fetchedFriends.add(userName); // Add current user to the list
            }
            for (String friendEmail in friends) {
              QuerySnapshot friendQuerySnapshot = await FirebaseFirestore
                  .instance
                  .collection('users')
                  .where('email', isEqualTo: friendEmail)
                  .limit(1)
                  .get();

              if (friendQuerySnapshot.docs.isNotEmpty) {
                DocumentSnapshot friendSnapshot = friendQuerySnapshot.docs.first;
                Map<String, dynamic> friendData = friendSnapshot.data() as Map<String, dynamic>;

                if (friendData.containsKey('name')) {
                  String friendName = friendData['name'] as String;
                  if (friendName != userName) {
                    fetchedFriends.add(friendName);
                  }
                } else {
                  print('Name field not found for friend with email: $friendEmail');
                }
              } else {
                print('User document not found for friend with email: $friendEmail');
              }
            }

            setState(() {
              availableFriends = fetchedFriends;
            });
          } else {
            print('$userName has no friends.');
          }
        } else {
          print('User document not found for $userName');
        }
      } else {
        print('Current user name is null');
      }
    } catch (e) {
      print('Error loading user friends: $e');
    }
  }

  Future<String?> _loadCurrentUserName() async {
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

          if (userData.containsKey('name')) {
            String userName = userData['name'] as String;
            return userName;
          } else {
            print('Name field not found in user document');
          }
        } else {
          print('User document not found for the current user');
        }
      } catch (e) {
        print('Error loading user document: $e');
      }
    }
    return null;
  }

  Widget _buildChallengeListItem(ChallengeListItem item) {
    int index = challengeList.indexOf(item);
    bool hasMultipleItems = challengeList.length > 1;
    bool isChecked = item.challengeTitle.isNotEmpty; // Determine if the checkbox should be checked

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Checkbox to the left
            Checkbox(
              value: isChecked,
              onChanged: (bool? value) {
                setState(() {
                  item.challengeTitle = value == true ? item.challengeTitle : "";
                });
              },
            ),
            // TextFormField for challenge title
            Expanded(
              child: TextFormField(
                onChanged: (value) {
                  setState(() {
                    item.challengeTitle = value;
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'Checklist',
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                controller: item.titleController,
              ),
            ),
            // Add icon
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                setState(() {
                  if (item.challengeTitle.isNotEmpty) {
                    // Check if the entry already exists to prevent duplicates
                    bool entryExists = challengeList.any((d) => d.challengeTitle == item.challengeTitle);
                    if (!entryExists) {
                      challengeList.add(ChallengeListItem(
                        challengeTitle: item.challengeTitle,
                        titleController: TextEditingController(),
                      ));
                    }
                  }
                  // Always add a new blank entry
                  challengeList.add(ChallengeListItem(
                    challengeTitle: "",
                    titleController: TextEditingController(),
                  ));
                });
              },
            ),
            // Close icon
            if (hasMultipleItems)
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    if (index >= 0) {
                      challengeList.removeAt(index);
                    }
                  });
                },
              ),
          ],
        ),
        const SizedBox(height: 8.0),
      ],
    );
  }

  Widget _buildFriendSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Challenge Friends',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8.0,
          children: availableFriends.map((friend) {
            return FilterChip(
              label: Text(friend),
              selected: selectedFriends.contains(friend),
              onSelected: (isSelected) {
                setState(() {
                  if (isSelected) {
                    selectedFriends.add(friend);
                  } else {
                    selectedFriends.remove(friend);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTeamSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Challenge Previous Teams',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8.0,
          children: availableTeams.map((team) {
            return FilterChip(
              label: Text(team),
              selected: selectedTeams.contains(team),
              onSelected: (isSelected) {
                setState(() {
                  if (isSelected) {
                    selectedTeams.add(team);
                  } else {
                    selectedTeams.remove(team);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildChallengeOptions() {
    return Card(
      elevation: 4.0,
      color: Colors.grey[50],
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Challenge a Community Member',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Switch(
                  value: challengeStranger,
                  onChanged: (value) {
                    setState(() {
                      challengeStranger = value;
                      // Clear selections when switching to stranger option
                      if (challengeStranger) {
                        selectedFriends.clear();
                        selectedTeams.clear();
                      }
                    });
                  },
                ),
              ],
            ),
            if (!challengeStranger) ...[
              const SizedBox(height: 16.0),
              _buildFriendSelection(),
              const SizedBox(height: 16.0),
              _buildTeamSelection(),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Challenge Details'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Challenge Title and Description
          TextFormField(
            controller: challengeHeaderController,
            decoration: const InputDecoration(
              labelText: 'Challenge Title',
              border: OutlineInputBorder(),
              labelStyle: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8.0),
          TextFormField(
            controller: challengeDescriptionController,
            maxLines: 5, // Increase height for larger text area
            decoration: InputDecoration(
              labelText: 'Challenge Description',
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blueAccent, width: 2.0), // Custom border color and width
              ),
              filled: true,
              fillColor: Colors.grey[200], // Custom background color
              contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0), // Custom padding
            ),
          ),
          const SizedBox(height: 16.0),
          ...challengeList.map((item) => _buildChallengeListItem(item)).toList(),
          const SizedBox(height: 16.0),
          _buildChallengeOptions(), // Add the grouped challenge options here
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateChallenge(),
                ),
              );
            },
            child: Icon(Icons.add),
            heroTag: null, // Avoid conflicts with multiple FABs
          ),
          SizedBox(width: 16.0),
          FloatingActionButton(
            onPressed: () async {
              // Gather all data to pass to FrequencyScreen
              String challengeHeader = challengeHeaderController.text;
              String challengeDescription = challengeDescriptionController.text;
              List<String> challengeListTitles = challengeList.map((item) => item.challengeTitle).toList();
              List<String> challengeTeams = selectedTeams;
              List<String> challengeFriends = challengeStranger ? ['Community Member'] : selectedFriends;

              // Ensure the current user is at the top of the list
              if (currentUser != null) {
                String? currentUserName = await _loadCurrentUserName();
                if (currentUserName != null && !selectedFriends.contains(currentUserName)) {
                  challengeFriends.insert(0, currentUserName); // Add current user as the first friend
                }
              }

              // Print the data to console for verification
              print('Challenge Header: $challengeHeader');
              print('Challenge Description: $challengeDescription');
              print('Challenge List: $challengeListTitles');
              print('Challenge Teams: $challengeTeams');
              print('Challenge Friends: $challengeFriends');

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FrequencyScreen(
                    challengeHeader: challengeHeader,
                    challengeDescription: challengeDescription,
                    challengeListTitles: challengeListTitles,
                    challengeTeams: challengeTeams,
                    challengeFriends: challengeFriends,
                  ),
                ),
              );
            },
            child: Icon(Icons.navigate_next),
            heroTag: null, // Avoid conflicts with multiple FABs
          ),
        ],
      ),
    );
  }
}

class ChallengeListItem {
  String challengeTitle;
  TextEditingController titleController;

  ChallengeListItem({
    required this.challengeTitle,
    required this.titleController,
  });
}