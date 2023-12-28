import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:snapchat_ui_clone/screens/prebuilt_activity_template_screen.dart';
import 'package:snapchat_ui_clone/screens/select_teams_screen.dart';
import 'package:snapchat_ui_clone/screens/selection_screen.dart';

class CreateChallenge extends StatefulWidget {
  const CreateChallenge({Key? key}) : super(key: key);

  @override
  _CreateChallengeState createState() => _CreateChallengeState();
}

class _CreateChallengeState extends State<CreateChallenge> {
  List<ChallengeData> challengeDataList = [
    ChallengeData(challengeTitle: "", controller: TextEditingController())
  ];
  List<String> selectedFriends = [];
  List<String> selectedTeams = [];

  bool showFrequencyDropdowns = false;
  bool showGoalField = false;
  bool showUnitsDropdown = false;
  int selectedNumber = 1;
  String selectedTimeUnit = "Per Day";
  String selectedChallengeType = "CheckBox";
  String selectedGoal = "times";

  List<String> timeUnitOptions = [
    "Per Second",
    "Per Minute",
    "Per Hour",
    "Per Day",
    "Per Week",
    "Per Month",
    "Per Year",
  ];

  List<String> goalOptions = ["times", "seconds", "minutes", "hours", "days"];

  late List<InputFieldData> inputFieldsDataList;

  bool areFieldsFilled() {
    return challengeDataList.isNotEmpty &&
        challengeDataList.every((data) => data.challengeTitle.isNotEmpty);
  }

