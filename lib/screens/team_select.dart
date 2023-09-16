import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';

class TeamSelect extends StatefulWidget {
  const TeamSelect({Key? key}) : super(key: key);

  @override
  State<TeamSelect> createState() => _TeamSelectState();
}

class _TeamSelectState extends State<TeamSelect> {
  int _selectedToggleIndex = 0; // Default to the "Events" toggle
  int _expandedChallengeIndex = -1;

  // Initialize a map to keep track of the checked states for each team's activities
  Map<String, List<bool>> _teamCheckedStates = {};

  Future<List<dynamic>> loadTeamData() async {
    String jsonDataFile = 'assets/images/data/team_data.json'; // Default to events_data.json

    final String jsonData = await rootBundle.loadString(jsonDataFile);
    final jsonDataMap = json.decode(jsonData);
    final challengeList = jsonDataMap['data'] as List<dynamic>;

    // Filter the challengeList based on the 'user' field ****** This is where it should automatically pull
    //in the user which is currently logged in
    final filteredChallengeList = challengeList.where((challenge) => challenge['user'] == 'user2').toList();
    print(filteredChallengeList);
    return filteredChallengeList;
  }

  void _confirmTeam() {
    List<String> selectedTeams = [];
    // Implement your logic here for confirming the team.
    // You can use the selected data to perform the necessary actions.
    // For now, let's just print a message as a placeholder.
    print('Team confirmed');
    _teamCheckedStates.forEach((teamName, checkedStates) {
      if (checkedStates.contains(true)) {
        print('Team checked: $teamName');
        selectedTeams.add(teamName); // Add checked team to the list
      }
    });
    // Close the current screen and return to the previous screen.
    Navigator.pop(context, selectedTeams);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select a Team'),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            // Top bar
            Positioned(
              top: 100,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height - 100 - (Platform.isIOS ? 90 : 60),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // List of Challenges
                    FutureBuilder<List<dynamic>>(
                      future: loadTeamData(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return const Center(child: Text('Error loading data'));
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

                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: challengeList.length,
                          itemBuilder: (context, index) {
                            final challenge = challengeList[index];
                            final challengeType = challenge['user'];
                            final subChallengeTypes = challenge['subChallengeTypes'] as Map<String, dynamic>;

                            return Card(
                              elevation: 4,
                              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: subChallengeTypes.entries.map((entry) {
                                  final subChallengeData = entry.value as Map<String, dynamic>;
                                  final TeamName = subChallengeData['teamname'] as String?;
                                  final activities = subChallengeData['teammates'] as List<dynamic>;
                                  print("Team Name: $TeamName");
                                  print(index);

                                  // Initialize the checked state for this team's activities
                                  _teamCheckedStates.putIfAbsent(TeamName!, () => List.generate(activities.length, (index) => false));

                                  return ExpansionTile(
                                    leading: Checkbox(
                                      value: _teamCheckedStates[TeamName!]!.contains(true), // Use the checked state from the map
                                      onChanged: (bool? newValue) {
                                        setState(() {
                                          // Update the checked state when the checkbox is changed
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
                                  );
                                }).toList(),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _confirmTeam,
        child: Icon(Icons.check),
      ),
    );

  }
}
