import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapchat_ui_clone/widgets/top_bar.dart';
import 'dart:io';
import '../style.dart';
import '../widgets/stories.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({Key? key}) : super(key: key);

  @override
  State<EventsScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventsScreen> {
  int _selectedToggleIndex = 0; // Default to the "Events" toggle
  int _expandedChallengeIndex = -1;

  Future<List<dynamic>> loadChallengeData() async {
    String jsonDataFile = 'assets/images/data/events_data.json'; // Default to events_data.json

    if (_selectedToggleIndex == 1) {
      jsonDataFile = 'assets/images/data/activities_data.json';
    } else if (_selectedToggleIndex == 2) {
      jsonDataFile = 'assets/images/data/challenge_data.json';
    } else if (_selectedToggleIndex == 3) {
      jsonDataFile = 'assets/images/data/events_data.json';
    }



    final String jsonData = await rootBundle.loadString(jsonDataFile);
    final jsonDataMap = json.decode(jsonData);
    final challengeList = jsonDataMap['data'] as List<dynamic>;
    return challengeList;
  }

  List<bool> isSelected = [true, false, false, false];

  // String getTitle() {
  //   if (_selectedToggleIndex == 0) {
  //     return 'Create Events';
  //   } else if (_selectedToggleIndex == 1) {
  //     return 'Create Activities';
  //   } else if (_selectedToggleIndex == 2) {
  //     return 'Create Challenges';
  //   }
  //   return 'Unknown Title';
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            // Top bar
            const TopBar(isCameraPage: false, text: 'Unite'),
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
                    // Stories
                    Style.sectionTitle('Team Stories'),
                    const Stories(),
                    const SizedBox(height: 18),
                    // Select A Challenge
                    Style.sectionTitle('Create a Post'),
                    const SizedBox(height: 18),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Center(
                        child: ToggleButtons(
                          isSelected: isSelected,
                          children: const <Widget>[
                            Text('Event', style: TextStyle(fontSize: 18)),
                            Text("To-Do", style: TextStyle(fontSize: 18)),
                            Text('Activity', style: TextStyle(fontSize: 18)),
                            Text('Challenge', style: TextStyle(fontSize: 18)),
                          ],
                          onPressed: (int newIndex) {
                            setState(() {
                              for (int i = 0; i < isSelected.length; i++) {
                                isSelected[i] = i == newIndex;
                              }
                              _selectedToggleIndex = newIndex; // Update the selected toggle index
                            });
                          },
                        ),
                      ),
                    ),
                    // List of Challenges
                    FutureBuilder<List<dynamic>>(
                      future: loadChallengeData(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return const Center(child: Text('Error loading data'));
                        } else if (!snapshot.hasData) {
                          return Center(child: Text('No data available'));
                        }

                        final challengeList = snapshot.data!;

                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: challengeList.length,
                          itemBuilder: (context, index) {
                            final challenge = challengeList[index];
                            final challengeType = challenge['challengeType'];
                            final subChallengeTypes = challenge['subChallengeTypes'] as Map<String, dynamic>;
                            final isExpanded = index == _expandedChallengeIndex;

                            return Card(
                              elevation: 4,
                              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  ListTile(
                                    title: Text(
                                      challengeType,
                                      style: TextStyle(
                                        color: _expandedChallengeIndex == index ? Colors.blue : Colors.black,
                                        fontWeight: _expandedChallengeIndex == index ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                    trailing: Icon(
                                      isExpanded
                                          ? Icons.keyboard_arrow_up
                                          : Icons.keyboard_arrow_down,
                                    ),
                                    onTap: () {
                                      setState(() {
                                        _expandedChallengeIndex = isExpanded ? -1 : index;
                                      });
                                    },
                                  ),
                                  if (isExpanded)
                                    Column(
                                      children: subChallengeTypes.entries.map((entry) {
                                        final subChallengeData = entry.value as Map<String, dynamic>;
                                        final subChallengeName = subChallengeData['name'] as String;
                                        final activities = subChallengeData['activities'] as List<dynamic>;

                                        return ExpansionTile(
                                          title: Text(subChallengeName), // Display the name of subChallenge
                                          children: [
                                            ListView.builder(
                                              shrinkWrap: true,
                                              itemCount: activities.length,
                                              itemBuilder: (context, activityIndex) {
                                                final activity = activities[activityIndex];
                                                final activityName = activity['name'] as String;

                                                return ExpansionTile(
                                                  title: Text(activityName),
                                                  children: [
                                                    if (activity['subCategory'] != null)
                                                      ListTile(
                                                        title: Text(
                                                          activity['subCategory']['name'] as String, // Get the subCategory's name
                                                        ),
                                                      ),
                                                    // You can add more details about the activity here
                                                  ],
                                                );
                                              },
                                            ),
                                          ],
                                        );
                                      }).toList(),
                                    ),
                                ],
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
    );
  }
}
