import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:snapchat_ui_clone/screens/prebuilt_activity_template_screen.dart';
import 'package:snapchat_ui_clone/screens/select_teams_screen.dart';
import 'package:snapchat_ui_clone/screens/selection_screen.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart'; // Import the intl package for date formatting


class CreateChallenge extends StatefulWidget {
  const CreateChallenge({Key? key}) : super(key: key);

  @override
  _CreateChallengeState createState() => _CreateChallengeState();
}

class _CreateChallengeState extends State<CreateChallenge> {
  List<ChallengeData> challengeDataList = [
    ChallengeData(challengeTitle: "", controller: TextEditingController())
  ];

  // String currentDate = DateFormat("MMMM dd, yyyy").format(DateTime.now());
  DateTime startDate = DateTime.now().toLocal();


  List<String> selectedFriends = [];
  List<String> selectedTeams = [];

  bool showFrequencyDropdowns = false;
  bool showGoalField = false;
  bool showUnitsDropdown = false;
  int selectedNumber = 1;
  String selectedTimeUnit = "Per Day";
  String selectedChallengeType = "CheckBox";
  String selectedGoal = "times";
  bool enableUserTyping = false;
  bool communityChallengePost = false;
  bool emotionalCategory = false;
  bool environmentalCategory = false;
  bool financialCategory = false;
  bool intellectualCategory = false;
  bool occupationalCategory = false;
  bool physicalCategory = false;
  bool socialCategory = false;
  bool spiritualCategory = false;

  bool isRecurringEvent = false;
  List<String> selectedDays = [];
  int selectedValue = 0;
  bool _showCircularSlider = false;


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
  String dropdownValue = 'Challenge everyone including you';


  late List<InputFieldData> inputFieldsDataList;