  @override
  void initState() {
    super.initState();
    inputFieldsDataList = List.generate(
      selectedNumber,
          (index) => InputFieldData(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create Challenges'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Customize Challenge'),
              Tab(text: 'Select Challenge Template'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    Column(
                      children: challengeDataList
                          .map((data) => _buildChallengeRow(data))
                          .toList(),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          showFrequencyDropdowns = !showFrequencyDropdowns;
                        });
                      },
                      child: Text(showFrequencyDropdowns
                          ? 'Remove Frequency'
                          : 'Set Frequency?'),
                    ),
                    if (showFrequencyDropdowns) const SizedBox(height: 10),
                    if (showFrequencyDropdowns) _buildFrequencySection(),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          showGoalField = !showGoalField;
                        });
                      },
                      child: Text(showGoalField ? 'Remove Goal' : 'Set a Goal'),
                    ),
                    if (showGoalField) const SizedBox(height: 10),
                    if (showGoalField) _buildGoalField(),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SelectTeamsScreen(),
                          ),
                        ).then((result) {
                          if (result != null &&
                              result is Map<String, dynamic>) {
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
                            });
                          }
                        });
                      },
                      child: const Text('Challenge who?'),
                    ),
                    const SizedBox(height: 20),
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
                                    (friendName) =>
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Chip(
                                        label: Text(friendName),
                                        backgroundColor: Colors.grey,
                                      ),
                                    ),
                              ),
                              ...selectedTeams.map(
                                    (teamName) =>
                                    Padding(
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
                      onPressed: areFieldsFilled()
                          ? () => postChallenge(context)
                          : null,
                      child: const Text('Post Challenge'),
                    ),
                  ],
                ),
              ),
            ),
            PrebuiltActivityTemplateScreen(),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengeRow(ChallengeData data) {
    int index = challengeDataList.indexOf(data);
    bool hasMultipleItems = challengeDataList.length > 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (index == 0 && hasMultipleItems)
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: TextFormField(
              style: TextStyle(fontSize: 16),
              onChanged: (value) {},
              decoration: InputDecoration(
                hintText: 'Challenge Title',
              ),
            ),
          ),
        Row(
          children: [
            const Icon(Icons.check_box_outline_blank),
            const SizedBox(width: 10),
            Flexible(
              child: TextFormField(
                onChanged: (value) {
                  data.challengeTitle = value;
                  setState(() {});
                },
                decoration: const InputDecoration(
                  hintText: 'Challenge',
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                controller: data.controller,
              ),
            ),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                setState(() {
                  challengeDataList.add(
                    ChallengeData(
                        challengeTitle: "",
                        controller: TextEditingController()),
                  );
                });
              },
            ),
            if (hasMultipleItems)
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    if (index >= 0) {
                      challengeDataList.removeAt(index);
                    }
                  });
                },
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildFrequencySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Set Frequency',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const SizedBox(width: 10),
            Flexible(
              child: DropdownButton<String>(
                value: selectedTimeUnit,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedTimeUnit = newValue;
                    });
                  }
                },
                items: timeUnitOptions.map<DropdownMenuItem<String>>(
                      (String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  },
                ).toList(),
                hint: Text('Select Time Unit'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildGoalField() {
    return Row(
      children: [
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Set a Goal',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        showUnitsDropdown = !showUnitsDropdown;
                      });
                    },
                    child: Text(showUnitsDropdown ? 'Remove Units' : 'Units'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Flexible(
                    child: TextFormField(
                      onChanged: (value) {
                        // Handle goal input
                        inputFieldsDataList[0].unit =
                            value; // Assuming you want to save the goal value in the 'unit' field of InputFieldData
                      },
                      decoration: const InputDecoration(
                        hintText: 'Enter a Goal',
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (showUnitsDropdown)
                    DropdownButton<String>(
                      value: selectedGoal,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedGoal = newValue;
                          });
                        }
                      },
                      items: goalOptions.map<DropdownMenuItem<String>>(
                            (String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        },
                      ).toList(),
                      hint: Text('Units'),
                    ),
                  const SizedBox(width: 10),
                  if (showFrequencyDropdowns)
                    Text(
                      selectedTimeUnit,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void postChallenge(BuildContext context) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        CollectionReference challengesCollection =
        FirebaseFirestore.instance.collection('challenges');

        // Fetch user data based on the provided email
        QuerySnapshot userQuerySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: currentUser.email)
            .limit(1)
            .get();

        if (userQuerySnapshot.docs.isNotEmpty) {
          DocumentSnapshot userSnapshot = userQuerySnapshot.docs.first;
          Map<String, dynamic> userData =
          userSnapshot.data() as Map<String, dynamic>;

          Map<String, dynamic> challengeData = {
            'CurrentUserEmail': currentUser.email,
            'CurrentUserName': userData['name'],
            // Store the user's name
            'challengeDataList': challengeDataList
                .map((data) => {'challengeTitle': data.challengeTitle})
                .toList(),
            'selectedFriends': selectedFriends,
            'selectedTeams': selectedTeams,
            'showFrequencyDropdowns': showFrequencyDropdowns,
            'selectedNumber': selectedNumber,
            'selectedTimeUnit': selectedTimeUnit,
            'showGoalField': showGoalField,
            'selectedUnit': selectedGoal,
            'showUnitsDropdown': showUnitsDropdown,
            'goalValue': inputFieldsDataList[0].unit,
            // Add this line to include the goal value
            'accepted': 0,
          };

          DocumentReference challengeDocRef =
          await challengesCollection.add(challengeData);

          print('Challenge Posted:');
          print('Selected Friends: $selectedFriends');
          print('Selected Teams: $selectedTeams');

          // Iterate through selectedTeams and update teams' challenges and users
          for (String teamName in selectedTeams) {
            // Find team's ID in the 'teams' collection
            QuerySnapshot teamQuerySnapshot = await FirebaseFirestore.instance
                .collection('teams')
                .where('team_name', isEqualTo: teamName)
                .limit(1)
                .get();

            if (teamQuerySnapshot.docs.isNotEmpty) {
              DocumentSnapshot teamSnapshot = teamQuerySnapshot.docs.first;
              String teamId = teamSnapshot.id;

              // Get the list of users in the selected team
              List<String> teamMembers =
              List<String>.from(teamSnapshot['users'] ?? []);

              // Include existing users in the 'players' field
              List<String> players = List.from(teamMembers);
              players.addAll(selectedFriends);

              // Update the team's document with the challenge data
              await FirebaseFirestore.instance
                  .collection('teams')
                  .doc(teamId)
                  .update({
                'team_challenges': FieldValue.arrayUnion([
                  {
                    'status': 'pending',
                    'challengeDocRef': challengeDocRef.id,
                    'creatorUserId': userData['name'],
                    // Store the user's name
                    'template_name': challengeDataList
                        .map((data) => {'challengeTitle': data.challengeTitle})
                        .toList(),
                    'players': players,
                    // Add the list of players to the team challenge
                  }
                ]),
              });

              // Iterate through each user and update their 'team_events'
              for (String teamMember in teamMembers) {
                // Find the user's ID in the 'users' collection
                QuerySnapshot userQuerySnapshot = await FirebaseFirestore
                    .instance
                    .collection('users')
                    .where('name', isEqualTo: teamMember)
                    .limit(1)
                    .get();

                if (userQuerySnapshot.docs.isNotEmpty) {
                  DocumentSnapshot userSnapshot = userQuerySnapshot.docs.first;
                  String userId = userSnapshot.id;

                  // Update the user's document with the challenge data
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .update({
                    'team_challenges': FieldValue.arrayUnion([
                      {
                        'status': 'pending',
                        'challengeDocRef': challengeDocRef.id,
                        'creatorUserId': currentUser.uid,
                        'template_name': challengeDataList
                            .map((data) =>
                        {
                          'challengeTitle': data.challengeTitle
                        })
                            .toList(),
                        // You might want to set the template name if applicable
                        'players': players,
                        // Add the list of players to the user's team challenge
                      }
                    ])
                  });
                }
              }
            }
          }

          Navigator.pop(context);
        } else {
          print('User document not found for the current user');
        }
      } else {
        print('Current User is null');
      }
    } catch (e, stackTrace) {
      print('Error posting challenge: $e');
      print('StackTrace: $stackTrace');
    }
  }
}
  class ChallengeData {
  String challengeTitle;
  TextEditingController controller;

  ChallengeData({required this.challengeTitle, required this.controller});
}

class InputFieldData {
  int numberOfFields = 1;
  String unit = "Second";
}
