import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileScreen extends StatefulWidget {
  final String user;

  const UserProfileScreen(this.user, {Key? key}) : super(key: key);

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late String username; // Set the default name
  late String userEmail = ''; // Store user email
  int totalPoints = 1000;
  int totalStreaks = 5;
  String profilePictureUrl = 'https://csncollision.com/wp-content/uploads/2019/10/placeholder-circle.png';

  final TextEditingController _nameController = TextEditingController();

  bool _isEditing = false;
  late User? currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      String? currentUserName = widget.user;
      if (currentUserName != null) {
        setState(() {
          username = currentUserName;
          _nameController.text = username;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.lightBlue,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
                if (_isEditing) {
                  _nameController.text = username;
                }
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(profilePictureUrl),
                backgroundColor: Colors.red,
              ),
              const SizedBox(height: 20),
              _isEditing
                  ? TextFormField(
                controller: _nameController,
                style: const TextStyle(
                    fontSize: 30, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  hintText: 'Enter your name',
                  labelText: 'Name',
                ),
              )
                  : Text(
                username,
                style: const TextStyle(
                    fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                userEmail,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 10),
              FutureBuilder<int>(
                future: getGivingPoints(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator(); // While waiting for the result, show a loading indicator
                  } else if (snapshot.hasData) {
                    int totalGivingPoints = snapshot.data!;
                    return Column(
                      children: [
                        Text(
                          'Coach Points: $totalGivingPoints',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return Text('Unknown error occurred');
                  }
                },
              ),
              FutureBuilder<int>(
                future: getTotalPoints(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator(); // While waiting for the result, show a loading indicator
                  } else if (snapshot.hasData) {
                    int totalPoints = snapshot.data!;
                    return Column(
                      children: [
                        Text(
                          'Player Points: $totalPoints',
                          style: const TextStyle(fontSize: 18),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                // Add your logic for the "Activities this Month" button here
                              },
                              child: Text('Activities this Month'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                // Add your logic for the "Activities History" button here
                              },
                              child: Text('Activities History'),
                            ),
                          ],
                        ),
                      ],
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return Text('Unknown error occurred');
                  }
                },
              ),

              const SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Wellness Distribution',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  for (final streak in streaks)
                    Row(
                      children: [
                        Image.asset(streak['icon'], width: 40, height: 40),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              streak['name'],
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5),
                            FutureBuilder<int>(
                              future: getWellnessPoints(
                                  streak['name'].toString().toLowerCase()),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return CircularProgressIndicator();
                                } else if (snapshot.hasData) {
                                  int completionCount = snapshot.data!;
                                  return Text(
                                    'Completion Count: $completionCount',
                                    style: const TextStyle(fontSize: 14),
                                  );
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else {
                                  return Text('Unknown error occurred');
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 30),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  ' Friends:',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }


  Future<int> getGivingPoints() async {
    int totalWellnessPoints = 0;

    try {
      String? currentUserName = widget.user;
      if (currentUserName != null) {
        // Fetch all challenge documents
        QuerySnapshot challengeSnapshot =
        await FirebaseFirestore.instance.collection('challenges').get();

        // Iterate through each challenge document
        for (DocumentSnapshot challengeDoc in challengeSnapshot.docs) {
          Map<String, dynamic> challengeData =
          challengeDoc.data() as Map<String, dynamic>;

          // Iterate through each key-value pair in challengeData
          challengeData.forEach((key, value) {
            // Check if the key ends with '_stats'
            if (key.endsWith('_stats')) {
              print('User stats found in challenge data for field: $key');

              // Get the user stats directly
              List<dynamic>? userStats = value as List<dynamic>?;

              // Count the completions for the current user
              if (userStats != null) {
                for (var data in userStats) {
                  if (data is Map<String, dynamic> &&
                      data.containsKey('confirmed_completion') &&
                      data.containsKey('date')) {
                    List<dynamic>? confirmedCompletions = data['confirmed_completion'];
                    if (confirmedCompletions != null) {
                      for (var index in confirmedCompletions) {
                        if (index == currentUserName) {
                          totalWellnessPoints++;
                        }
                      }
                    }
                  }
                }
              }
            }
          });
        }
      }
    } catch (e) {
      print('Error calculating total wellness points: $e');
    }

    print('Total Wellness Points: $totalWellnessPoints');
    return totalWellnessPoints;
  }



  Future<int> getTotalPoints() async {
    int totalWellnessPoints = 0;

    try {
      String? currentUserName = widget.user;
      if (currentUserName != null) {
        // Fetch all challenge documents
        QuerySnapshot challengeSnapshot = await FirebaseFirestore.instance
            .collection('challenges')
            .get();

        // Iterate through each challenge document
        for (DocumentSnapshot challengeDoc in challengeSnapshot.docs) {
          Map<String, dynamic> challengeData = challengeDoc.data() as Map<String, dynamic>;

          // Iterate through each category field
          for (String key in challengeData.keys) {
            if (key.endsWith('Category') && challengeData[key] == true) {
              String category = key.substring(0, key.length - 8); // Remove 'Category' suffix

              // Fetch user stats path
              String userStatsPath = currentUserName + '_stats';

              // Check if the user's stats exist within the challenge data
              if (challengeData.containsKey(userStatsPath)) {
                print('User stats found in challenge data');

                // Get the user stats directly
                List<dynamic>? userStats = challengeData[userStatsPath];

                // Set to store encountered date fields
                Set<String> encounteredDateFields = {};

                // Count the completions for the current user
                if (userStats != null) {
                  for (var data in userStats) {
                    if (data is Map<String, dynamic> &&
                        data.containsKey('confirmed_completion') &&
                        data.containsKey('date')) {
                      String? dateField = data['date'];
                      if (dateField != null && !encounteredDateFields.contains(dateField)) {
                        totalWellnessPoints++;
                        encounteredDateFields.add(dateField); // Add the current date field to the set
                      }
                    }
                  }
                }
              } else {
                print('User stats not found in challenge data');
              }
            }
          }
        }
      }
    } catch (e) {
      print('Error calculating total wellness points: $e');
    }

    print('Total Wellness Points: $totalWellnessPoints');
    return totalWellnessPoints;
  }

  // Function to calculate wellness points
  Future<int> getWellnessPoints(String category) async {
    int wellnessPoints = 0;
    category = category.toLowerCase();
    try {
      String? currentUserName = widget.user;
      if (currentUserName != null) {
        // Fetch all challenge documents
        QuerySnapshot challengeSnapshot = await FirebaseFirestore.instance
            .collection('challenges')
            .get();

        // Iterate through each challenge document
        for (DocumentSnapshot challengeDoc in challengeSnapshot.docs) {
          Map<String, dynamic> challengeData = challengeDoc.data() as Map<String, dynamic>;

          // Check if the category field is true
          if (challengeData['${category}Category'] == true) {
            print('Category ${category} is true in challenge document: ${challengeDoc.id}');

            // Construct the path for the user's stats
            String userStatsPath = currentUserName + '_stats';
            print('User stats path: $userStatsPath');

            // Check if the user's stats exist within the challenge data
            if (challengeData.containsKey(userStatsPath)) {
              print('User stats found in challenge data');

              // Get the user stats directly
              List<dynamic>? userStats = challengeData[userStatsPath];

              // Set to store encountered date fields
              Set<String> encounteredDateFields = {};

              // Count the completions for the current user
              if (userStats != null) {
                for (var data in userStats) {
                  if (data is Map<String, dynamic> &&
                      data.containsKey('confirmed_completion') &&
                      data.containsKey('date')) {
                    String? dateField = data['date'];
                    if (dateField != null && !encounteredDateFields.contains(dateField)) {
                      wellnessPoints++;
                      encounteredDateFields.add(dateField); // Add the current date field to the set
                    }
                  }
                }
              }

            } else {
              print('User stats not found in challenge data');
            }

          } else {
            print('Category ${category} is not true in challenge document: ${challengeDoc.id}');
          }
        }
      }
    } catch (e) {
      print('Error calculating wellness points: $e');
    }
    print('Wellness Points: $wellnessPoints');
    return wellnessPoints;
  }
}

final List<Map<String, dynamic>> streaks = [
  {'name': 'Emotional', 'icon': 'assets/images/Emotional-mini.png'},
  {'name': 'Environmental', 'icon': 'assets/images/Environmental-mini.png'},
  {'name': 'Financial', 'icon': 'assets/images/Financial-mini.png'},
  {'name': 'Intellectual', 'icon': 'assets/images/Intellectual-mini.png'},
  {'name': 'Occupational', 'icon': 'assets/images/Occupational-mini.png'},
  {'name': 'Physical', 'icon': 'assets/images/Physical-mini.png'},
  {'name': 'Social', 'icon': 'assets/images/Social-mini.png'},
  {'name': 'Spiritual', 'icon': 'assets/images/Spiritual-mini.png'},
];