  bool areFieldsFilled() {
    return challengeDataList.isNotEmpty &&
        challengeDataList.every((data) => data.challengeTitle.isNotEmpty);
  }


  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime pickedDate = (await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    ))!;
    if (pickedDate != null && pickedDate != startDate) {
      setState(() {
        startDate = pickedDate;
      });
    }
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
                padding: const EdgeInsets.all(4.0),
                child: Column(
                  children: <Widget>[

                    const SizedBox(height: 20),
                    Column(
                      children: challengeDataList
                          .map((data) => _buildChallengeRow(data))
                          .toList(),
                    ),
                    const SizedBox(height: 20),
                    const SizedBox(height: 20),
// Show checkboxes for recurring events
                    const SizedBox(height: 20),
// Show checkboxes for recurring events

                    Row(
                      children: <Widget>[
                        TextButton(
                          onPressed: () => _selectStartDate(context),
                          child: const Text(
                            'Select Start Date',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Text(
                          DateFormat('MMMM dd yyyy').format(startDate),
                          style: TextStyle(fontSize: 16),
                        ),

                      ],
                    ),

                    const SizedBox(height: 20),
                    Text(
                      'Select Challenge Length',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '${selectedValue == 0 ? "Infinity" : selectedValue.toStringAsFixed(2)} Days', // Display selectedValue or "Infinite" if selectedValue is 0
                      style: TextStyle(fontSize: 16),
                    ),

                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                int newValue = selectedValue;
                                return AlertDialog(
                                  title: Text("Type in challenge length"),
                                  content: TextFormField(
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      newValue = int.tryParse(value) ?? selectedValue;
                                    },
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text('Cancel'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: Text('Confirm'),
                                      onPressed: () {
                                        setState(() {
                                          selectedValue = newValue;
                                        });
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Text(
                            'Insert Number',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              selectedValue = double.infinity as int;
                            });
                          },
                          child: Text(
                            'Set as Infinite',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
// Show checkboxes for recurring events
                    TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return StatefulBuilder(
                              builder: (BuildContext context, setState) {
                                return AlertDialog(
                                  title: Text('Select Value'),
                                  content: SizedBox(
                                    height: 220, // Adjust height as needed
                                    child: CircularSlider(
                                      onClose: (value) {
                                        setState(() {
                                          selectedValue = value as int; // Update the value in the parent widget
                                        });
                                      },
                                    ),
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        setState(() {}); // Refresh the screen
                                      },
                                      child: Text('Close'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        );
                      },
                      child: Text('Use Circular slider to select challenge length'),
                    ),





                    DropdownButton<String>(
                      value: dropdownValue,
                      onChanged: (String? newValue) {
                        setState(() {
                          dropdownValue = newValue!;
                          // Add logic to handle different dropdown options here
                        });
                      },
                      items: <String>[
                        'Challenge everyone including you',
                        'Challenge yourself - get your teammates to verify',
                        'Challenge your teammates - you verify',
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: emotionalCategory,
                          onChanged: (value) {
                            setState(() {
                              emotionalCategory = value!;
                            });
                          },
                        ),
                        const SizedBox(width: 10),
                        Image.asset(
                          'assets/images/Emotional-mini.png',
                          width: 40,
                          height: 40,
                        ),
                        const SizedBox(width: 10),
                        const Text('Emotional'),
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: environmentalCategory,
                          onChanged: (value) {
                            setState(() {
                              environmentalCategory = value!;
                            });
                          },
                        ),
                        const SizedBox(width: 10),
                        Image.asset(
                          'assets/images/Environmental-mini.png',
                          width: 40,
                          height: 40,
                        ),
                        const SizedBox(width: 10),
                        const Text('Environmental'),
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: financialCategory,
                          onChanged: (value) {
                            setState(() {
                              financialCategory = value!;
                            });
                          },
                        ),
                        const SizedBox(width: 10),
                        Image.asset(
                          'assets/images/Financial-mini.png',
                          width: 40,
                          height: 40,
                        ),
                        const SizedBox(width: 10),
                        const Text('Financial'),
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: intellectualCategory,
                          onChanged: (value) {
                            setState(() {
                              intellectualCategory = value!;
                            });
                          },
                        ),
                        const SizedBox(width: 10),
                        Image.asset(
                          'assets/images/Intellectual-mini.png',
                          width: 40,
                          height: 40,
                        ),
                        const SizedBox(width: 10),
                        const Text('Intellectual'),
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: occupationalCategory,
                          onChanged: (value) {
                            setState(() {
                              occupationalCategory = value!;
                            });
                          },
                        ),
                        const SizedBox(width: 10),
                        Image.asset(
                          'assets/images/Occupational-mini.png',
                          width: 40,
                          height: 40,
                        ),
                        const SizedBox(width: 10),
                        const Text('Occupational'),
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: physicalCategory,
                          onChanged: (value) {
                            setState(() {
                              physicalCategory = value!;
                            });
                          },
                        ),
                        const SizedBox(width: 10),
                        Image.asset(
                          'assets/images/Physical-mini.png',
                          width: 40,
                          height: 40,
                        ),
                        const SizedBox(width: 10),
                        const Text('Physical'),
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: socialCategory,
                          onChanged: (value) {
                            setState(() {
                              socialCategory = value!;
                            });
                          },
                        ),
                        const SizedBox(width: 10),
                        Image.asset(
                          'assets/images/Social-mini.png',
                          width: 40,
                          height: 40,
                        ),
                        const SizedBox(width: 10),
                        const Text('Social'),
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: spiritualCategory,
                          onChanged: (value) {
                            setState(() {
                              spiritualCategory = value!;
                            });
                          },
                        ),
                        const SizedBox(width: 10),
                        Image.asset(
                          'assets/images/Spiritual-mini.png',
                          width: 40,
                          height: 40,
                        ),
                        const SizedBox(width: 10),
                        const Text('Spiritual'),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          // Toggle the enableUserTyping state
                          enableUserTyping = !enableUserTyping;
                        });
                      },
                      child: Text(enableUserTyping ? "Disable user typing" : "Enable user typing"),
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
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Checkbox(
                          value: communityChallengePost,
                          onChanged: (value) {
                            setState(() {
                              communityChallengePost = value!;
                            });
                          },
                        ),
                        const SizedBox(width: 10),
                        const Text('Post to Community Challenges'),
                      ],
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
              onChanged: (value) {
                setState(() {
                  // Update the challengeTitle in the current data
                  data.challengeTitle = value;
                  // Check if the title is not already in the list, then add it
                  if (!challengeDataList.any((element) => element.challengeTitle == value)) {
                    // If not present, add it to the beginning of the list
                    challengeDataList.insert(0, ChallengeData(challengeTitle: value, controller: TextEditingController()));
                  }
                });
              },
              decoration: InputDecoration(
                hintText: 'Challenge Title',
              ),
              initialValue: data.challengeTitle,
            ),
          ),
        Row(
          children: [
            const Icon(Icons.check_box_outline_blank),
            const SizedBox(width: 10),
            Flexible(
              child: TextFormField(
                onChanged: (value) {
                  setState(() {
                    // Update the challengeTitle in the current data
                    data.challengeTitle = value;
                  });
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
                  // If there is a challengeTitle, add it to the list before adding the new ChallengeData
                  if (data.challengeTitle.isNotEmpty) {
                    challengeDataList.add(ChallengeData(challengeTitle: data.challengeTitle, controller: TextEditingController()));
                  }
                  // Add the new ChallengeData to the list
                  challengeDataList.add(ChallengeData(challengeTitle: "", controller: TextEditingController()));
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

          String formattedStartDate = DateFormat('MMMM dd yyyy').format(startDate);


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
            'userTyping' : enableUserTyping,
            'challengeType' : dropdownValue,
            'communityChallenge' : communityChallengePost,
            'emotionalCategory' : emotionalCategory,
          'environmentalCategory' : environmentalCategory,
          'financialCategory' : financialCategory,
          'intellectualCategory' : intellectualCategory,
          'occupationalCategory' : occupationalCategory,
          'physicalCategory' : physicalCategory,
          'socialCategory' : socialCategory,
          'spiritualCategory' : spiritualCategory,
          'challengeLength' : selectedValue,
            'startDate': formattedStartDate,
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
                    'userTyping' : enableUserTyping,
                    'challengeLength' : selectedValue,
                    'startDate': formattedStartDate,
                    // Add the list of players to the team challenge
                  }
                ]),
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

                  // Determine the status based on whether the user is the host
                  String status = (userData['name'] == teamMember) ? 'host' : 'pending';

                  // Update the user's document with the challenge data
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .update({
                    'team_challenges': FieldValue.arrayUnion([
                      {
                        'status': status,
                        'challengeDocRef': challengeDocRef.id,
                        'creatorUserId': userData['name'], // Use the user's name as creatorUserId
                        'template_name': challengeDataList
                            .map((data) => {'challengeTitle': data.challengeTitle})
                            .toList(),
                        'players': players,
                        'userTyping' : enableUserTyping,
                        'challengeLength' : selectedValue,
                        'startDate': formattedStartDate,
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

Future<void> deletePostedChallenge(DocumentReference challengeDocRef) async {
  try {
    // Get the challenge data before deleting
    DocumentSnapshot challengeSnapshot = await challengeDocRef.get();
    Map<String, dynamic> challengeData =
    challengeSnapshot.data() as Map<String, dynamic>;

    // Delete the challenge document
    await challengeDocRef.delete();
    print('Challenge deleted successfully');

    // Iterate through selectedTeams and update teams' challenges and users
    for (String teamName in challengeData['selectedTeams']) {
      // Find team's ID in the 'teams' collection
      QuerySnapshot teamQuerySnapshot = await FirebaseFirestore.instance
          .collection('teams')
          .where('team_name', isEqualTo: teamName)
          .limit(1)
          .get();

      if (teamQuerySnapshot.docs.isNotEmpty) {
        DocumentSnapshot teamSnapshot = teamQuerySnapshot.docs.first;
        String teamId = teamSnapshot.id;

        // Update the team's document by removing the challenge data
        await FirebaseFirestore.instance
            .collection('teams')
            .doc(teamId)
            .update({
          'team_challenges': FieldValue.arrayRemove([
            {
              'status': 'pending',
              'challengeDocRef': challengeDocRef.id,
            }
          ]),
        });

        // Iterate through each user in the team and update their 'team_events'
        for (String teamMember in teamSnapshot['users']) {
          // Find the user's ID in the 'users' collection
          QuerySnapshot userQuerySnapshot = await FirebaseFirestore.instance
              .collection('users')
              .where('name', isEqualTo: teamMember)
              .limit(1)
              .get();

          if (userQuerySnapshot.docs.isNotEmpty) {
            DocumentSnapshot userSnapshot = userQuerySnapshot.docs.first;
            String userId = userSnapshot.id;

            // Update the user's document by removing the challenge data
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .update({
              'team_challenges': FieldValue.arrayRemove([
                {
                  'status': (userSnapshot['name'] == teamMember)
                      ? 'host'
                      : 'pending',
                  'challengeDocRef': challengeDocRef.id,
                }
              ])
            });
          }
        }
      }
    }

    print('Challenge deleted from all relevant locations');
  } catch (e, stackTrace) {
    print('Error deleting challenge: $e');
    print('StackTrace: $stackTrace');
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


class CircularSlider extends StatefulWidget {
  final void Function(double) onClose;

  const CircularSlider({Key? key, required this.onClose}) : super(key: key);

  @override
  _CircularSliderState createState() => _CircularSliderState();
}

class _CircularSliderState extends State<CircularSlider> {
  double _startAngle = -math.pi / 2;
  double _endAngle = -math.pi / 2;
  double _value = 0.0;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 200,
            height: 200,
            child: GestureDetector(
              onPanStart: (details) {
                RenderBox renderBox = context.findRenderObject() as RenderBox;
                Offset center = renderBox.localToGlobal(renderBox.size.center(Offset.zero));
                _startAngle = math.atan2(details.globalPosition.dy - center.dy, details.globalPosition.dx - center.dx);
              },
              onPanUpdate: (details) {
                RenderBox renderBox = context.findRenderObject() as RenderBox;
                Offset center = renderBox.localToGlobal(renderBox.size.center(Offset.zero));
                double newAngle = math.atan2(details.globalPosition.dy - center.dy, details.globalPosition.dx - center.dx);
                double angleDiff = newAngle - _startAngle;

                // Calculate the new value
                double newValue = _value + angleDiff;

                // Check if the new value will be negative
                if (_value <= 0 && newValue < 0) {
                  return; // Prevent going into negative values
                }

                // Normalize the angle between 0 and 2*pi
                double normalizedAngle = (newAngle - _startAngle + 2 * math.pi) % (2 * math.pi);

                setState(() {
                  _endAngle = newAngle;
                  if (angleDiff < -math.pi) {
                    angleDiff += 2 * math.pi;
                  } else if (angleDiff > math.pi) {
                    angleDiff -= 2 * math.pi;
                  }
                  _value += angleDiff;
                  _startAngle = newAngle;
                });
              },
              onPanEnd: (_) {
                widget.onClose(_value); // Call the onClose callback with the selected value
              },
              child: CustomPaint(
                painter: CircularSliderPainter(angle: _value),
              ),
            ),
          ),
          Positioned(
            top: 100,
            child: Text(
              'Value: ${(_value / (2 * math.pi) * 100).toStringAsFixed(0)}',
              style: TextStyle(fontSize: 24.0),
            ),
          ),
        ],
      ),
    );
  }
}



class CircularSliderPainter extends CustomPainter {
  final double angle;

  CircularSliderPainter({required this.angle});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint backgroundPaint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 10.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final Paint progressPaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 10.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final double radius = size.width / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);

    canvas.drawCircle(center, radius, backgroundPaint);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      angle % (2 * math.pi),
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}