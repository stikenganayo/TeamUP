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
      Set<String> uniqueDates = Set<String>();
      int countOfArraysForConsistencyDates = 0;
      int countOfArraysForDifferentDate = 0;

      // Iterate through the documents and display confirmation message
      challengesSnapshot.docs.forEach((challengeDoc) {
        Map<String, dynamic> challengeData = challengeDoc.data() as Map<String, dynamic>;

        // Assuming userLoggedIn_stats is an array
        List<dynamic> userLoggedInStats = challengeData['${userName}_stats'] ?? [];

        // Count the number of arrays with the current date
        countOfArraysForCurrentDate += userLoggedInStats.where((statsElement) =>
        statsElement['date'] == formattedDate,
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

      });



      print('Teammates who verified $userName: $countOfArraysForCurrentDate');
      print('Total points for $userName: $countOfArraysForDifferentDate');
      print('Current Streak for $userName: $countOfArraysForConsistencyDates');
      print(adjustedUserCount);

      Map<String, int> result = {
        'countOfArraysForCurrentDate': countOfArraysForCurrentDate,
        'countOfArraysForDifferentDate': countOfArraysForDifferentDate,
        'countOfArraysForConsistencyDates': countOfArraysForConsistencyDates,
        'adjustedUserCount': adjustedUserCount,
      };

      return result;
    } catch (e) {
      // Handle exceptions here, if needed
      print('Error in _showConfirmationDialog: $e');
      return {'countOfArraysForCurrentDate': 0, 'countOfArraysForDifferentDate': 0, 'countOfArraysForConsistencyDates': 0, 'adjustedUserCount': 0}; // Return default values or handle the error accordingly
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

    return Row(
      children: [
        // SizedBox(width: 16), // Adjust the width for more space
        Icon(Icons.local_fire_department_sharp),
        Text(' $minUserCount'),
        Icon(Icons.directions_run), // Add another icon
        Text(' $totalUserPoints'),
      ],
    );
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const SizedBox(width: 16),
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
                                  builder: (context) =>
                                  const SearchScreen(initialTabIndex: 1),
                                ),
                              );

                              // Introduce a delay of 1 second before reloading the team list
                              await Future.delayed(Duration(seconds: 4));

                              // After creating a team and the delay, reload the team list
                              _loadCurrentUser();

                              // Close the loading indicator dialog
                              Navigator.pop(context);
                            },
                            child: Text('Create Team'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
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
                          const SizedBox(width: 8),
                          ElevatedButton(
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
                          const SizedBox(width: 8),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
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
                                                child: Text(
                                                  '${teamNameSnapshot.data}',
                                                  style: const TextStyle(
                                                    fontSize: 25, // Adjust the font size as needed
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black, // Adjust the text color as needed
                                                  ),
                                                ),
                                              );
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

                                                                                                    print(countOfArraysForCurrentDate);
                                                                                                    print(adjustedUserCount);

                                                                                                    // Now you can use these values as needed

                                                                                                    return Column(
                                                                                                      children: [
                                                                                                        Row(
                                                                                                          children: [
                                                                                                            Text('$countOfArraysForCurrentDate/$adjustedUserCount teammates confirmed completion'), // Display additional text based on isCurrentUser
                                                                                                          ],
                                                                                                        ),


                                                                                                        Row(
                                                                                                          children: [
                                                                                                            const Icon(
                                                                                                              Icons.directions_run,
                                                                                                              color: Colors.black26, // Set the icon color to your preference
                                                                                                            ),
                                                                                                            SizedBox(width: 8), // Add some spacing between the icon and text
                                                                                                            Text('$countOfArraysForDifferentDate'),
                                                                                                            SizedBox(width: 16),
                                                                                                            const Icon(
                                                                                                              Icons.local_fire_department_sharp,
                                                                                                              color: Colors.yellow, // Set the icon color to your preference
                                                                                                            ),
                                                                                                            SizedBox(width: 8), // Add some spacing between the icon and text
                                                                                                            Text('$countOfArraysForConsistencyDates'),
                                                                                                          ],
                                                                                                        ),
                                                                                                      ],
                                                                                                    );



                                                                                                  } else {
                                                                                                    // Handle the case where result is null
                                                                                                    return Text('Error: Null result from _displayUserPoints');
                                                                                                  }
                                                                                                } else {
                                                                                                  return CircularProgressIndicator();
                                                                                                }
                                                                                              },
                                                                                            )



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
            ),
          ),
        ],
      ),
    );
  }
}
