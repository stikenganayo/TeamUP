import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:snapchat_ui_clone/screens/event_screen.dart';
import 'package:snapchat_ui_clone/screens/search_screen.dart';
import '../style.dart';
import '../widgets/top_bar.dart';
import '../widgets/team_stories.dart';
import 'add_challenge_screen.dart';
import 'add_event_screen.dart';
import 'create_team_page.dart';
import 'dart:io';

class TeamScreen extends StatefulWidget {
  const TeamScreen({Key? key}) : super(key: key);

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  late User? currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<String?> _loadCurrentUserName() async {
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

          // Check for the 'name' field in the user data
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
    return null; // Return null if any error occurs or if user is not found
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
          Map<String, dynamic> userData =
          userSnapshot.data() as Map<String, dynamic>;

          // Print all data inside the current user's document
          print('User Data: $userData');

          // Check for team_ids in the user data
          if (userData.containsKey('team_ids')) {
            setState(() {});
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

  Future<String> _getTeamName(String teamId) async {
    try {
      // Fetch the team document based on the team ID
      DocumentSnapshot teamSnapshot = await FirebaseFirestore.instance
          .collection('teams')
          .doc(teamId)
          .get();

      if (teamSnapshot.exists) {
        Map<String, dynamic> teamData = teamSnapshot.data() as Map<String, dynamic>;

        // Check for the 'team_name' field in the team data
        if (teamData.containsKey('team_name')) {
          String teamName = teamData['team_name'];
          return teamName;
        } else {
          print('Team name field not found in team document');
        }
      } else {
        print('Team document not found for $teamId');
      }
    } catch (e) {
      print('Error loading team document: $e');
    }

    return 'Unknown Team';
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
        Map<String, dynamic> userData =
        userSnapshot.data() as Map<String, dynamic>;

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




  Future<List<String>> _getTeamPlayers(String teamId) async {
    try {
      // Fetch the team document based on the team ID
      DocumentSnapshot teamSnapshot = await FirebaseFirestore.instance
          .collection('teams')
          .doc(teamId)
          .get();

      if (teamSnapshot.exists) {
        Map<String, dynamic> teamData = teamSnapshot.data() as Map<String, dynamic>;

        // Check for the 'team_challenges' field and 'team_name' field in the team data
        if (teamData.containsKey('team_challenges') && teamData.containsKey('team_name')) {
          List<dynamic> teamChallenges = teamData['team_challenges'];
          String teamName = teamData['team_name'];

          // Print the array of team challenges and the team name to the console
          print('Team Challenges for $teamName: $teamChallenges');
          print('Team Name for $teamId: $teamName');

          // Assuming you want to get players from the first challenge
          if (teamChallenges.isNotEmpty &&
              teamChallenges[0].containsKey('players') &&
              teamChallenges[0]['players'] is List) {
            List<String> players = List.from(teamChallenges[0]['players']);
            return players;
          } else {
            print('Players field not found or not a list in team challenges');
          }
        } else {
          print('Team challenges or Team name field not found in team document');
        }
      } else {
        print('Team document not found for $teamId');
      }
    } catch (e) {
      print('Error loading team document: $e');
    }

    return [];
  }



  Future<List<String>> _getChallengeTitles(String teamId) async {
    try {
      // Fetch the team document based on the team ID
      DocumentSnapshot teamSnapshot = await FirebaseFirestore.instance
          .collection('teams')
          .doc(teamId)
          .get();

      if (teamSnapshot.exists) {
        Map<String, dynamic> teamData =
        teamSnapshot.data() as Map<String, dynamic>;

        // Print the team name directly from the teamData
        if (teamData.containsKey('team_challenges')) {
          List<dynamic> teamChallenges = teamData['team_challenges'];

          print('Team Challenges: $teamChallenges');

          // Extract challenge titles from all challenges
          List<String> challengeTitles = [];
          for (var challenge in teamChallenges) {
            if (challenge.containsKey('template_name') &&
                challenge['template_name'].isNotEmpty &&
                challenge['template_name'][0].containsKey('challengeTitle')) {
              String challengeTitle =
              challenge['template_name'][0]['challengeTitle'];
              challengeTitles.add(challengeTitle);
            }
          }

          return challengeTitles;
        } else {
          print('Team challenges field not found in team document');
        }
      } else {
        print('Team document not found for $teamId');
      }
    } catch (e) {
      print('Error loading team or challenge document: $e');
    }

    return []; // Default value if anything goes wrong
  }
  Future<List<String>> _getTeamPlayersForChallenge(String teamId, String challengeTitle) async {
    try {
      // Fetch the team document based on the team ID
      DocumentSnapshot teamSnapshot = await FirebaseFirestore.instance
          .collection('teams')
          .doc(teamId)
          .get();

      if (teamSnapshot.exists) {
        Map<String, dynamic> teamData = teamSnapshot.data() as Map<String, dynamic>;

        // Check for the 'team_challenges' field and 'team_name' field in the team data
        if (teamData.containsKey('team_challenges') && teamData.containsKey('team_name')) {
          List<dynamic> teamChallenges = teamData['team_challenges'];
          String teamName = teamData['team_name'];

          // Print the array of team challenges and the team name to the console
          print('Team Challenges for $teamName: $teamChallenges');
          print('Team Name for $teamId: $teamName');

          // Find the challenge with the matching title
          Map<String, dynamic>? selectedChallenge;
          for (var challenge in teamChallenges) {
            if (challenge.containsKey('template_name') &&
                challenge['template_name'] is List &&
                challenge['template_name'][0].containsKey('challengeTitle') &&
                challenge['template_name'][0]['challengeTitle'] == challengeTitle) {
              selectedChallenge = challenge;
              break;
            }
          }

          // Assuming you want to get players from the selected challenge
          if (selectedChallenge != null &&
              selectedChallenge.containsKey('players') &&
              selectedChallenge['players'] is List) {
            List<String> players = List.from(selectedChallenge['players']);
            return players;
          } else {
            print('Players field not found or not a list in the selected challenge');
          }
        } else {
          print('Team challenges or Team name field not found in team document');
        }
      } else {
        print('Team document not found for $teamId');
      }
    } catch (e) {
      print('Error loading team document: $e');
    }

    return [];
  }

  Future<List<String>> _getStatusForChallenge(String teamId, String challengeTitle) async {
    List<String> statusList = [];

    try {
      // Fetch the team document based on the team ID
      DocumentSnapshot teamSnapshot = await FirebaseFirestore.instance
          .collection('teams')
          .doc(teamId)
          .get();

      if (teamSnapshot.exists) {
        Map<String, dynamic> teamData = teamSnapshot.data() as Map<String, dynamic>;

        // Check for the 'team_challenges' field and 'team_name' field in the team data
        if (teamData.containsKey('team_challenges') && teamData.containsKey('team_name')) {
          List<dynamic> teamChallenges = teamData['team_challenges'];
          String teamName = teamData['team_name'];

          // Find the challenge with the matching title
          Map<String, dynamic>? selectedChallenge;
          for (var challenge in teamChallenges) {
            if (challenge.containsKey('template_name') &&
                challenge['template_name'] is List &&
                challenge['template_name'][0].containsKey('challengeTitle') &&
                challenge['template_name'][0]['challengeTitle'] == challengeTitle) {
              selectedChallenge = challenge;
              break;
            }
          }

          // Find the challengeDocRef and players
          if (selectedChallenge != null && selectedChallenge.containsKey('challengeDocRef')) {
            // Find the list of players for the current challenge
            if (selectedChallenge.containsKey('players') &&
                selectedChallenge['players'] is List) {
              List<String> players = List.from(selectedChallenge['players']);

              // Iterate through each player
              for (var player in players) {
                // Find the user document based on the player's name
                var userDocument = await FirebaseFirestore.instance
                    .collection('users')
                    .where('name', isEqualTo: player)
                    .get();

                if (userDocument.docs.isNotEmpty) {
                  var userDocData = userDocument.docs.first.data();

                  // Find the user's status in the current challenge
                  if (userDocData.containsKey('team_challenges') &&
                      userDocData['team_challenges'] is List) {
                    List<dynamic> userChallenges = List.from(userDocData['team_challenges']);

                    for (var userChallenge in userChallenges) {
                      if (userChallenge is Map &&
                          userChallenge.containsKey('challengeDocRef') &&
                          userChallenge['challengeDocRef'] == selectedChallenge['challengeDocRef']) {
                        // Match found, add the status to the list
                        if (userChallenge.containsKey('status')) {
                          statusList.add('${player}: ${userChallenge['status']}');
                        }

                        break; // Break out of the loop after finding the matching challenge
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    } catch (e) {
      print('Error loading team document: $e');
    }

    return statusList;
  }
  Future<String> _getStatusForUserInChallenge(String teamId, String challengeTitle, String userName) async {
    try {
      // Fetch the team document based on the team ID
      DocumentSnapshot teamSnapshot = await FirebaseFirestore.instance
          .collection('teams')
          .doc(teamId)
          .get();

      if (teamSnapshot.exists) {
        Map<String, dynamic> teamData = teamSnapshot.data() as Map<String, dynamic>;

        // Check for the 'team_challenges' field and 'team_name' field in the team data
        if (teamData.containsKey('team_challenges') && teamData.containsKey('team_name')) {
          List<dynamic> teamChallenges = teamData['team_challenges'];

          // Find the challenge with the matching title
          Map<String, dynamic>? selectedChallenge;
          for (var challenge in teamChallenges) {
            if (challenge.containsKey('template_name') &&
                challenge['template_name'] is List &&
                challenge['template_name'][0].containsKey('challengeTitle') &&
                challenge['template_name'][0]['challengeTitle'] == challengeTitle) {
              selectedChallenge = challenge;
              break;
            }
          }

          // Check if the challenge is found
          if (selectedChallenge != null) {
            // Check if the challenge has a 'status' field
            if (selectedChallenge.containsKey('status') && selectedChallenge['status'] is Map) {
              Map<String, dynamic> statusMap = Map.from(selectedChallenge['status']);

              // Find the status for the specified user
              if (statusMap.containsKey(userName)) {
                return statusMap[userName].toString();
              } else {
                return 'Status not found';
              }
            } else {
              print('Status field not found for the challenge: $challengeTitle');
            }
          } else {
            print('Challenge not found: $challengeTitle');
          }
        } else {
          print('Team challenges or Team name field not found in team document');
        }
      } else {
        print('Team document not found for $teamId');
      }
    } catch (e) {
      print('Error loading team document: $e');
    }

    return 'Error loading status'; // Return an error message in case of an issue
  }
  Future<int> getTeamDetails(String teamId) async {
    try {
      // Assuming Firestore is your database instance
      final teamsCollection = FirebaseFirestore.instance.collection('teams');

      // Fetch the team document based on the provided teamId
      DocumentSnapshot teamDocSnapshot = await teamsCollection.doc(teamId).get();

      if (teamDocSnapshot.exists) {
        // Extract users array from team document
        List<dynamic>? users = teamDocSnapshot['users'];

        // Print teamId
        print('Team ID: $teamId');

        // Print users to the screen
        print('Users:');
        if (users != null) {
          for (var user in users) {
            print('- $user');
          }
        } else {
          print('No users found for this team.');
        }

        // Calculate and print the count of users
        int userCount = users?.length ?? 0;
        print('User Count: $userCount');

        // Subtract 1 from the count and return the adjusted count
        int adjustedUserCount = userCount - 1;
        print('Adjusted User Count: $adjustedUserCount');
        return adjustedUserCount;
      } else {
        print('Team document not found for teamId: $teamId');
        // Throw an exception to handle this case
        throw Exception('Team document not found for teamId: $teamId');
      }
    } catch (e) {
      print('Error loading team document: $e');
      // Throw an exception to handle the error
      throw Exception('Error loading team document: $e');
    }
  }

  Future<void> _showConfirmationDialog(String userName, String userLoggedIn, String currentChallenge, String teamId) async {
    try {
      // Fetch and display team details
      int adjustedUserCount = await getTeamDetails(teamId);

      return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirmation'),
            content: Text('Select yes if you would like to confirm $userName has completed this challenge for today.'),
            actions: <Widget>[
              TextButton(
                onPressed: () async {
                  // Add your logic for confirming completion here
                  Navigator.of(context).pop();

                  // Get the challenges collection reference
                  CollectionReference challengesCollection = FirebaseFirestore.instance.collection('challenges');

                  // Fetch documents from the challenges collection
                  QuerySnapshot challengesSnapshot = await challengesCollection.where('challengeDataList', arrayContains: {'challengeTitle': currentChallenge}).get();

                  // Get the current date in the desired format
                  String formattedDate = DateFormat('MMMM dd, yyyy').format(DateTime.now());

                  // Iterate through the documents and update if challengeTitle matches
                  challengesSnapshot.docs.forEach((challengeDoc) async {
                    Map<String, dynamic> challengeData = challengeDoc.data() as Map<String, dynamic>;

                    // Assuming userName_stats is an array
                    List<dynamic> userNameStats = challengeData['${userName}_stats'] ?? [];

                    // Create a new array element
                    Map<String, dynamic> newStatsElement = {
                      'confirmed_completion': [userLoggedIn.trim()],
                      'date': formattedDate,
                    };

                    // Update the document in the challenges collection
                    await challengesCollection.doc(challengeDoc.id).update({
                      '${userName}_stats': FieldValue.arrayUnion([newStatsElement]),
                    });
                  });
                },
                child: Text('Yes'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('No'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      // Handle exceptions here, if needed
      print('Error in _showConfirmationDialog: $e');
    }
  }

  Future<void> _incrementAttendField(String teamId, String currentUserLoggedIn) async {
    try {
      // Get the current date in the "month day year" format
      String currentDate = DateFormat('MMMM dd yyyy').format(DateTime.now());

      // Fetch the team document based on the team ID
      DocumentSnapshot teamSnapshot = await FirebaseFirestore.instance
          .collection('teams')
          .doc(teamId)
          .get();

      if (teamSnapshot.exists) {
        List<dynamic> userEvents = teamSnapshot.get('user_events');

        // Iterate through each event
        for (var event in userEvents) {
          if (event is Map<String, dynamic>) {
            // Initialize attending count for the event
            int attendingCount = 0;

            // Initialize the statsCounts map to store counts for each stats field
            Map<String, int> statsCounts = {};

            // Create the new field currentUserLoggedIn_stats and store the current date as an array
            String currentUserStatsField = '${currentUserLoggedIn}_stats';
            List<String>? currentUserStats = event[currentUserStatsField]?.cast<String>();

            // Update the date field in _stats if currentDate is not already present
            if (currentUserStats == null || !currentUserStats.contains(currentDate)) {
              if (currentUserStats == null) {
                event[currentUserStatsField] = [currentDate];
              } else {
                currentUserStats.add(currentDate);
                event[currentUserStatsField] = currentUserStats;
              }
            }

            // Iterate through each field ending with _stats
            event.keys.where((key) => key.endsWith('_stats')).forEach((statKey) {
              List<String> stats = (event[statKey] as List<dynamic>).cast<String>();

              // Check if the current date matches any date within the field's array
              if (stats.contains(currentDate)) {
                // Update attending count by the number of users with the same date
                attendingCount += 1;
              } else {
                // Clear attending count since there are no users for the current date
                attendingCount = 0;
              }
            });

            // Update the attending count for this event in user_events
            event['attending'] = attendingCount;
          }
        }

        // Update the Firestore document with the modified user_events
        await teamSnapshot.reference.update({
          'user_events': userEvents,
        });

      } else {
        print('Team document not found for $teamId');
      }
    } catch (e) {
      print('Error loading or updating team document: $e');
    }
  }


  Future<void> _setAttendField(String teamId) async {
    try {
      // Get the current date in the "month day year" format
      String currentDate = DateFormat('MMMM dd yyyy').format(DateTime.now());

      // Fetch the team document based on the team ID
      DocumentSnapshot teamSnapshot = await FirebaseFirestore.instance
          .collection('teams')
          .doc(teamId)
          .get();

      if (teamSnapshot.exists) {
        List<dynamic> userEvents = teamSnapshot.get('user_events');

        // Iterate through each event
        for (var event in userEvents) {
          if (event is Map<String, dynamic>) {
            // Initialize attending count for the event outside of the loop
            int attendingCount = 0;

            // Iterate through each field ending with _stats
            event.keys.where((key) => key.endsWith('_stats')).forEach((statKey) {
              List<String> stats = (event[statKey] as List<dynamic>).cast<String>();

              // Check if the current date matches any date within the field's array
              if (stats.contains(currentDate)) {
                // Update attending count by the number of users with the same date
                attendingCount += stats.where((date) => date == currentDate).length;
              }
            });

            // Update the attending count for this event in user_events
            event['attending'] = attendingCount;
          }
        }

        // Update the Firestore document with the modified user_events
        await teamSnapshot.reference.update({
          'user_events': userEvents,
        });
      } else {
        print('Team document not found for $teamId');
      }
    } catch (e) {
      print('Error loading or updating team document: $e');
    }
  }





  Future<Map<String, dynamic>> _getEvents(String teamId) async {
    await _setAttendField(teamId);

    try {
      // Get the current day and formatted date
      String currentDay = DateFormat('EEE').format(DateTime.now());
      String currentFormattedDate = DateFormat('MMMM dd yyyy').format(DateTime.now());
      print('Current day: $currentDay');
      print('Current formatted date: $currentFormattedDate');

      // Fetch the team document based on the team ID
      DocumentSnapshot teamSnapshot = await FirebaseFirestore.instance
          .collection('teams')
          .doc(teamId)
          .get();

      if (teamSnapshot.exists) {
        Map<String, dynamic> teamData = teamSnapshot.data() as Map<String, dynamic>;

        // Check for the 'user_events' field in the team data
        if (teamData.containsKey('user_events')) {
          List<dynamic> userEvents = teamData['user_events'];
          if (userEvents.isNotEmpty) {
            // Find the first event that matches the current day or startDate
            Map<String, dynamic>? firstMatchingEvent;
            for (var event in userEvents) {

              List<String> selectedDays = List<String>.from(event['selectedDays']);
              print('Selected days for event: $selectedDays');
              if (selectedDays.contains(currentDay)) {
                // Extract event data
                firstMatchingEvent = {
                  'startTime': event['startTime'],
                  'endTime': event['endTime'],
                  'eventTitle': event['eventTitle'],
                  'selectedDays': event['selectedDays'],
                  'attending': event['attending'],
                  'eventCreator': event['eventCreator'],
                };
                // Concatenate dash after start time
                firstMatchingEvent['startTime'] = '${firstMatchingEvent['startTime']}  -';
                print('First matching event: $firstMatchingEvent');
                break; // Stop searching once a matching event is found
              } else {
                // Check if it's a one-time event with startDate matching the current date
                String startDate = DateFormat('MMMM dd yyyy').format((event['startDate'] as Timestamp).toDate());
                if (startDate == currentFormattedDate) {
                  // Extract event data
                  firstMatchingEvent = {
                    'startTime': event['startTime'],
                    'endTime': event['endTime'],
                    'eventTitle': event['eventTitle'],
                    'selectedDays': event['selectedDays'],
                    'attending': event['attending'],
                    'eventCreator': event['eventCreator'],
                  };
                  // Concatenate dash after start time
                  firstMatchingEvent['startTime'] = '${firstMatchingEvent['startTime']}  -';
                  print('First matching event: $firstMatchingEvent');
                  break; // Stop searching once a matching event is found
                }
              }
            }
            // Return the matching event data, or empty values if no match found
            return firstMatchingEvent ?? {
              'startTime': '',
              'endTime': '',
              'eventTitle': '',
              'attending': '',
              'eventCreator': '',
              'selectedDays': []
            };
          } else {
            print('No user events found in team document');
          }
        } else {
          print('User events field not found in team document');
        }
      } else {
        print('Team document not found for $teamId');
      }
    } catch (e) {
      print('Error loading team document: $e');
    }

    return {
      'startTime': '',
      'endTime': '',
      'eventTitle': '',
      'attending': '',
      'eventCreator': '',
      'selectedDays': []
    }; // Returning empty values if no event found or error occurred
  }



  Future<Map<String, int>> _displayUserPoints(String userName, String userLoggedIn, String currentChallenge, String teamId) async {
    try {
      // Fetch and display team details
      int adjustedUserCount = await getTeamDetails(teamId);
      print(adjustedUserCount);

      // Get the challenges collection reference
      CollectionReference challengesCollection = FirebaseFirestore.instance.collection('challenges');

      // Fetch documents from the challenges collection
      QuerySnapshot challengesSnapshot = await challengesCollection.where('challengeDataList', arrayContains: {'challengeTitle': currentChallenge}).get();

      // Get the current date in the desired format
      DateTime currentDate = DateTime.now();
      String formattedDate = DateFormat('MMMM dd, yyyy').format(currentDate);

      int countOfArraysForCurrentDate = 0;
      int countOfArraysForConsistencyDates = 0;
      int countOfArraysForDifferentDate = 0;
      int userTyping = 0;
      int challengeType = 0;
      int emotionalCategory = 0;
      int environmentalCategory = 0;
      int financialCategory = 0;
      int intellectualCategory = 0;
      int occupationalCategory = 0;
      int physicalCategory = 0;
      int socialCategory = 0;
      int spiritualCategory = 0;

      // Iterate through the documents and display confirmation message
      challengesSnapshot.docs.forEach((challengeDoc) {
        Map<String, dynamic> challengeData = challengeDoc.data() as Map<String, dynamic>;

        // Assuming userLoggedIn_stats is an array
        List<dynamic> userLoggedInStats = challengeData['${userName}_stats'] ?? [];

        // Count the number of arrays with the current date and 'confirmed_completion'
        countOfArraysForCurrentDate += userLoggedInStats.where((statsElement) =>
        statsElement['date'] == formattedDate &&
            statsElement.containsKey('confirmed_completion') &&
            (statsElement['confirmed_completion'] as List).isNotEmpty,
        ).length;


        // Count all arrays
        countOfArraysForDifferentDate += userLoggedInStats.length;

        // Create a Set to store unique dates
        Set<String> uniqueDatesInChallenge = Set<String>();

        // Iterate through userLoggedInStats to add unique dates
        userLoggedInStats.forEach((statsElement) {
          String date = statsElement['date'];

          // Check if the date is not in uniqueDatesInChallenge
          if (!uniqueDatesInChallenge.contains(date)) {
            uniqueDatesInChallenge.add(date);
          } else {
            // Subtract 1 for each duplicate date
            countOfArraysForDifferentDate--;
          }
        });

        // Count the number of arrays for consistency dates
        DateTime loopDate = currentDate; // Create a separate variable for the loop
        bool foundMatchingDate = userLoggedInStats.any((statsElement) => statsElement['date'] == DateFormat('MMMM dd, yyyy').format(loopDate));

        if (!foundMatchingDate) {
          // Subtract one day if no match for the current date
          loopDate = loopDate.subtract(Duration(days: 1));
        }

        while (userLoggedInStats.any((statsElement) => statsElement['date'] == DateFormat('MMMM dd, yyyy').format(loopDate))) {
          countOfArraysForConsistencyDates++;
          loopDate = loopDate.subtract(Duration(days: 1));
        }


        userTyping = challengeData['userTyping'] == 'true' ? 1 : 0;
        // Debugging statements
        print('Challenge data: $challengeData');
        print('User Typing field: ${challengeData['userTyping']}');
        print('Challenge Type: ${challengeData['challengeType']}');
        print('emotionalCategory: ${challengeData['emotionalCategory']}');

// Assuming userTyping is a boolean field



        if (challengeData['emotionalCategory'] == true) {
          emotionalCategory = 1;
        } else {
          emotionalCategory = 0;
        }
        if (challengeData['environmentalCategory'] == true) {
          environmentalCategory = 1;
        } else {
          environmentalCategory = 0;
        }
        if (challengeData['financialCategory'] == true) {
          financialCategory = 1;
        } else {
          financialCategory = 0;
        }
        if (challengeData['intellectualCategory'] == true) {
          intellectualCategory = 1;
        } else {
          intellectualCategory = 0;
        }
        if (challengeData['occupationalCategory'] == true) {
          occupationalCategory = 1;
        } else {
          occupationalCategory = 0;
        }
        if (challengeData['physicalCategory'] == true) {
          physicalCategory = 1;
        } else {
          physicalCategory = 0;
        }
        if (challengeData['socialCategory'] == true) {
          socialCategory = 1;
        } else {
          socialCategory = 0;
        }
        if (challengeData['spiritualCategory'] == true) {
          spiritualCategory = 1;
        } else {
          spiritualCategory = 0;
        }



        // environmentalCategory = challengeData['environmentalCategory'] == 'true' ? 1 : 0;
        // financialCategory = challengeData['financialCategory'] == 'true' ? 1 : 0;
        // intellectualCategory = challengeData['intellectualCategory'] == 'true' ? 1 : 0;
        // occupationalCategory = challengeData['occupationalCategory'] == 'true' ? 1 : 0;
        // physicalCategory = challengeData['physicalCategory'] == 'true' ? 1 : 0;
        // socialCategory = challengeData['socialCategory'] == 'true' ? 1 : 0;
        // spiritualCategory = challengeData['spiritualCategory'] == 'true' ? 1 : 0;
        print('emotionalCategory Status: $emotionalCategory');



        print('User Typing for $userName: $userTyping');

        challengeType = challengeData['challengeType'] == 'Challenge yourself - get your teammates to verify' ? 1 : (challengeData['challengeType'] == 'Challenge your teammates - you verify' ? 2 : 0);

        print(challengeType);



      });

      print('Is user typing enabled for $userName: $userTyping');
      print('Teammates who verified $userName: $countOfArraysForCurrentDate');
      print('Total points for $userName: $countOfArraysForDifferentDate');
      print('Current Streak for $userName: $countOfArraysForConsistencyDates');
      print(adjustedUserCount);

      Map<String, int> result = {
        'countOfArraysForCurrentDate': countOfArraysForCurrentDate,
        'countOfArraysForDifferentDate': countOfArraysForDifferentDate,
        'countOfArraysForConsistencyDates': countOfArraysForConsistencyDates,
        'adjustedUserCount': adjustedUserCount,
        'userTyping': userTyping,
        'challengeType': challengeType,
        'emotionalCategory' : emotionalCategory,
        'environmentalCategory' : environmentalCategory,
        'financialCategory' : financialCategory,
        'intellectualCategory' : intellectualCategory,
        'occupationalCategory' : occupationalCategory,
        'physicalCategory' : physicalCategory,
        'socialCategory' : socialCategory,
        'spiritualCategory' : spiritualCategory,
      };

      return result;
    } catch (e) {
      // Handle exceptions here, if needed
      print('Error in _displayUserPoints: $e');
      return {'countOfArraysForCurrentDate': 0, 'countOfArraysForDifferentDate': 0, 'countOfArraysForConsistencyDates': 0, 'adjustedUserCount': 0, 'userTyping': 0, 'challengeType': 0, 'emotionalCategory': 0, 'environmentalCategory': 0, 'financialCategory': 0, 'intellectualCategory': 0, 'occupationalCategory': 0, 'physicalCategory': 0, 'socialCategory': 0, 'spiritualCategory': 0}; // Return default values or handle the error accordingly
    }
  }


  Future<List<dynamic>> getTeamUsers(String teamId) async {
    try {
      // Assuming Firestore is your database instance
      final teamsCollection = FirebaseFirestore.instance.collection('teams');

      // Fetch the team document based on the provided teamId
      DocumentSnapshot teamDocSnapshot = await teamsCollection.doc(teamId).get();

      if (teamDocSnapshot.exists) {
        // Extract users array from team document
        List<dynamic>? users = teamDocSnapshot['users'];

        // Print teamId
        print('Team ID: $teamId');

        // Print users to the screen
        print('Users:');
        if (users != null) {

        } else {
          print('No users found for this team.');
        }

        return users ?? []; // Return the list of users, or an empty list if null
      } else {
        print('Team document not found for teamId: $teamId');
        // Throw an exception to handle this case
        throw Exception('Team document not found for teamId: $teamId');
      }
    } catch (e) {
      print('Error loading team document: $e');
      // Throw an exception to handle the error
      throw Exception('Error loading team document: $e');
    }
  }





  Future<Widget> challengeStreaksAndPoints(challengeTitle, teamId) async {
    // Fetch and display team details
    List<dynamic> users = await getTeamUsers(teamId);

    // Add "_stats" to each user name
    List<String> userStatsNames = users.map((user) => '$user\_stats').toList();
    print(userStatsNames);

// Get the challenges collection reference
    CollectionReference challengesCollection = FirebaseFirestore.instance.collection('challenges');

// Fetch documents from the challenges collection
    QuerySnapshot challengesSnapshot = await challengesCollection.where('challengeDataList', arrayContains: {'challengeTitle': challengeTitle}).get();

// List to store input fields
    List<String> allInputFields = [];

    int emotionalCategory = 0;
    int environmentalCategory = 0;
    int financialCategory = 0;
    int intellectualCategory = 0;
    int occupationalCategory = 0;
    int physicalCategory = 0;
    int socialCategory = 0;
    int spiritualCategory = 0;

// Iterate through each document
    for (QueryDocumentSnapshot document in challengesSnapshot.docs) {
      // Check if data is not null for the document
      if (document.exists) {
        Map<String, dynamic>? data = document.data() as Map<String, dynamic>?;

        // Iterate through each field in the document
        if (data != null) {
          data.forEach((key, value) {
            // Check if the field contains "_quotes"
            if (key.toString().contains('_quotes')) {
                // Add the "input" field in each array to the list
                value.forEach((item) {
                  if (item['input'] != null) {
                    allInputFields.add(item['input']);
                  }
                });
            }
          });
        }
      }
    }

// Print the list of all input fields
    print('All Input Fields: $allInputFields');




    // Get the current date in the desired format
    DateTime currentDate = DateTime.now();
    String formattedDate = DateFormat('MMMM dd, yyyy').format(currentDate);

    print(challengeTitle);

    // Initialize a map to store counts for each user
    Map<String, int> userCounts = {};

    // Initialize a variable to store the sum of all users' points
    int totalUserPoints = 0;

    // Initialize a list to store all the currentStreak values
    List<int> currentStreaksList = [];

    // Iterate through each index in userStatsNames
    for (String userStatName in userStatsNames) {
      // Initialize count for the current user
      int userCount = 0;

      // Initialize a variable to store the streak for the current user
      int currentStreak = 0;

      // Iterate through each document in challengesSnapshot
      for (QueryDocumentSnapshot challengeDoc in challengesSnapshot.docs) {
        Map<String, dynamic> challengeData = challengeDoc.data() as Map<
            String,
            dynamic>;

        // Retrieve the stats array for the current userStatName
        List<dynamic> userLoggedInStats = challengeData[userStatName] ?? [];

        // Count all arrays
        userCount += userLoggedInStats.length;

        // Create a Set to store unique dates
        Set<String> uniqueDatesInChallenge = Set<String>();

        // Iterate through userLoggedInStats to add unique dates
        userLoggedInStats.forEach((statsElement) {
          String date = statsElement['date'];

          // Check if the date is not in uniqueDatesInChallenge
          if (!uniqueDatesInChallenge.contains(date)) {
            uniqueDatesInChallenge.add(date);
          } else {
            // Subtract 1 for each duplicate date
            userCount--;
          }
        });

        // Count the number of arrays for consistency dates
        DateTime loopDate = currentDate; // Create a separate variable for the loop
        bool foundMatchingDate = userLoggedInStats.any((statsElement) =>
        statsElement['date'] == DateFormat('MMMM dd, yyyy').format(loopDate));

        if (!foundMatchingDate) {
          // Subtract one day if no match for the current date
          loopDate = loopDate.subtract(Duration(days: 1));
        }

        while (userLoggedInStats.any((statsElement) =>
        statsElement['date'] == DateFormat('MMMM dd, yyyy').format(loopDate))) {
          currentStreak++;
          loopDate = loopDate.subtract(Duration(days: 1));
        }
      }

        // Print the current streak for the current user
      print('Current Streak for $userStatName: $currentStreak');

      // Store the current streak in the list
      currentStreaksList.add(currentStreak);

      // Store the count for the current userStatName in the userCounts map
      userCounts[userStatName] = userCount;

      // Add the user's count to the totalUserPoints
      totalUserPoints += userCount;
    }

    // Print the counts for each user
    userCounts.forEach((user, count) {
      print('$user: $count');
    });

    // Print the total points for all users
    print('Total User Points: $totalUserPoints');

    // Find the minimum count among all users
    int minUserCount = currentStreaksList.isNotEmpty ? currentStreaksList.reduce((value, element) => value < element ? value : element) : 0;

    // Print the minimum count among all users
    print('Min Count Among All Users: $minUserCount');

    // Initialize a variable to track whether there is more than one array
    bool hasMultipleChallenges = false;

// Initialize a list to store challenge data for the popup
    List<Map<String, dynamic>> popupChallengeDataList = [];

// Iterate through the documents
    for (QueryDocumentSnapshot challengeDoc in challengesSnapshot.docs) {
      Map<String, dynamic> challengeData = challengeDoc.data() as Map<String, dynamic>;

      // Assuming 'challengeDataList' is a list
      List<dynamic> challengeDataList = challengeData['challengeDataList'];

      // Print the entire array
      print("Challenge Data List: $challengeDataList");

      if (challengeData['emotionalCategory'] == true) {
        emotionalCategory = 1;
      } else {
        emotionalCategory = 0;
      }
      if (challengeData['environmentalCategory'] == true) {
        environmentalCategory = 1;
      } else {
        environmentalCategory = 0;
      }
      if (challengeData['financialCategory'] == true) {
        financialCategory = 1;
      } else {
        financialCategory = 0;
      }
      if (challengeData['intellectualCategory'] == true) {
        intellectualCategory = 1;
      } else {
        intellectualCategory = 0;
      }
      if (challengeData['occupationalCategory'] == true) {
        occupationalCategory = 1;
      } else {
        occupationalCategory = 0;
      }
      if (challengeData['physicalCategory'] == true) {
        physicalCategory = 1;
      } else {
        physicalCategory = 0;
      }
      if (challengeData['socialCategory'] == true) {
        socialCategory = 1;
      } else {
        socialCategory = 0;
      }
      if (challengeData['spiritualCategory'] == true) {
        spiritualCategory = 1;
      } else {
        spiritualCategory = 0;
      }



      // Check if the array has more than one element
      if (challengeDataList.length > 1) {
        hasMultipleChallenges = true;

        // Store the challenge data for the popup
        popupChallengeDataList = List.from(challengeDataList);
      }
    }

    return Row(
      children: [
        // Add a button to the left of the row if there are multiple challenges
        if (hasMultipleChallenges)
          ElevatedButton(
            onPressed: () {
              // Show a dialog with the title at index 0 and the rest as a list
              showDialog(
                context: context, // Replace 'context' with your actual context variable
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(popupChallengeDataList.isNotEmpty ? popupChallengeDataList[0]['challengeTitle'] : ''),
                    content: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: 200, // Adjust the height constraint as needed
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: List.generate(
                            popupChallengeDataList.length - 1,
                                (index) => ListTile(
                              title: Text(popupChallengeDataList[index + 1]['challengeTitle']),
                            ),
                          ),
                        ),
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                        },
                        child: Text('Close'),
                      ),
                    ],
                  );
                },
              );
            },
            child: Text('Tasks'),
          ),
        if (allInputFields.isNotEmpty)
          ElevatedButton(
            onPressed: () {
              // Show a dialog with the title at index 0 and the rest as a list
              showDialog(
                context: context, // Replace 'context' with your actual context variable
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(popupChallengeDataList.isNotEmpty ? popupChallengeDataList[0]['challengeTitle'] : ''),
                    content: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: 200, // Adjust the height constraint as needed
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: List.generate(
                            allInputFields.length,
                                (index) => ListTile(
                              title: Text(allInputFields[index]),
                            ),
                          ),
                        ),
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                        },
                        child: Text('Close'),
                      ),
                    ],
                  );
                },
              );
            },
            child: Text('History'),
          ),


        SizedBox(width: 8), // Add some space between the button and the icons/text
        Icon(Icons.local_fire_department_sharp),
        Text(' $minUserCount'),
        SizedBox(width: 8), // Add some space between the button and the icons/text
        // Icon(Icons.directions_run),
        if (emotionalCategory == 1)
          Image.asset(
            'assets/images/Emotional-mini.png',
            width: 20,
            height: 20,
          ),
        if (environmentalCategory == 1)
          Image.asset(
            'assets/images/Environmental-mini.png',
            width: 20,
            height: 20,
          ),
        if (financialCategory == 1)
          Image.asset(
            'assets/images/Financial-mini.png',
            width: 20,
            height: 20,
          ),
        if (intellectualCategory == 1)
          Image.asset(
            'assets/images/Intellectual-mini.png',
            width: 20,
            height: 20,
          ),
        if (occupationalCategory == 1)
          Image.asset(
            'assets/images/Occupational-mini.png',
            width: 20,
            height: 20,
          ),
        if (physicalCategory == 1)
          Image.asset(
            'assets/images/Physical-mini.png',
            width: 20,
            height: 20,
          ),
        if (socialCategory == 1)
          Image.asset(
            'assets/images/Social-mini.png',
            width: 20,
            height: 20,
          ),
        if (spiritualCategory == 1)
          Image.asset(
            'assets/images/Spiritual-mini.png',
            width: 20,
            height: 20,
          ),
        Text(' $totalUserPoints'),
      ],
    );


  }

  Future<String> _userTextInput(String userName, String userLoggedIn, String currentChallenge, String teamId) async {
    try {
      // Fetch and display team details
      int adjustedUserCount = await getTeamDetails(teamId);
      print(adjustedUserCount);

      // Get the challenges collection reference
      CollectionReference challengesCollection = FirebaseFirestore.instance.collection('challenges');

      // Fetch documents from the challenges collection
      QuerySnapshot challengesSnapshot = await challengesCollection.where('challengeDataList', arrayContains: {'challengeTitle': currentChallenge}).get();

      // Default value in case it's not found
      String userTyping = "not_typing";

      // Iterate through the documents and display confirmation message
      challengesSnapshot.docs.forEach((challengeDoc) {
        Map<String, dynamic> challengeData = challengeDoc.data() as Map<String, dynamic>;

        // Assuming userLoggedIn_stats is an array
        List<dynamic> userTextInput = challengeData['${userName}_quotes'] ?? [];

        // Check if there's an array with today's date
        Map<String, dynamic>? todayEntry = userTextInput.firstWhere(
              (entry) => entry['date'] == DateFormat('MMMM dd, yyyy').format(DateTime.now()),
          orElse: () => null,
        );

        // If an entry for today exists, return the 'input' field
        if (todayEntry != null && todayEntry.containsKey('input')) {
          userTyping = todayEntry['input'].toString();
        } else {
          // If userTyping field exists in challengeData, use it
          if (challengeData.containsKey('userTyping')) {
            userTyping = challengeData['userTyping'].toString();
          }
        }

        // Print the userTyping content to the console
        print('User Typing for $userName: $userTyping');
      });

      // Check if userLoggedIn is equal to userName and userTyping is 'true'
      if (userLoggedIn == userName && userTyping == 'true') {
        return 'typing'; // Return a string indicating the user is typing
      } else {
        return userTyping; // Return the 'input' field or "not_typing"
      }
    } catch (e) {
      // Handle exceptions here, if needed
      print('Error in _userTextInput: $e');
      return 'error'; // Return a default value or handle the error accordingly
    }
  }




  Future<void> _showTypeResponseDialog(String userName, String userLoggedIn, String currentChallenge, String teamId) async {
    try {
      // Fetch and display team details
      int adjustedUserCount = await getTeamDetails(teamId);
      TextEditingController inputController = TextEditingController();

      return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Type Response below'),
            content: TextField(
              controller: inputController,
              decoration: InputDecoration(
                hintText: 'Enter your response',
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () async {
                  // Retrieve the entered text
                  String enteredText = inputController.text.trim();

                  // Add your logic for confirming completion here
                  Navigator.of(context).pop();

                  // Get the challenges collection reference
                  CollectionReference challengesCollection = FirebaseFirestore.instance.collection('challenges');

                  // Fetch documents from the challenges collection
                  QuerySnapshot challengesSnapshot = await challengesCollection.where('challengeDataList', arrayContains: {'challengeTitle': currentChallenge}).get();

                  // Get the current date in the desired format
                  String formattedDate = DateFormat('MMMM dd, yyyy').format(DateTime.now());

                  // Iterate through the documents and update if challengeTitle matches
                  challengesSnapshot.docs.forEach((challengeDoc) async {
                    Map<String, dynamic> challengeData = challengeDoc.data() as Map<String, dynamic>;

                    // Assuming userName_stats is an array
                    List<dynamic> userNameStats = challengeData['${userName}_quotes'] ?? [];

                    // Create a new array element
                    Map<String, dynamic> newStatsElement = {
                      'input': enteredText,
                      'date': formattedDate,
                    };

                    // Update the document in the challenges collection
                    await challengesCollection.doc(challengeDoc.id).update({
                      '${userName}_quotes': FieldValue.arrayUnion([newStatsElement]),
                    });
                  });
                },
                child: Text('Save'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancel'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      // Handle exceptions here, if needed
      print('Error in _showConfirmationDialog: $e');
    }
  }


  void openTeamDetailsDialog(BuildContext context, String teamId) async {
    print(teamId);

    try {
      // Fetch team users from Firestore
      List<dynamic> users = await getTeamUsers(teamId);

      // Show dialog with team details
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Team Details'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Text('Team ID: $teamId'),
              Text('All members:'),
              const SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: users.map<Widget>((user) => Text(user.toString())).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      print('Error opening team details dialog: $e');
      // Show error message
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to load team details: $e'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Close'),
            ),
          ],
        ),
      );
    }
  }
  Future<void> _showStatsPopup(BuildContext context, String teamId) async {
    try {
      // Fetch the team document based on the team ID
      DocumentSnapshot teamSnapshot = await FirebaseFirestore.instance
          .collection('teams')
          .doc(teamId)
          .get();

      if (teamSnapshot.exists) {
        Map<String, dynamic> eventData =
        teamSnapshot.data() as Map<String, dynamic>;

        // Check if user_events field exists
        if (eventData.containsKey('user_events')) {
          List<dynamic> userEvents = eventData['user_events'];

          // Get formatted current date
          String formattedCurrentDate = _formatCurrentDate();

          // Show a dialog with matching stats
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Teammates Going'),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: userEvents
                        .map((event) => _getMatchingStats(event, formattedCurrentDate))
                        .expand((stats) => stats)
                        .toList(),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Close'),
                  ),
                ],
              );
            },
          );
        } else {
          print('user_events field not found in team document');
        }
      } else {
        print('Team document not found for $teamId');
      }
    } catch (e) {
      print('Error showing stats popup: $e');
    }
  }

  List<Widget> _getMatchingStats(Map<String, dynamic> event, String currentDate) {
    List<Widget> matchingStats = [];

    if (event is Map<String, dynamic>) {
      event.keys.where((key) => key.endsWith('_stats')).forEach((statKey) {
        List<String> stats = (event[statKey] as List<dynamic>).cast<String>();

        stats.forEach((dateString) {
          // Compare date with current date
          if (dateString == currentDate) {
            matchingStats.add(Text(statKey.substring(0, statKey.length - 6)));
          }
        });
      });
    }

    return matchingStats;
  }

  String _formatCurrentDate() {
    // Get current date and format it to match the Firestore document date format
    DateTime currentDate = DateTime.now();
    String formattedDate = DateFormat('MMMM dd yyyy').format(currentDate);
    return formattedDate;
  }



  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Style.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          const TopBar(isCameraPage: false, text: 'Team'),
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height -
                100 -
                (Platform.isIOS ? 90 : 60),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Style.sectionTitle('Team Stories'),
                  const Stories(), // Add the Stories widget here
                  const SizedBox(height: 20),
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          // Show a loading indicator while creating a team
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                          );

                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SearchScreen(initialTabIndex: 1),
                            ),
                          );

                          // Introduce a delay of 1 second before reloading the team list
                          // await Future.delayed(Duration(seconds: 4));

                          // After creating a team and the delay, reload the team list
                          _loadCurrentUser();

                          // Close the loading indicator dialog
                          Navigator.pop(context);
                        },
                        child: Text('Create Team OR Community'),
                      ),
                      SizedBox(height: 8), // Add spacing between the buttons row and the "Create Team OR Community" button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center, // Align buttons in the center horizontally
                        children: [
                          Flexible(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const CreateEvent(),
                                  ),
                                );
                                // Handle the "Create an event/activity" button tap
                                // e.g., Navigator.push(context, MaterialPageRoute(builder: (context) => CreateEventActivityScreen()));
                              },
                              child: Text('Create Event'),
                            ),
                          ),
                          SizedBox(width: 8), // Add spacing between buttons
                          Flexible(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const CreateChallenge(),
                                  ),
                                );
                                // Handle the "Create a team" button tap
                                // e.g., Navigator.push(context, MaterialPageRoute(builder: (context) => CreateTeamScreen()));
                              },
                              child: Text('Create Challenge'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),


                  const SizedBox(height: 30),
              ExpansionTile(
                title: Style.sectionTitle('Your Teams'),
                children: [
                  Style.sectionTitle('Teams'),
                  const SizedBox(height: 10),
                  // Display the current list of friends IDs

                  FutureBuilder<List<String>>(
                    future: _getTeamIds(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasError || snapshot.data == null) {
                          return ListTile(
                            title: Text('Error loading team IDs'),
                          );
                        } else {
                          // Display team IDs and users
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: snapshot.data!.map((teamId) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      // Add an edit icon here
                                      GestureDetector(
                                        onTap: () {
                                          // Handle the edit action, e.g., navigate to edit team screen
                                          print('Edit team tapped for team: $teamId');

                                        },
                                        child: const Icon(Icons.chat),
                                      ),
                                      const SizedBox(width: 8), // Add some spacing between the icon and text
                                      FutureBuilder<String>(
                                        future: _getTeamName(teamId),
                                        builder: (context, teamNameSnapshot) {
                                          if (teamNameSnapshot.connectionState == ConnectionState.done) {
                                            if (teamNameSnapshot.hasError || teamNameSnapshot.data == null) {
                                              return Text('Unknown Team');
                                            } else {
                                              return Padding(
                                                padding: const EdgeInsets.only(left: 16),
                                                child: FutureBuilder<String>(
                                                  future: _getTeamName(teamId),
                                                  builder: (context, teamNameSnapshot) {
                                                    if (teamNameSnapshot.connectionState == ConnectionState.done) {
                                                      if (teamNameSnapshot.hasError || teamNameSnapshot.data == null) {
                                                        return Text('Unknown Team');
                                                      } else {
                                                        return Row(
                                                          children: [
                                                            Text(
                                                              '${teamNameSnapshot.data}',
                                                              style: const TextStyle(
                                                                fontSize: 25, // Adjust the font size as needed
                                                                fontWeight: FontWeight.bold,
                                                                color: Colors.black, // Adjust the text color as needed
                                                              ),
                                                            ),
                                                            SizedBox(width: 5), // Adjust the spacing between text and icon
                                                            IconButton(
                                                              icon: Icon(Icons.info),
                                                              onPressed: () {
                                                                openTeamDetailsDialog(context, teamId); // Call the function to open dialog
                                                              },
                                                            ),
                                                          ],
                                                        );
                                                      }
                                                    } else {
                                                      return CircularProgressIndicator();
                                                    }
                                                  },
                                                ),
                                              );


                                            }
                                          } else {
                                            return CircularProgressIndicator();
                                          }
                                        },
                                      ),
                                      FutureBuilder<Map<String, dynamic>>(
                                        future: _getEvents(teamId),
                                        builder: (context, eventSnapshot) {
                                          if (eventSnapshot.connectionState == ConnectionState.done) {
                                            if (eventSnapshot.hasError || eventSnapshot.data == null || eventSnapshot.data!.isEmpty) {
                                              return Text('Unknown Event');
                                            } else {
                                              String eventTitle = eventSnapshot.data?['eventTitle'] ?? 'Unknown Title';
                                              // Check if the event data is not empty before rendering
                                              if (eventSnapshot.data!.isNotEmpty) {
                                                return Padding(
                                                  padding: const EdgeInsets.only(left: 0),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          if (eventSnapshot.data?['eventCreator'] != '')
                                                          const Text(
                                                            'Events Today',
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.black87,
                                                            ),
                                                          ),
                                                          const SizedBox(width: 0), // Adding some space between the texts
                                                          if (eventSnapshot.data?['eventCreator'] != '')
                                                          IconButton(
                                                            onPressed: () async {
                                                              await _showStatsPopup(context, teamId);
                                                            },
                                                            icon: Icon(Icons.info),
                                                          ),
                                                        ],
                                                      ),

                                                      Text(
                                                        '$eventTitle',
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      if (eventSnapshot.data?['startTime'] != null && eventSnapshot.data?['endTime'] != null) // Check if both startTime and endTime are present
                                                        Row(
                                                          children: [
                                                            Text(
                                                              '${eventSnapshot.data?['startTime'] ?? 'Unknown'}',
                                                              style: const TextStyle(
                                                                fontSize: 12,
                                                                color: Colors.black87,
                                                              ),
                                                            ),
                                                            const SizedBox(width: 5), // Adding some space between the texts
                                                            Text(
                                                              '${eventSnapshot.data?['endTime'] ?? 'Unknown'}',
                                                              style: const TextStyle(
                                                                fontSize: 12,
                                                                color: Colors.black87,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      if (eventSnapshot.data?['attending'] != '') // Check if attending data is present
                                                        Text(
                                                          'Attending: ${eventSnapshot.data?['attending']}',
                                                          style: const TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.black87,
                                                          ),
                                                        ),
                                                      if (eventSnapshot.data?['eventCreator'] != '') // Check if attending data is present
                                                        Text(
                                                          'host: ${eventSnapshot.data?['eventCreator']}',
                                                          style: const TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.black87,
                                                          ),
                                                        ),
                                                      if (eventSnapshot.data?['eventCreator'] != '') // Check if attending data is present
                                                        ElevatedButton(
                                                          onPressed: () async {
                                                            String currentUserLoggedIn = await _loadCurrentUserName() as String;
                                                            _incrementAttendField(teamId, currentUserLoggedIn);
                                                            setState(() {});
                                                          },
                                                          child: Text('Attend?'),
                                                        ),

                                                    ],
                                                  ),
                                                );
                                              } else {
                                                return SizedBox(); // Return an empty SizedBox if event data is empty
                                              }
                                            }
                                          } else {
                                            return CircularProgressIndicator();
                                          }
                                        },
                                      ),



                                    ],
                                  ),

                                  const SizedBox(height: 8),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey[300]!),
                                      borderRadius: BorderRadius.all(Radius.circular(8)),
                                    ),
                                    child: ExpansionTile(
                                      title: Text('Challenges'),
                                      children: [

                                        FutureBuilder<List<String>>(
                                          future: _getChallengeTitles(teamId),
                                          builder: (context, challengeTitlesSnapshot) {
                                            if (challengeTitlesSnapshot.connectionState == ConnectionState.done) {
                                              if (challengeTitlesSnapshot.hasError || challengeTitlesSnapshot.data == null) {
                                                return Text('Error loading team challenges for $teamId');
                                              } else {
                                                // Display list of challenge titles
                                                return Column(

                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: challengeTitlesSnapshot.data!.map((challengeTitle) {

                                                    // Add this line to print the challengeDocRef
                                                    return Container(
                                                      decoration: BoxDecoration(
                                                        border: Border.all(color: Colors.grey[300]!),
                                                        borderRadius: BorderRadius.all(Radius.circular(8)),
                                                      ),
                                                      child: ExpansionTile(
                                                        title: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Text('$challengeTitle'),
                                                            FutureBuilder<Widget>(

                                                              future: challengeStreaksAndPoints(challengeTitle, teamId),
                                                              builder: (context, snapshot) {
                                                                if (snapshot.connectionState == ConnectionState.waiting) {
                                                                  return CircularProgressIndicator(); // Show a loading indicator while fetching data
                                                                } else if (snapshot.hasError) {
                                                                  return Text('Error loading data'); // Show an error message if there's an error
                                                                } else {
                                                                  return snapshot.data!; // Display the fetched data
                                                                }
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                        children: [
                                                          FutureBuilder<List<String>>(
                                                            future: _getStatusForChallenge(teamId, challengeTitle),
                                                            builder: (context, statusListSnapshot) {
                                                              if (statusListSnapshot.connectionState == ConnectionState.done) {
                                                                if (statusListSnapshot.hasError || statusListSnapshot.data == null) {
                                                                  return Text('Error loading status for $challengeTitle');
                                                                } else {
                                                                  // Check if there is any status containing 'pending'
                                                                  bool containsPending = statusListSnapshot.data!.any((userStatus) => userStatus.contains('pending'));

                                                                  // Display list of users only if there is no 'pending' status
                                                                  if (!containsPending) {
                                                                    return Column(
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      children: statusListSnapshot.data!.map((userStatus) {
                                                                        // Split the userStatus into user and status
                                                                        List<String> parts = userStatus.split(':');
                                                                        String user = parts[0].trim();
                                                                        String status = parts[1].trim();

                                                                        // Define the color based on status
                                                                        Color circleColor = status == 'Accept' ? Colors.green : Colors.red;

                                                                        // Define the icon based on the userStatus
                                                                        IconData icon = userStatus.contains('host') ? Icons.person : Icons.circle;

                                                                        // Button text
                                                                        String buttonText = 'Completed';



                                                                        Future<String?> userNameFuture = _loadCurrentUserName();

                                                                        return FutureBuilder<String?>(
                                                                          future: userNameFuture,
                                                                          builder: (context, userNameSnapshot) {
                                                                            if (userNameSnapshot.connectionState == ConnectionState.done) {
                                                                              if (userNameSnapshot.hasError || userNameSnapshot.data == null) {
                                                                                return Text('Error loading current user name');
                                                                              } else {
                                                                                // Check if the current user's name matches the displayed user's name
                                                                                bool isCurrentUser = user == userNameSnapshot.data!;

                                                                                return Padding(
                                                                                  padding: const EdgeInsets.only(left: 16),
                                                                                  child: Column(
                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                    children: [
                                                                                      Row(
                                                                                        children: [
                                                                                          // Circle or person icon
                                                                                          Icon(icon, color: circleColor, size: 12),
                                                                                          const SizedBox(width: 8), // Add spacing between the icon and text
                                                                                          Expanded(
                                                                                            child: Column(
                                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                                              children: [
                                                                                                Text('$user: $status'),

                                                                                            FutureBuilder<Map<String, dynamic>>(
                                                                                              future: _displayUserPoints(user, userNameSnapshot.data!, challengeTitle, teamId),
                                                                                              builder: (context, displayTextSnapshot) {
                                                                                                if (displayTextSnapshot.connectionState == ConnectionState.done) {
                                                                                                  Map<String, dynamic>? result = displayTextSnapshot.data;

                                                                                                  // Check if the result is not null before accessing its values
                                                                                                  if (result != null) {
                                                                                                    int countOfArraysForCurrentDate = result['countOfArraysForCurrentDate'] as int? ?? 0;
                                                                                                    int adjustedUserCount = result['adjustedUserCount'] as int? ?? 0;
                                                                                                    int countOfArraysForDifferentDate = result['countOfArraysForDifferentDate'] as int? ?? 0;
                                                                                                    int countOfArraysForConsistencyDates = result['countOfArraysForConsistencyDates'] as int? ?? 0;
                                                                                                    int userTyping = result['userTyping'] as int? ?? 0;
                                                                                                    int challengeType = result['challengeType'] as int? ?? 0;
                                                                                                    int emotionalCategory = result['emotionalCategory'] as int? ?? 0;
                                                                                                    int environmentalCategory = result['environmentalCategory'] as int? ?? 0;
                                                                                                    int financialCategory = result['financialCategory'] as int? ?? 0;
                                                                                                    int intellectualCategory = result['intellectualCategory'] as int? ?? 0;
                                                                                                    int occupationalCategory = result['occupationalCategory'] as int? ?? 0;
                                                                                                    int physicalCategory = result['physicalCategory'] as int? ?? 0;
                                                                                                    int socialCategory = result['socialCategory'] as int? ?? 0;
                                                                                                    int spiritualCategory = result['spiritualCategory'] as int? ?? 0;



                                                                                                    print(countOfArraysForCurrentDate);
                                                                                                    print(adjustedUserCount);
                                                                                                    print("Status please: $userTyping");

                                                                                                    // Add a condition to not display the Column when challengeType is 1
                                                                                                    // Add a condition to not display the Column when challengeType is 1 and user is the same as userNameSnapshot.data!
                                                                                                    if (!(challengeType == 1 && user != userNameSnapshot.data! || challengeType == 2 && user == userNameSnapshot.data!)){
                                                                                                      print(countOfArraysForCurrentDate);
                                                                                                      print(adjustedUserCount);
                                                                                                      print("Status please: $userTyping");

                                                                                                      // Now you can use these values as needed

                                                                                                      return Column(
                                                                                                        children: [
                                                                                                          Row(
                                                                                                            children: [
                                                                                                              Text('$countOfArraysForCurrentDate/$adjustedUserCount teammates confirmed completion'),
                                                                                                            ],
                                                                                                          ),
                                                                                                          Row(
                                                                                                            children: [
                                                                                                              if (emotionalCategory == 1)
                                                                                                                Image.asset(
                                                                                                                  'assets/images/Emotional-mini.png',
                                                                                                                  width: 30,
                                                                                                                  height: 30,
                                                                                                                ),
                                                                                                              if (environmentalCategory == 1)
                                                                                                                Image.asset(
                                                                                                                  'assets/images/Environmental-mini.png',
                                                                                                                  width: 30,
                                                                                                                  height: 30,
                                                                                                                ),
                                                                                                              if (financialCategory == 1)
                                                                                                                Image.asset(
                                                                                                                  'assets/images/Financial-mini.png',
                                                                                                                  width: 30,
                                                                                                                  height: 30,
                                                                                                                ),
                                                                                                              if (intellectualCategory == 1)
                                                                                                                Image.asset(
                                                                                                                  'assets/images/Intellectual-mini.png',
                                                                                                                  width: 30,
                                                                                                                  height: 30,
                                                                                                                ),
                                                                                                              if (occupationalCategory == 1)
                                                                                                                Image.asset(
                                                                                                                  'assets/images/Occupational-mini.png',
                                                                                                                  width: 30,
                                                                                                                  height: 30,
                                                                                                                ),
                                                                                                              if (physicalCategory == 1)
                                                                                                                Image.asset(
                                                                                                                  'assets/images/Physical-mini.png',
                                                                                                                  width: 30,
                                                                                                                  height: 30,
                                                                                                                ),
                                                                                                              if (socialCategory == 1)
                                                                                                                Image.asset(
                                                                                                                  'assets/images/Social-mini.png',
                                                                                                                  width: 30,
                                                                                                                  height: 30,
                                                                                                                ),
                                                                                                              if (spiritualCategory == 1)
                                                                                                                Image.asset(
                                                                                                                  'assets/images/Spiritual-mini.png',
                                                                                                                  width: 30,
                                                                                                                  height: 30,
                                                                                                                ),

                                                                                                              SizedBox(width: 8),
                                                                                                              Text('$countOfArraysForDifferentDate'),
                                                                                                              SizedBox(width: 16),
                                                                                                              const Icon(
                                                                                                                Icons.local_fire_department_sharp,
                                                                                                                color: Colors.yellow,
                                                                                                              ),
                                                                                                              SizedBox(width: 8),
                                                                                                              Text('$countOfArraysForConsistencyDates'),
                                                                                                            ],
                                                                                                          ),
                                                                                                          if (userTyping == 1)
                                                                                                            ElevatedButton(
                                                                                                              onPressed: () {
                                                                                                                // Handle button press here
                                                                                                                // For example, mark the user as completed
                                                                                                              },
                                                                                                              child: const Text("Hello"),
                                                                                                            ),
                                                                                                        ],
                                                                                                      );
                                                                                                    } else {
                                                                                                      // ChallengeType is 1 and user is the same as userNameSnapshot.data!, do not display the Column
                                                                                                      return SizedBox.shrink();
                                                                                                    }



                                                                                                  } else {
                                                                                                    // Handle the case where result is null
                                                                                                    return Text('Error: Null result from _displayUserPoints');
                                                                                                  }
                                                                                                } else {
                                                                                                  return CircularProgressIndicator();
                                                                                                }
                                                                                              },
                                                                                            ),




                                                                                                // Add the new FutureBuilder for userTextInput
                                                                                                FutureBuilder<String>(
                                                                                                  future: _userTextInput(user, userNameSnapshot.data!, challengeTitle, teamId), // Assuming _userTextInput returns a Future<String>
                                                                                                  builder: (context, userTextInputSnapshot) {
                                                                                                    if (userTextInputSnapshot.connectionState == ConnectionState.done) {
                                                                                                      if (userTextInputSnapshot.hasError) {
                                                                                                        return Text('Error loading user text input');
                                                                                                      } else {
                                                                                                        // Display the user text input
                                                                                                        String userTypingStatus = userTextInputSnapshot.data ?? 'not_typing';

                                                                                                        if (userTypingStatus == 'typing') {
                                                                                                          // Display a button when user is typing
                                                                                                          return ElevatedButton(
                                                                                                            onPressed: () {
                                                                                                              _showTypeResponseDialog(user, userNameSnapshot.data!, challengeTitle, teamId);
                                                                                                              // Handle button press here
                                                                                                              // For example, open a text input field for the user to type a response
                                                                                                            },
                                                                                                            child: const Text('Type response'),
                                                                                                          );
                                                                                                        } else if (userTypingStatus == 'not_typing' || userTypingStatus == 'true' || userTypingStatus == 'false') {
                                                                                                          return const Text('');
                                                                                                        } else {
                                                                                                          // Display a message when the user is not typing
                                                                                                          return Text(userTypingStatus);
                                                                                                        }

                                                                                                      }
                                                                                                    } else {
                                                                                                      return CircularProgressIndicator();
                                                                                                    }
                                                                                                  },
                                                                                                ),
                                                                                              ],
                                                                                            ),
                                                                                          ),
                                                                                          // Completed button (conditional rendering)
                                                                                          if (!isCurrentUser)
                                                                                            ElevatedButton(
                                                                                              onPressed: () {
                                                                                                // Handle button press here
                                                                                                // For example, mark the user as completed
                                                                                                _showConfirmationDialog(user, userNameSnapshot.data!, challengeTitle, teamId);
                                                                                              },
                                                                                              child: Text(buttonText),
                                                                                            ),
                                                                                        ],
                                                                                      ),
                                                                                      Divider(), // Line between users
                                                                                    ],
                                                                                  ),
                                                                                );
                                                                              }
                                                                            } else {
                                                                              return CircularProgressIndicator();
                                                                            }
                                                                          },
                                                                        );



                                                                      }).toList(),
                                                                    );
                                                                  } else {
                                                                    // Return a message indicating that there are 'pending' statuses
                                                                    return Text('This challenge contains pending statuses.');
                                                                  }
                                                                }
                                                              } else {
                                                                return CircularProgressIndicator();
                                                              }
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  }).toList(),
                                                );
                                              }
                                            } else {
                                              return CircularProgressIndicator();
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),



                                  const SizedBox(height: 20),
                                ],
                              );
                            }).toList(),
                          );
                        }
                      } else {
                        // Display loading indicator while fetching data
                        return ListTile(
                          title: CircularProgressIndicator(),
                        );
                      }
                    },
                  ),







                ],
              ),
                  const SizedBox(height: 30),
                  ExpansionTile(
                    title: Style.sectionTitle('Your Communities'),
                    children: [
                      ExpansionTile(
                        title: Style.sectionTitle('Communities'),
                        children: [
                      const SizedBox(height: 10),
                      // Display the current list of friends IDs

                      FutureBuilder<List<String>>(
                        future: _getTeamIds(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.done) {
                            if (snapshot.hasError || snapshot.data == null) {
                              return ListTile(
                                title: Text('Error loading team IDs'),
                              );
                            } else {
                              // Display team IDs and users
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: snapshot.data!.map((teamId) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          // Add an edit icon here
                                          GestureDetector(
                                            onTap: () {
                                              // Handle the edit action, e.g., navigate to edit team screen
                                              print('Edit team tapped for team: $teamId');

                                            },
                                            child: const Icon(Icons.chat),
                                          ),
                                          const SizedBox(width: 8), // Add some spacing between the icon and text
                                          FutureBuilder<String>(
                                            future: _getTeamName(teamId),
                                            builder: (context, teamNameSnapshot) {
                                              if (teamNameSnapshot.connectionState == ConnectionState.done) {
                                                if (teamNameSnapshot.hasError || teamNameSnapshot.data == null) {
                                                  return Text('Unknown Team');
                                                } else {
                                                  return Padding(
                                                    padding: const EdgeInsets.only(left: 16),
                                                    child: FutureBuilder<String>(
                                                      future: _getTeamName(teamId),
                                                      builder: (context, teamNameSnapshot) {
                                                        if (teamNameSnapshot.connectionState == ConnectionState.done) {
                                                          if (teamNameSnapshot.hasError || teamNameSnapshot.data == null) {
                                                            return Text('Unknown Team');
                                                          } else {
                                                            return Row(
                                                              children: [
                                                                Text(
                                                                  '${teamNameSnapshot.data}',
                                                                  style: const TextStyle(
                                                                    fontSize: 25, // Adjust the font size as needed
                                                                    fontWeight: FontWeight.bold,
                                                                    color: Colors.black, // Adjust the text color as needed
                                                                  ),
                                                                ),
                                                                SizedBox(width: 5), // Adjust the spacing between text and icon
                                                                IconButton(
                                                                  icon: Icon(Icons.info),
                                                                  onPressed: () {
                                                                    openTeamDetailsDialog(context, teamId); // Call the function to open dialog
                                                                  },
                                                                ),
                                                              ],
                                                            );
                                                          }
                                                        } else {
                                                          return CircularProgressIndicator();
                                                        }
                                                      },
                                                    ),
                                                  );


                                                }
                                              } else {
                                                return CircularProgressIndicator();
                                              }
                                            },
                                          ),
                                          // FutureBuilder<String>(
                                          //   future: _getEvents(teamId),
                                          //   builder: (context, eventTitleSnapshot) {
                                          //     if (eventTitleSnapshot.connectionState == ConnectionState.done) {
                                          //       if (eventTitleSnapshot.hasError || eventTitleSnapshot.data == null) {
                                          //         return Text('Unknown Event');
                                          //       } else {
                                          //         return Padding(
                                          //           padding: const EdgeInsets.only(left: 16),
                                          //           child: Text(
                                          //             '${eventTitleSnapshot.data}',
                                          //             style: const TextStyle(
                                          //               fontSize: 25, // Adjust the font size as needed
                                          //               fontWeight: FontWeight.bold,
                                          //               color: Colors.black, // Adjust the text color as needed
                                          //             ),
                                          //           ),
                                          //         );
                                          //       }
                                          //     } else {
                                          //       return CircularProgressIndicator();
                                          //     }
                                          //   },
                                          // ),

                                        ],
                                      ),

                                      const SizedBox(height: 8),
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey[300]!),
                                          borderRadius: BorderRadius.all(Radius.circular(8)),
                                        ),
                                        child: ExpansionTile(
                                          title: Text('Challenges'),
                                          children: [

                                            FutureBuilder<List<String>>(
                                              future: _getChallengeTitles(teamId),
                                              builder: (context, challengeTitlesSnapshot) {
                                                if (challengeTitlesSnapshot.connectionState == ConnectionState.done) {
                                                  if (challengeTitlesSnapshot.hasError || challengeTitlesSnapshot.data == null) {
                                                    return Text('Error loading team challenges for $teamId');
                                                  } else {
                                                    // Display list of challenge titles
                                                    return Column(

                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: challengeTitlesSnapshot.data!.map((challengeTitle) {

                                                        // Add this line to print the challengeDocRef
                                                        return Container(
                                                          decoration: BoxDecoration(
                                                            border: Border.all(color: Colors.grey[300]!),
                                                            borderRadius: BorderRadius.all(Radius.circular(8)),
                                                          ),
                                                          child: ExpansionTile(
                                                            title: Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                Text('$challengeTitle'),
                                                                FutureBuilder<Widget>(

                                                                  future: challengeStreaksAndPoints(challengeTitle, teamId),
                                                                  builder: (context, snapshot) {
                                                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                                                      return CircularProgressIndicator(); // Show a loading indicator while fetching data
                                                                    } else if (snapshot.hasError) {
                                                                      return Text('Error loading data'); // Show an error message if there's an error
                                                                    } else {
                                                                      return snapshot.data!; // Display the fetched data
                                                                    }
                                                                  },
                                                                ),
                                                              ],
                                                            ),
                                                            children: [
                                                              FutureBuilder<List<String>>(
                                                                future: _getStatusForChallenge(teamId, challengeTitle),
                                                                builder: (context, statusListSnapshot) {
                                                                  if (statusListSnapshot.connectionState == ConnectionState.done) {
                                                                    if (statusListSnapshot.hasError || statusListSnapshot.data == null) {
                                                                      return Text('Error loading status for $challengeTitle');
                                                                    } else {
                                                                      // Check if there is any status containing 'pending'
                                                                      bool containsPending = statusListSnapshot.data!.any((userStatus) => userStatus.contains('pending'));

                                                                      // Display list of users only if there is no 'pending' status
                                                                      if (!containsPending) {
                                                                        return Column(
                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                          children: statusListSnapshot.data!.map((userStatus) {
                                                                            // Split the userStatus into user and status
                                                                            List<String> parts = userStatus.split(':');
                                                                            String user = parts[0].trim();
                                                                            String status = parts[1].trim();

                                                                            // Define the color based on status
                                                                            Color circleColor = status == 'Accept' ? Colors.green : Colors.red;

                                                                            // Define the icon based on the userStatus
                                                                            IconData icon = userStatus.contains('host') ? Icons.person : Icons.circle;

                                                                            // Button text
                                                                            String buttonText = 'Completed';



                                                                            Future<String?> userNameFuture = _loadCurrentUserName();

                                                                            return FutureBuilder<String?>(
                                                                              future: userNameFuture,
                                                                              builder: (context, userNameSnapshot) {
                                                                                if (userNameSnapshot.connectionState == ConnectionState.done) {
                                                                                  if (userNameSnapshot.hasError || userNameSnapshot.data == null) {
                                                                                    return Text('Error loading current user name');
                                                                                  } else {
                                                                                    // Check if the current user's name matches the displayed user's name
                                                                                    bool isCurrentUser = user == userNameSnapshot.data!;

                                                                                    return Padding(
                                                                                      padding: const EdgeInsets.only(left: 16),
                                                                                      child: Column(
                                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                                        children: [
                                                                                          Row(
                                                                                            children: [
                                                                                              // Circle or person icon
                                                                                              Icon(icon, color: circleColor, size: 12),
                                                                                              const SizedBox(width: 8), // Add spacing between the icon and text
                                                                                              Expanded(
                                                                                                child: Column(
                                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                  children: [
                                                                                                    Text('$user: $status'),

                                                                                                    FutureBuilder<Map<String, dynamic>>(
                                                                                                      future: _displayUserPoints(user, userNameSnapshot.data!, challengeTitle, teamId),
                                                                                                      builder: (context, displayTextSnapshot) {
                                                                                                        if (displayTextSnapshot.connectionState == ConnectionState.done) {
                                                                                                          Map<String, dynamic>? result = displayTextSnapshot.data;

                                                                                                          // Check if the result is not null before accessing its values
                                                                                                          if (result != null) {
                                                                                                            int countOfArraysForCurrentDate = result['countOfArraysForCurrentDate'] as int? ?? 0;
                                                                                                            int adjustedUserCount = result['adjustedUserCount'] as int? ?? 0;
                                                                                                            int countOfArraysForDifferentDate = result['countOfArraysForDifferentDate'] as int? ?? 0;
                                                                                                            int countOfArraysForConsistencyDates = result['countOfArraysForConsistencyDates'] as int? ?? 0;
                                                                                                            int userTyping = result['userTyping'] as int? ?? 0;
                                                                                                            int challengeType = result['challengeType'] as int? ?? 0;
                                                                                                            int emotionalCategory = result['emotionalCategory'] as int? ?? 0;
                                                                                                            int environmentalCategory = result['environmentalCategory'] as int? ?? 0;
                                                                                                            int financialCategory = result['financialCategory'] as int? ?? 0;
                                                                                                            int intellectualCategory = result['intellectualCategory'] as int? ?? 0;
                                                                                                            int occupationalCategory = result['occupationalCategory'] as int? ?? 0;
                                                                                                            int physicalCategory = result['physicalCategory'] as int? ?? 0;
                                                                                                            int socialCategory = result['socialCategory'] as int? ?? 0;
                                                                                                            int spiritualCategory = result['spiritualCategory'] as int? ?? 0;



                                                                                                            print(countOfArraysForCurrentDate);
                                                                                                            print(adjustedUserCount);
                                                                                                            print("Status please: $userTyping");

                                                                                                            // Add a condition to not display the Column when challengeType is 1
                                                                                                            // Add a condition to not display the Column when challengeType is 1 and user is the same as userNameSnapshot.data!
                                                                                                            if (!(challengeType == 1 && user != userNameSnapshot.data! || challengeType == 2 && user == userNameSnapshot.data!)){
                                                                                                              print(countOfArraysForCurrentDate);
                                                                                                              print(adjustedUserCount);
                                                                                                              print("Status please: $userTyping");

                                                                                                              // Now you can use these values as needed

                                                                                                              return Column(
                                                                                                                children: [
                                                                                                                  Row(
                                                                                                                    children: [
                                                                                                                      Text('$countOfArraysForCurrentDate/$adjustedUserCount teammates confirmed completion'),
                                                                                                                    ],
                                                                                                                  ),
                                                                                                                  Row(
                                                                                                                    children: [
                                                                                                                      if (emotionalCategory == 1)
                                                                                                                        Image.asset(
                                                                                                                          'assets/images/Emotional-mini.png',
                                                                                                                          width: 30,
                                                                                                                          height: 30,
                                                                                                                        ),
                                                                                                                      if (environmentalCategory == 1)
                                                                                                                        Image.asset(
                                                                                                                          'assets/images/Environmental-mini.png',
                                                                                                                          width: 30,
                                                                                                                          height: 30,
                                                                                                                        ),
                                                                                                                      if (financialCategory == 1)
                                                                                                                        Image.asset(
                                                                                                                          'assets/images/Financial-mini.png',
                                                                                                                          width: 30,
                                                                                                                          height: 30,
                                                                                                                        ),
                                                                                                                      if (intellectualCategory == 1)
                                                                                                                        Image.asset(
                                                                                                                          'assets/images/Intellectual-mini.png',
                                                                                                                          width: 30,
                                                                                                                          height: 30,
                                                                                                                        ),
                                                                                                                      if (occupationalCategory == 1)
                                                                                                                        Image.asset(
                                                                                                                          'assets/images/Occupational-mini.png',
                                                                                                                          width: 30,
                                                                                                                          height: 30,
                                                                                                                        ),
                                                                                                                      if (physicalCategory == 1)
                                                                                                                        Image.asset(
                                                                                                                          'assets/images/Physical-mini.png',
                                                                                                                          width: 30,
                                                                                                                          height: 30,
                                                                                                                        ),
                                                                                                                      if (socialCategory == 1)
                                                                                                                        Image.asset(
                                                                                                                          'assets/images/Social-mini.png',
                                                                                                                          width: 30,
                                                                                                                          height: 30,
                                                                                                                        ),
                                                                                                                      if (spiritualCategory == 1)
                                                                                                                        Image.asset(
                                                                                                                          'assets/images/Spiritual-mini.png',
                                                                                                                          width: 30,
                                                                                                                          height: 30,
                                                                                                                        ),

                                                                                                                      SizedBox(width: 8),
                                                                                                                      Text('$countOfArraysForDifferentDate'),
                                                                                                                      SizedBox(width: 16),
                                                                                                                      const Icon(
                                                                                                                        Icons.local_fire_department_sharp,
                                                                                                                        color: Colors.yellow,
                                                                                                                      ),
                                                                                                                      SizedBox(width: 8),
                                                                                                                      Text('$countOfArraysForConsistencyDates'),
                                                                                                                    ],
                                                                                                                  ),
                                                                                                                  if (userTyping == 1)
                                                                                                                    ElevatedButton(
                                                                                                                      onPressed: () {
                                                                                                                        // Handle button press here
                                                                                                                        // For example, mark the user as completed
                                                                                                                      },
                                                                                                                      child: const Text("Hello"),
                                                                                                                    ),
                                                                                                                ],
                                                                                                              );
                                                                                                            } else {
                                                                                                              // ChallengeType is 1 and user is the same as userNameSnapshot.data!, do not display the Column
                                                                                                              return SizedBox.shrink();
                                                                                                            }



                                                                                                          } else {
                                                                                                            // Handle the case where result is null
                                                                                                            return Text('Error: Null result from _displayUserPoints');
                                                                                                          }
                                                                                                        } else {
                                                                                                          return CircularProgressIndicator();
                                                                                                        }
                                                                                                      },
                                                                                                    ),




                                                                                                    // Add the new FutureBuilder for userTextInput
                                                                                                    FutureBuilder<String>(
                                                                                                      future: _userTextInput(user, userNameSnapshot.data!, challengeTitle, teamId), // Assuming _userTextInput returns a Future<String>
                                                                                                      builder: (context, userTextInputSnapshot) {
                                                                                                        if (userTextInputSnapshot.connectionState == ConnectionState.done) {
                                                                                                          if (userTextInputSnapshot.hasError) {
                                                                                                            return Text('Error loading user text input');
                                                                                                          } else {
                                                                                                            // Display the user text input
                                                                                                            String userTypingStatus = userTextInputSnapshot.data ?? 'not_typing';

                                                                                                            if (userTypingStatus == 'typing') {
                                                                                                              // Display a button when user is typing
                                                                                                              return ElevatedButton(
                                                                                                                onPressed: () {
                                                                                                                  _showTypeResponseDialog(user, userNameSnapshot.data!, challengeTitle, teamId);
                                                                                                                  // Handle button press here
                                                                                                                  // For example, open a text input field for the user to type a response
                                                                                                                },
                                                                                                                child: const Text('Type response'),
                                                                                                              );
                                                                                                            } else if (userTypingStatus == 'not_typing' || userTypingStatus == 'true' || userTypingStatus == 'false') {
                                                                                                              return const Text('');
                                                                                                            } else {
                                                                                                              // Display a message when the user is not typing
                                                                                                              return Text(userTypingStatus);
                                                                                                            }

                                                                                                          }
                                                                                                        } else {
                                                                                                          return CircularProgressIndicator();
                                                                                                        }
                                                                                                      },
                                                                                                    ),
                                                                                                  ],
                                                                                                ),
                                                                                              ),
                                                                                              // Completed button (conditional rendering)
                                                                                              if (!isCurrentUser)
                                                                                                ElevatedButton(
                                                                                                  onPressed: () {
                                                                                                    // Handle button press here
                                                                                                    // For example, mark the user as completed
                                                                                                    _showConfirmationDialog(user, userNameSnapshot.data!, challengeTitle, teamId);
                                                                                                  },
                                                                                                  child: Text(buttonText),
                                                                                                ),
                                                                                            ],
                                                                                          ),
                                                                                          Divider(), // Line between users
                                                                                        ],
                                                                                      ),
                                                                                    );
                                                                                  }
                                                                                } else {
                                                                                  return CircularProgressIndicator();
                                                                                }
                                                                              },
                                                                            );



                                                                          }).toList(),
                                                                        );
                                                                      } else {
                                                                        // Return a message indicating that there are 'pending' statuses
                                                                        return Text('This challenge contains pending statuses.');
                                                                      }
                                                                    }
                                                                  } else {
                                                                    return CircularProgressIndicator();
                                                                  }
                                                                },
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      }).toList(),
                                                    );
                                                  }
                                                } else {
                                                  return CircularProgressIndicator();
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ),



                                      const SizedBox(height: 20),
                                    ],
                                  );
                                }).toList(),
                              );
                            }
                          } else {
                            // Display loading indicator while fetching data
                            return ListTile(
                              title: CircularProgressIndicator(),
                            );
                          }
                        },
                      ),


          ]


                      )

                    ],
                  ),
              ]
            ),
          ),


    ),

        ],

      ),

    );

  }

}

