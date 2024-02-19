import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateTeam extends StatefulWidget {
  const CreateTeam({Key? key}) : super(key: key);

  @override
  _CreateTeamState createState() => _CreateTeamState();
}

class _CreateTeamState extends State<CreateTeam> {
  late User? currentUser;
  List<String> friendsList = [];
  List<String> filteredFriendsList = [];
  List<String> selectedFriends = [];
  Map<String, String> friendNameMap = {};
  TextEditingController _searchController = TextEditingController();
  TextEditingController _teamNameController = TextEditingController();

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

          if (userData.containsKey('friends')) {
            setState(() {
              friendsList = List.from(userData['friends']);
              filteredFriendsList = List.from(friendsList);
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

  void _searchUsers(String query) {
    setState(() {
      filteredFriendsList = friendsList
          .where((friendEmail) => friendEmail.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _addUser(String friendEmail) async {
    try {
      String? friendName = await _getFriendName(friendEmail);

      if (friendName != null) {
        setState(() {
          if (!selectedFriends.contains(friendName)) {
            selectedFriends.add(friendName);
          }
          friendNameMap[friendEmail] = friendName;
        });
      }
    } catch (e) {
      print('Error adding user: $e');
    }
  }

  void _removeUser(String friendName) {
    setState(() {
      selectedFriends.remove(friendName);
    });
  }

  Future<void> _showTeamNameDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Type Team name"),
          content: TextField(
            controller: _teamNameController,
            decoration: InputDecoration(
              labelText: 'Team Name',
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {

                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pop();
                _createTeam(); // Create the team after closing the dialog
                // Display a pop-up message at the bottom for 2 seconds
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Your team has successfully been created in the "Team Page"'),
                    duration: Duration(seconds: 4),
                    behavior: SnackBarBehavior.floating, // Set behavior to floating
                  ),
                );



              },
              child: Text('Confirm Team'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
            ),
          ],
        );
      },
    );
  }

  void _createTeam() async {
    try {
      // Fetch the current user's email UID
      String currentUserEmailUid = currentUser != null ? currentUser!.email ?? "" : "";

      // Fetch the user document based on the current user's email UID
      QuerySnapshot currentUserQuerySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: currentUserEmailUid)
          .limit(1)
          .get();

      if (currentUserQuerySnapshot.docs.isNotEmpty) {
        DocumentSnapshot currentUserSnapshot = currentUserQuerySnapshot.docs.first;
        String currentUserName = currentUserSnapshot['name'];

        // Create a new document in the 'teams' collection
        DocumentReference teamRef = await FirebaseFirestore.instance.collection('teams').add({
          'team_name': _teamNameController.text, // Add the team name
          'users': [...selectedFriends, currentUserName], // Add the current user's name to the 'users' array
          // Add any additional information you want to store for the team
        });

        // Access the ID of the newly created team document
        String teamId = teamRef.id;

        // Update each user's 'team_ids' field with the new team ID if their name is present
        for (String friendName in selectedFriends) {
          // Fetch the user document based on the friend's name
          QuerySnapshot userQuerySnapshot = await FirebaseFirestore.instance
              .collection('users')
              .where('name', isEqualTo: friendName)
              .limit(1)
              .get();

          if (userQuerySnapshot.docs.isNotEmpty) {
            DocumentSnapshot userSnapshot = userQuerySnapshot.docs.first;
            String userId = userSnapshot.id;

            // Update the user's 'team_ids' field with the new team ID
            await FirebaseFirestore.instance.collection('users').doc(userId).update({
              'team_ids': FieldValue.arrayUnion([teamId]),
            });
          }
        }

        // Update the current user's 'team_ids' field with the new team ID
        await FirebaseFirestore.instance.collection('users').doc(currentUserSnapshot.id).update({
          'team_ids': FieldValue.arrayUnion([teamId]),
        });

        print('Team created successfully with ID: $teamId');

        // Clear the selectedFriends list after creating the team
        setState(() {
          selectedFriends.clear();
        });
      } else {
        print('User document not found for the current user');
      }
    } catch (e) {
      print('Error creating team: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (query) => _searchUsers(query),
              decoration: const InputDecoration(
                labelText: 'Search for friends',
                suffixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: filteredFriendsList.map((friendEmail) {
                return FutureBuilder(
                  future: _getFriendName(friendEmail),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasError || snapshot.data == null) {
                        return ListTile(
                          title: Text('Error loading friend name'),
                        );
                      } else {
                        // Display friend's name on the screen
                        return ListTile(
                          title: Row(
                            children: [
                              Expanded(
                                child: Text('${snapshot.data}'),
                              ),
                              ElevatedButton(
                                onPressed: () => _addUser(friendEmail),
                                child: Text(
                                  selectedFriends.contains(snapshot.data) ? 'Added' : 'Add',
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: selectedFriends.contains(snapshot.data)
                                      ? Colors.grey
                                      : Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    } else {
                      // Display loading indicator while fetching data
                      return ListTile(
                        title: CircularProgressIndicator(),
                      );
                    }
                  },
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 20),
          Center(
            child: selectedFriends.isNotEmpty
                ? ElevatedButton(
              onPressed: _showTeamNameDialog,
              child: Text('Create Team'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
            )
                : SizedBox.shrink(),
          ),
          SizedBox(height: 20),
          Text('Selected Friends:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Wrap(
            alignment: WrapAlignment.center,
            children: selectedFriends.map((friendName) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Stack(
                  children: [
                    Chip(
                      label: Text(friendName),
                      backgroundColor: Colors.grey,
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => _removeUser(friendName),
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.red,
                          child: Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
