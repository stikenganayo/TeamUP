import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SelectionScreen extends StatefulWidget {
  const SelectionScreen({Key? key}) : super(key: key);

  @override
  _SelectionScreenState createState() => _SelectionScreenState();
}

class _SelectionScreenState extends State<SelectionScreen> {
  late User? currentUser;
  List<String> friendsList = [];
  List<String> filteredFriendsList = [];
  List<String> selectedFriends = [];
  Map<String, String> friendNameMap = {};
  List<String> teamIds = [];
  List<String> selectedTeams = [];
  Map<String, String> teamNameMap = {};
  TextEditingController _searchController = TextEditingController();
  Map<String, dynamic> userData = {}; // Declare userData at the class level

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
          print(userData['name']);
          if (userData.containsKey('friends')) {
            setState(() {
              friendsList = List.from(userData['friends']);
              filteredFriendsList = List.from(friendsList);
            });

            print('Friends List: $friendsList');
          } else {
            print('Friends field not found in user document');
          }

          if (userData.containsKey('team_ids')) {
            setState(() {
              teamIds = List.from(userData['team_ids']);
            });
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

  Future<String?> _getFriendName(String friendEmail) async {
    try {
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
            print('Friend UID: ${friendSnapshot.id}');
            return friendData['name'];
          }
        }
      }
    } catch (e) {
      print('Error loading friend document: $e');
    }

    return null;
  }

  Future<String?> _getTeamName(String teamId) async {
    try {
      DocumentSnapshot teamSnapshot = await FirebaseFirestore.instance
          .collection('teams')
          .doc(teamId)
          .get();

      if (teamSnapshot.exists) {
        Map<String, dynamic> teamData = teamSnapshot.data() as Map<String, dynamic>;

        if (teamData.containsKey('team_name')) {
          return teamData['team_name'];
        }
      }
    } catch (e) {
      print('Error loading team document: $e');
    }

    return null;
  }

  void _searchUsers(String query) {
    setState(() {
      filteredFriendsList = friendsList
          .where((friendEmail) => friendEmail.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _toggleUser(String friendEmail) async {
    try {
      String? friendName = await _getFriendName(friendEmail);

      if (friendName != null) {
        setState(() {
          if (selectedFriends.contains(friendName)) {
            selectedFriends.remove(friendName);
          } else {
            selectedFriends.add(friendName);
          }
          friendNameMap[friendEmail] = friendName;
        });
      }
    } catch (e) {
      print('Error toggling user: $e');
    }
  }

  void _removeUser(String friendName) {
    setState(() {
      selectedFriends.remove(friendName);
    });
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

  void _searchTeams(String query) {
    setState(() {
      // Filter teams based on the team name
      teamIds = teamIds
          .where((teamId) => teamNameMap.containsKey(teamId) && teamNameMap[teamId]!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _toggleTeam(String teamId) async {
    try {
      String? teamName = await _getTeamName(teamId);

      if (teamName != null) {
        setState(() {
          if (selectedTeams.contains(teamName)) {
            selectedTeams.remove(teamName);
          } else {
            selectedTeams.add(teamName);
          }
          teamNameMap[teamId] = teamName;
        });
      }
    } catch (e) {
      print('Error toggling team: $e');
    }
  }

  void _removeTeam(String teamName) {
    setState(() {
      selectedTeams.remove(teamName);
    });
  }

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose where to post!'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Teams Section Title
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Teams:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            FutureBuilder<List<String>>(
              future: _getTeamIds(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError || snapshot.data == null) {
                    return ListTile(
                      title: Text('Error loading team IDs'),
                    );
                  } else {
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
                              ),
                              child: ListTile(
                                title: FutureBuilder<String?>(
                                  future: _getTeamName(teamId),
                                  builder: (context, teamNameSnapshot) {
                                    if (teamNameSnapshot.connectionState ==
                                        ConnectionState.done) {
                                      if (teamNameSnapshot.hasError ||
                                          teamNameSnapshot.data == null) {
                                        return ListTile(
                                          title: Text('Error loading team name for $teamId'),
                                        );
                                      } else {
                                        return Text('${teamNameSnapshot.data}');
                                      }
                                    } else {
                                      return CircularProgressIndicator();
                                    }
                                  },
                                ),
                                onTap: () {
                                  _toggleTeam(teamId);
                                },
                                trailing: Checkbox(
                                  value: selectedTeams.contains(teamNameMap[teamId]),
                                  onChanged: (value) {
                                    _toggleTeam(teamId);
                                  },
                                  activeColor: Colors.blue,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        );
                      }).toList(),
                    );
                  }
                } else {
                  return ListTile(
                    title: CircularProgressIndicator(),
                  );
                }
              },
            ),

            // Friends Section
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Friends:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                onChanged: (query) {
                  _searchUsers(query);
                  _searchTeams(query);
                },
                decoration: const InputDecoration(
                  labelText: 'Search for friends or teams',
                  suffixIcon: Icon(Icons.search),
                ),
              ),
            ),
            ListView(
              shrinkWrap: true,
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
                        return ListTile(
                          title: Row(
                            children: [
                              Expanded(
                                child: Text('${snapshot.data}'),
                              ),
                              Checkbox(
                                value: selectedFriends.contains(snapshot.data),
                                onChanged: (value) => _toggleUser(friendEmail),
                                activeColor: Colors.blue,
                              ),
                            ],
                          ),
                        );
                      }
                    } else {
                      return ListTile(
                        title: CircularProgressIndicator(),
                      );
                    }
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, {'friends': selectedFriends, 'teams': selectedTeams});
                },
                child: Text('Post Request'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
              ),
            ),

            SizedBox(height: 20),

            Text('Selected Friends and Teams:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Wrap(
              alignment: WrapAlignment.center,
              children: [
                ...selectedFriends.map((friendName) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Chip(
                      label: Text(friendName),
                      onDeleted: () => _removeUser(friendName),
                      backgroundColor: Colors.grey,
                    ),
                  );
                }),
                ...selectedTeams.map((teamName) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Chip(
                      label: Text(teamName),
                      onDeleted: () => _removeTeam(teamName),
                      backgroundColor: Colors.blue,
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
