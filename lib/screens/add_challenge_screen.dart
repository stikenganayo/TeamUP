import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CreateChallenge extends StatefulWidget {
  const CreateChallenge({Key? key}) : super(key: key);

  @override
  _CreateChallengeState createState() => _CreateChallengeState();
}

class _CreateChallengeState extends State<CreateChallenge> {
  List<ChallengeData> challengeDataList = [
    ChallengeData(challengeTitle: "", controller: TextEditingController())
  ];

  String selectedFrequency = "Once"; // Default value
  List<String> frequencyOptions = [
    "Once",
    "every 1 day",
    "every 2 days",
    "every 3 days",
    "every 4 days",
    "every 5 days",
    "every week",
    "every 2 weeks",
    // Add more options as needed
  ];

  List<String> selectedTeams = []; // List to store selected teams

  // Initialize a map to keep track of the checked states for each team's activities
  Map<String, List<bool>> _teamCheckedStates = {};

  Future<List<dynamic>> loadTeamData() async {
    String jsonDataFile = 'assets/images/data/team_data.json'; // Default to events_data.json

    final String jsonData = await rootBundle.loadString(jsonDataFile);
    final jsonDataMap = json.decode(jsonData);
    final challengeList = jsonDataMap['data'] as List<dynamic>;

    // Filter the challengeList based on the 'user' field ****** This is where it should automatically pull
    //in the user which is currently logged in
    final filteredChallengeList = challengeList.where((challenge) => challenge['user'] == 'whiskey').toList();
    print(filteredChallengeList);
    return filteredChallengeList;
  }

  bool areFieldsFilled() {
    return challengeDataList.isNotEmpty &&
        challengeDataList.every((data) => data.challengeTitle.isNotEmpty);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Activity Template!'),
      ),
      body: SingleChildScrollView(
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
              _buildFrequencySection(),
              const SizedBox(height: 20),
              _buildTeamSelection(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: areFieldsFilled() ? () => postChallenge() : null,
                child: Text('Post Activity'),
              ),
              const SizedBox(height: 20),
              // Display selected teams below the button
              _buildSelectedTeamsList(),
            ],
          ),
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
                hintText: 'Activity Title',
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
                  hintText: 'Activity',
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
                    ChallengeData(challengeTitle: "", controller: TextEditingController()),
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
        Container(
          alignment: Alignment.centerLeft,
          child: DropdownButton<String>(
            value: selectedFrequency,
            onChanged: (String? newValue) {
              if (newValue != null) { // Check if newValue is not null
                setState(() {
                  selectedFrequency = newValue;
                });
              }
            },
            items: frequencyOptions.map<DropdownMenuItem<String>>(
                  (String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              },
            ).toList(),
            hint: Text('Select Frequency'),
          ),
        ),
      ],
    );
  }

  Widget _buildTeamSelection() {
    return FutureBuilder<List<dynamic>>(
      future: loadTeamData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error loading data'));
        } else if (!snapshot.hasData) {
          return Center(child: Text('No data available'));
        }

        final challengeList = snapshot.data!;
        print(challengeList);
        print('Team Checked States:');
        _teamCheckedStates.forEach((teamName, checkedStates) {
          print('Team Name: $teamName');
          print('Checked States: $checkedStates');
        });

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Team',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            ...challengeList.map<Widget>((challenge) {
              final challengeType = challenge['user'];
              final subChallengeTypes = challenge['UserTeams'] as Map<String, dynamic>;

              return Column(
                children: subChallengeTypes.entries.map<Widget>((entry) {
                  final subChallengeData = entry.value as Map<String, dynamic>;
                  final TeamName = subChallengeData['teamname'] as String?;
                  final activities = subChallengeData['teammates'] as List<dynamic>;

                  // Initialize the checked state for this team's activities
                  _teamCheckedStates.putIfAbsent(
                    TeamName!,
                        () => List.generate(activities.length, (index) => false),
                  );

                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ExpansionTile(
                      leading: Checkbox(
                        value: _teamCheckedStates[TeamName!]!.contains(true),
                        onChanged: (bool? newValue) {
                          setState(() {
                            _teamCheckedStates[TeamName!] = List.generate(activities.length, (index) => newValue ?? false);
                          });
                        },
                      ),
                      title: Text(TeamName ?? 'Unknown Team'),
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: activities.length,
                          itemBuilder: (context, activityIndex) {
                            final activity = activities[activityIndex];
                            final activityName = activity['name'] as String;

                            return CheckboxListTile(
                              title: Text(activityName),
                              value: _teamCheckedStates[TeamName!]![activityIndex],
                              onChanged: (bool? newValue) {
                                setState(() {
                                  _teamCheckedStates[TeamName!]![activityIndex] = newValue ?? false;
                                });
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            }).toList(),
          ],
        );
      },
    );
  }

  Widget _buildSelectedTeamsList() {
    return selectedTeams.isNotEmpty
        ? Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selected Teams:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          itemCount: selectedTeams.length,
          itemBuilder: (context, index) {
            return Text(selectedTeams[index]);
          },
        ),
      ],
    )
        : Container();
  }

  void postChallenge() {
    // Implement your logic to post the challenge here
    print('Challenges Posted: ${challengeDataList.map((data) => data.challengeTitle).toList()}');
    print('Selected Frequency: $selectedFrequency');
    print('Selected Teams: $selectedTeams');
  }
}

class ChallengeData {
  String challengeTitle;
  TextEditingController controller;

  ChallengeData({required this.challengeTitle, required this.controller});
}