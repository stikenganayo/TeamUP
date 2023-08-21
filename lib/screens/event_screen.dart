
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
    }

    final String jsonData = await rootBundle.loadString(jsonDataFile);
    final jsonDataMap = json.decode(jsonData);
    final challengeList = jsonDataMap['data'] as List<dynamic>;
    return challengeList;
  }

  List<bool> isSelected = [true, false, false];

  String getTitle() {
    if (_selectedToggleIndex == 0) {
      return 'Create Events';
    } else if (_selectedToggleIndex == 1) {
      return 'Create Activities';
    } else if (_selectedToggleIndex == 2) {
      return 'Create Challenges';
    }
    return 'Unknown Title';
  }

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
                    Style.sectionTitle(getTitle()),
                    const SizedBox(height: 18),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Center(
                        child: ToggleButtons(
                          isSelected: isSelected,
                          children: const <Widget>[
                            Text('Events', style: TextStyle(fontSize: 18)),
                            Text('Activities', style: TextStyle(fontSize: 18)),
                            Text('Challenges', style: TextStyle(fontSize: 18)),
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

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _expandedChallengeIndex = isExpanded ? -1 : index;
                                });
                              },
                              child: Card(
                                elevation: 4,
                                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16), // Adjust the border radius for the Card
                                ),
                                child: Column(
                                  children: [
                                    ListTile(
                                      title: Text(challengeType),
                                      trailing: IconButton(
                                        icon: Icon(_expandedChallengeIndex == index
                                            ? Icons.keyboard_arrow_up
                                            : Icons.keyboard_arrow_down),
                                        onPressed: () {
                                          setState(() {
                                            _expandedChallengeIndex =
                                            _expandedChallengeIndex == index ? -1 : index;
                                          });
                                        },
                                      ),
                                    ),
                                    if (_expandedChallengeIndex == index)
                                      ListView.builder(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        itemCount: subChallengeTypes.length,
                                        itemBuilder: (context, subIndex) {
                                          final subChallenge =
                                              subChallengeTypes.entries.elementAt(subIndex).value;
                                          final subChallengeName = subChallenge['name'] as String;
                                          return Padding(
                                            padding:
                                            const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                            child: Card(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(subChallengeName),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                  ],
                                ),
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








// import 'dart:convert';
// import 'dart:math';
//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:snapchat_ui_clone/screens/activity_screen.dart';
// import 'package:snapchat_ui_clone/screens/challenge_screen.dart';
// import 'package:snapchat_ui_clone/widgets/top_bar.dart';
// import 'dart:io';
// import '../style.dart';
// import '../widgets/stories.dart';
//
//
// class EventsScreen extends StatefulWidget {
//   const EventsScreen({Key? key}) : super(key: key);
//
//   @override
//   State<EventsScreen> createState() => _EventScreenState();
// }
//
// class _EventScreenState extends State<EventsScreen> {
//   bool _isChallengeExpanded = false;
//   int _expandedChallengeIndex = -1;
//
//   Future<List<dynamic>> loadChallengeData() async {
//     final String jsonData = await rootBundle.loadString('assets/images/data/events_data.json');
//     final jsonDataMap = json.decode(jsonData);
//     final challengeList = jsonDataMap['data'] as List<dynamic>;
//     return challengeList;
//   }
//
//   List<bool> isSelected = [true, false, false];
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Stack(
//           children: [
//             // Top bar
//             const TopBar(isCameraPage: false, text: 'Unite'),
//             Positioned(
//               top: 100,
//               left: 0,
//               right: 0,
//               height: MediaQuery.of(context).size.height - 100 - (Platform.isIOS ? 90 : 60),
//               child: SingleChildScrollView(
//                 physics: const BouncingScrollPhysics(),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Stories
//                     Style.sectionTitle('Team Stories'),
//                     const Stories(),
//                     const SizedBox(height: 18),
//                     // Select A Challenge
//                     Style.sectionTitle('Create Events'),
//                     const SizedBox(height: 18),
//                     Container(
//                       padding: EdgeInsets.symmetric(horizontal: 16),
//                       child: Center(
//                         child: ToggleButtons(
//                           isSelected: isSelected,
//
//                           children: const <Widget>[
//                             Text('Events', style: TextStyle(fontSize: 18)),
//                             Text('Activities', style: TextStyle(fontSize: 18)),
//                             Text('Challenges', style: TextStyle(fontSize: 18)),
//                           ],
//                           onPressed: (int newIndex) {
//                             setState(() {
//                               for (int i = 0; i < isSelected.length; i++) {
//                                 isSelected[i] = i == newIndex;
//                               }
//                             });
//                             if (newIndex == 1) {
//                             Navigator.push(
//                             context,
//                             MaterialPageRoute(builder: (context) => const ActivitiesScreen()),
//                             );
//                             }
//                             if (newIndex == 2) {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(builder: (context) => const ChallengeScreen()),
//                               );
//                             }
//
//                           },
//
//
//                         ),
//                       ),
//                     ),
//                     // List of Challenges
//                     FutureBuilder<List<dynamic>>(
//                       future: loadChallengeData(),
//                       builder: (context, snapshot) {
//                         if (snapshot.connectionState == ConnectionState.waiting) {
//                           return const Center(child: CircularProgressIndicator());
//                         } else if (snapshot.hasError) {
//                           return const Center(child: Text('Error loading data'));
//                         } else if (!snapshot.hasData) {
//                           return Center(child: Text('No data available'));
//                         }
//
//                         final challengeList = snapshot.data!;
//
//                         return ListView.builder(
//                           shrinkWrap: true,
//                           itemCount: challengeList.length,
//                           itemBuilder: (context, index) {
//                             final challenge = challengeList[index];
//                             final challengeType = challenge['challengeType'];
//                             final subChallengeTypes = challenge['subChallengeTypes'] as Map<String, dynamic>;
//                             final isExpanded = index == _expandedChallengeIndex;
//
//                             return GestureDetector(
//                               onTap: () {
//                                 setState(() {
//                                   _expandedChallengeIndex = isExpanded ? -1 : index;
//                                 });
//                               },
//                               child: Card(
//                                 elevation: 4,
//                                 margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(16), // Adjust the border radius for the Card
//                                 ),
//                                 child: Column(
//                                   children: [
//                                     ListTile(
//                                       title: Text(challengeType),
//                                     ),
//                                     if (isExpanded)
//                                       ListView.builder(
//                                         shrinkWrap: true,
//                                         physics: NeverScrollableScrollPhysics(),
//                                         itemCount: subChallengeTypes.length,
//                                         itemBuilder: (context, subIndex) {
//                                           final subChallenge = subChallengeTypes.entries.elementAt(subIndex).value;
//                                           final subChallengeName = subChallenge['name'] as String;
//                                           return Padding(
//                                             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//                                             child: Card(
//
//                                               child: Column(
//                                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                                 children: [
//                                                   Text(subChallengeName),
//                                                 ],
//                                               ),
//                                             ),
//                                           );
//                                         },
//                                       ),
//                                   ],
//                                 ),
//                               ),
//                             );
//                           },
//                         );
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }