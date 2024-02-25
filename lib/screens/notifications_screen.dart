import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';




class StatusButton extends StatefulWidget {
  final String buttonText;
  final String docRef;
  final String collection;
  final String currentStatus;
  final Function(String) onPressed;

  const StatusButton({
    Key? key,
    required this.buttonText,
    required this.docRef,
    required this.collection,
    required this.currentStatus,
    required this.onPressed,
  }) : super(key: key);

  @override
  _StatusButtonState createState() => _StatusButtonState();
}

class _StatusButtonState extends State<StatusButton> {
  @override
  Widget build(BuildContext context) {
    bool isButtonActive = widget.currentStatus == widget.buttonText;

    return ElevatedButton(
      onPressed: () {
        widget.onPressed(widget.buttonText);
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white, backgroundColor: isButtonActive ? Colors.green : null,
      ),
      child: Text(widget.buttonText),
    );
  }
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late User? currentUser;
  List<String> teamIds = [];
  List<Map<String, dynamic>> eventDetails = [];
  List<Map<String, dynamic>> challengeDetails = [];
  String currentUserName = '';

  // New variable to store the current user's name
  String currentUserFullName = '';


  // Set to keep track of added event IDs
  Set<String> _addedEventIds = Set();

  bool showMyCreated = false; // Added to track the selected option


  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        print('Current User Email: ${currentUser!.email}');

        QuerySnapshot userQuerySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: currentUser!.email)
            .limit(1)
            .get();

        if (userQuerySnapshot.docs.isNotEmpty) {
          DocumentSnapshot userSnapshot = userQuerySnapshot.docs.first;
          await _addUserDetails(userSnapshot);

          // Store the name field in currentUserFullName
          currentUserFullName = userSnapshot['name'];

          // Print the name field
          print('Current User Name: $currentUserFullName');
        } else {
          print('User document not found for the current user');
        }
      }
    } catch (e) {
      print('Error loading user document: $e');
    }
  }

  Future<void> _addUserDetails(DocumentSnapshot userSnapshot) async {
    Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;

    print('User Data: $userData');
    print("Are you working?");
    print(userData['team_events']);
    print(userData['user_events']); // New: Print user_events
    print(userData['team_challenges']); // New: Print team_challenges

    eventDetails.clear();
    challengeDetails.clear();

    if (userData.containsKey('team_events')) {
      List<dynamic> teamEvents = userData['team_events'];
      for (Map<String, dynamic> event in teamEvents) {
        await _addEventDetails(event);
      }
    } else {
      print('team_events field not found in user document');
    }

    if (userData.containsKey('team_challenges')) {
      List<dynamic> teamChallenges = userData['team_challenges'];
      for (Map<String, dynamic> challenge in teamChallenges) {
        await _addChallengeDetails(challenge);
      }
    } else {
      print('team_challenges field not found in user document');
    }

    if (userData.containsKey('team_challenges')) {
      List<dynamic> teamChallenges = userData['team_challenges'];
      for (Map<String, dynamic> challenge in teamChallenges) {
        await _addChallengeTemplateDetails(challenge);
      }
    } else {
      print('team_challenges field not found in user document');
    }





    if (userData.containsKey('user_events')) {
      List<dynamic> userEvents = userData['user_events'];
      for (Map<String, dynamic> event in userEvents) {
        await _addEventDetails(event);
      }
    } else {
      print('user_events field not found in user document');
    }

    if (userData.containsKey('team_ids')) {
      setState(() {
        teamIds = List.from(userData['team_ids']);
      });
    } else {
      print('Team_ids field not found in user document');
    }
  }

  Future<void> _addEventDetails(Map<String, dynamic> event) async {
    String eventDocRef = event['eventDocRef'];

    // Check if the event has already been added
    if (_addedEventIds.contains(eventDocRef)) {
      return;
    }

    DocumentSnapshot eventSnapshot = await FirebaseFirestore.instance
        .collection('events')
        .doc(eventDocRef)
        .get();

    if (eventSnapshot.exists) {
      Map<String, dynamic> eventData =
      eventSnapshot.data() as Map<String, dynamic>;

      print('Event Title: ${eventData['eventTitle']}');
      print('Start Date: ${eventData['startDate']}');
      print('Start Time: ${eventData['startTime']}');
      print('Event Location: ${eventData['eventLocation']}');
      print('Status: ${event['status']}');

      eventDetails.add({
        'title': eventData['eventTitle'],
        'startDate': eventData['startDate'],
        'startTime': eventData['startTime'] ?? '',
        'eventLocation': eventData['eventLocation'] ?? '',
        'Created By': eventData['CurrentUserName'],
        'status': event['status'] ?? '',
        'eventDocRef': eventDocRef,
        'selectedTeam': eventData['selectedTeams'],
        'attending': eventData['attending'],
      });

      // Add the event ID to the set
      _addedEventIds.add(eventDocRef);
    } else {
      print('Event document not found for eventDocRef: $eventDocRef');
    }
  }

  Future<void> _addChallengeDetails(Map<String, dynamic> challenge) async {
    String challengeDocRef = challenge['challengeDocRef'];

    DocumentSnapshot challengeSnapshot = await FirebaseFirestore.instance
        .collection('challenges')
        .doc(challengeDocRef)
        .get();

    if (challengeSnapshot.exists) {
      Map<String, dynamic> challengeData =
      challengeSnapshot.data() as Map<String, dynamic>;

      print('Challenge Title: ${challengeData['template_name']}');
      print('Description: ${challengeData['frequency']}');
      print('Status: ${challenge['status']}');

      challengeDetails.add({
        'title': challengeData['challengeDataList'] != null
            ? challengeData['challengeDataList'][0]['challengeTitle'].toString()
            : '',
        'Description': [
          if (challengeData['goalValue'] != null) challengeData['goalValue'],
          if (challengeData['selectedUnit'] != null) challengeData['selectedUnit'],
          if (challengeData['selectedTimeUnit'] != null)
            challengeData['selectedTimeUnit'],
        ].where((value) => value.isNotEmpty).join(' '), // Combine non-empty values
        'Created By': challengeData['CurrentUserName'],
        'Teams': (challengeData['selectedTeams'] as List<dynamic>)
            .map((team) => team.toString())
            .join(', '), // Concatenate teams with commas

        'status': challenge['status'] ?? '',
        'challengeDocRef': challengeDocRef,
        'accepted': challengeData['accepted'],
      });

    } else {
      print('Challenge document not found for challengeDocRef: $challengeDocRef');
    }
  }

  Future<void> _addChallengeTemplateDetails(Map<String, dynamic> challenge) async {
    String challengeDocRef = challenge['challengeDocRef'];

    DocumentSnapshot challengeSnapshot = await FirebaseFirestore.instance
        .collection('challenge_templates')
        .doc(challengeDocRef)
        .get();

    if (challengeSnapshot.exists) {
      Map<String, dynamic> challengeData =
      challengeSnapshot.data() as Map<String, dynamic>;

      print('Challenge Title: ${challengeData['template_name']}');
      print('Description: ${challengeData['frequency']}');
      print('Status: ${challenge['status']}');

      challengeDetails.add({
        'title': challengeData['template_name'],
        'Description': challengeData['frequency'],
        'Created By': challengeData['CurrentUserName'],
        'status': challenge['status'] ?? '',
        'challengeDocRef': challengeDocRef,
      });
    } else {
      print('Challenge document not found for challengeDocRef: $challengeDocRef');
    }
  }



  Future<void> _updateUserEventsStatus(String docRef, String status) async {
    try {
      QuerySnapshot userQuerySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: currentUser!.email)
          .limit(1)
          .get();
      print(status);
      if (userQuerySnapshot.docs.isNotEmpty) {
        DocumentSnapshot userSnapshot = userQuerySnapshot.docs.first;

        List<dynamic> userEvents = List.from(userSnapshot['user_events']);
        for (int i = 0; i < userEvents.length; i++) {
          if (userEvents[i]['eventDocRef'] == docRef || userEvents[i]['challengeDocRef'] == docRef) {
            userEvents[i]['status'] = status;
            await userSnapshot.reference.update({'user_events': userEvents});
            break;
          }
        }
      } else {
        print('User document not found for the current user');
      }
    } catch (e) {
      print('Error updating user_events status: $e');
    }
  }

  Future<void> _updateStatus(String docRef, String status, String collection) async {
    try {
      QuerySnapshot userQuerySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: currentUser!.email)
          .limit(1)
          .get();

      print('Updating status: $status for docRef: $docRef in collection: $collection');

      if (userQuerySnapshot.docs.isNotEmpty) {
        DocumentSnapshot userSnapshot = userQuerySnapshot.docs.first;

        List<dynamic> items = List.from(userSnapshot[collection]);
        print('Before update - $collection: $items');

        // Check the collection type and call the appropriate update function
        print('Collection: $collection');
        if (collection == 'team_events') {
          print('Calling _updateUserEventsStatus for team_events');
          await _updateUserEventsStatus(docRef, status);

          // Increment attendance if status is 'Going'
          if (status == 'Going') {
            await _updateAttendance(docRef, 'increment');
          } else {
            // Decrement attendance for other statuses
            await _updateAttendance(docRef, 'decrement');
          }
        } else if (collection == 'team_challenges') {
          // Add any specific handling for team_challenges if needed
          await _updateChallengeStatus(docRef, status);
        } else if (collection == 'user_events') {
          print('Calling _updateUserEventsStatus for user_events');
          await _updateUserEventsStatus(docRef, status);

          // Increment attendance if status is 'Going'
          if (status == 'Going') {
            await _updateAttendance(docRef, 'increment');
          } else {
            // Decrement attendance for other statuses
            await _updateAttendance(docRef, 'decrement');
          }
        } else {
          print('Unexpected collection type: $collection');
        }

        // Find the index of the item in the items list
        int itemIndex = items.indexWhere((item) => item['eventDocRef'] == docRef);

        // Check if the status is different before updating Firebase
        if (items[itemIndex]['status'] != status) {
          // Update the status of the specific item in Firebase
          items[itemIndex]['status'] = status;

          // Update the status to Firebase
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userSnapshot.id)
              .update({collection: items});
        }

        // Update the UI by triggering a rebuild
        setState(() {});
      } else {
        print('User document not found for the current user');
      }
    } catch (e) {
      print('Error updating status: $e');
    }
  }

  Future<void> _updateChallengeStatus(String docRef, String status) async {
    try {
      // Update challenge status in the 'challenges' collection
      DocumentReference challengeDocRef = FirebaseFirestore.instance.collection('challenges').doc(docRef);

      // Get the initial data before the update
      DocumentSnapshot initialSnapshot = await challengeDocRef.get();
      int initialAccepted = initialSnapshot['accepted'] ?? 0;

      if (status == 'Accept') {
        // Increment local accepted count
        initialAccepted += 1;
      } else {
        // Decrement local accepted count
        initialAccepted -= 1;
      }

      // Update Firestore document with status
      await challengeDocRef.update({
        'accepted': initialAccepted,
        'status': status,
      });

      // Update the local state after Firestore update
      int existingIndex = challengeDetails.indexWhere((element) => element['challengeDocRef'] == docRef);
      if (existingIndex != -1) {
        challengeDetails[existingIndex]['accepted'] = initialAccepted;
        challengeDetails[existingIndex]['status'] = status;
      }

      // Trigger a UI update by rebuilding
      setState(() {});

      // Update challenge status in the user's document
      QuerySnapshot userQuerySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: currentUser!.email)
          .limit(1)
          .get();

      if (userQuerySnapshot.docs.isNotEmpty) {
        DocumentSnapshot userSnapshot = userQuerySnapshot.docs.first;

        List<dynamic> teamChallenges = List.from(userSnapshot['team_challenges']);
        int challengeIndex = teamChallenges.indexWhere((challenge) => challenge['challengeDocRef'] == docRef);

        if (challengeIndex != -1) {
          // Update the status and accepted fields of the specific challenge in the 'team_challenges' array
          teamChallenges[challengeIndex]['status'] = status;
          teamChallenges[challengeIndex]['accepted'] = initialAccepted;

          // Update the user document in Firebase with the modified 'team_challenges' array
          await userSnapshot.reference.update({'team_challenges': teamChallenges});

          // Update the local state after Firebase update
          if (existingIndex != -1) {
            challengeDetails[existingIndex]['status'] = status;
            challengeDetails[existingIndex]['accepted'] = initialAccepted;
          }

          // Trigger a UI update by rebuilding
          setState(() {});

          print('Updating challenge status and accepted in both collections: $status for docRef: $docRef');
        } else {
          print('Challenge not found in user document for docRef: $docRef');
        }
      } else {
        print('User document not found for the current user');
      }
    } catch (e) {
      print('Error updating challenge status and accepted: $e');
    }
  }





  Future<void> _updateAttendance(String docRef, String action) async {
    try {
      DocumentReference eventDocRef = FirebaseFirestore.instance.collection('events').doc(docRef);

      // Get the initial data before the update
      DocumentSnapshot initialSnapshot = await eventDocRef.get();
      int initialAttendance = initialSnapshot['attending'] ?? 0;

      if (action == 'increment') {
        // Increment local attendance
        initialAttendance += 1;
      } else if (action == 'decrement') {
        // Decrement local attendance
        initialAttendance -= 1;
      }

      // Update Firestore document
      await eventDocRef.update({'attending': initialAttendance});

      // Update the local state after Firestore update
      int existingIndex = eventDetails.indexWhere((element) => element['eventDocRef'] == docRef);
      if (existingIndex != -1) {
        eventDetails[existingIndex]['attending'] = initialAttendance;
      }

      // Trigger a UI update by rebuilding
      setState(() {});
    } catch (e) {
      print('Error updating attendance: $e');
    }
  }

  Future<void> deleteChallengeAndReferences(String challengeDocRef) async {
    try {
      // Delete the challenge itself
      await FirebaseFirestore.instance.collection('challenges').doc(challengeDocRef).delete();
      print("Challenge deleted successfully!");
    } catch (error) {
      print("Error deleting challenge: $error");
      // Handle the error as needed
    }

    try {
      // Delete the challenge from teams
      QuerySnapshot teamsSnapshot = await FirebaseFirestore.instance.collection('teams').get();

      for (QueryDocumentSnapshot teamDoc in teamsSnapshot.docs) {
        String teamID = teamDoc.id;

        DocumentReference teamChallengesRef = FirebaseFirestore.instance.collection('teams').doc(teamID);
        DocumentSnapshot teamChallengesDoc = await teamChallengesRef.get();

        List<dynamic> teamChallengesArray = teamChallengesDoc['team_challenges'] ?? [];
        List<dynamic> updatedChallengesArray = teamChallengesArray
            .where((challenge) {
          String? teamChallengeDocRef = challenge['challengeDocRef'] as String?;
          return teamChallengeDocRef == null || teamChallengeDocRef != challengeDocRef;
        })
            .toList();

        await teamChallengesRef.update({'team_challenges': updatedChallengesArray});
        print("Updated Team Challenges for Team $teamID: $updatedChallengesArray");
      }
    } catch (error) {
      print("Error deleting challenge from teams: $error");
      // Handle the error as needed
    }

    try {
      // Delete the challenge from users
      QuerySnapshot usersSnapshot = await FirebaseFirestore.instance.collection('users').get();

      for (QueryDocumentSnapshot userDoc in usersSnapshot.docs) {
        String userID = userDoc.id;

        DocumentReference userChallengesRef = FirebaseFirestore.instance.collection('users').doc(userID);
        DocumentSnapshot userChallengesDoc = await userChallengesRef.get();

        List<dynamic> userChallengesArray = userChallengesDoc['team_challenges'] ?? [];
        List<dynamic> updatedChallengesArray = userChallengesArray
            .where((challenge) {
          if (challenge is Map<String, dynamic>) {
            String? userChallengeDocRef = challenge['challengeDocRef'] as String?;
            return userChallengeDocRef == null || userChallengeDocRef != challengeDocRef;
          }
          return true;
        })
            .toList();

        await userChallengesRef.update({'team_challenges': updatedChallengesArray});
        print("Updated Team Challenges for User $userID: $updatedChallengesArray");
      }
    } catch (error) {
      print("Error deleting challenge from users: $error");
      // Handle the error as needed
    }
  }

  void showDeleteConfirmationDialog(BuildContext context, String challengeDocRef) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Challenge"),
          content: Text("Clicking Yes will delete the challenge posted for all Teams. Are you sure you want to do this?"),
          actions: [
            TextButton(
              child: Text("No"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text("Yes"),
              onPressed: () async {
                // Perform the delete action here
                await deleteChallengeAndReferences(challengeDocRef);

                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Challenge deleted successfully!')));
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }






  @override
  Widget build(BuildContext context) {
    eventDetails.sort((a, b) {
      if (a['status'] == 'pending' && b['status'] != 'pending') {
        return -1;
      } else if (a['status'] != 'pending' && b['status'] == 'pending') {
        return 1;
      } else {
        return a['startDate'].compareTo(b['startDate']);
      }
    });

    challengeDetails.sort((a, b) {
      if (a['status'] == 'pending' && b['status'] != 'pending') {
        return -1;
      } else if (a['status'] != 'pending' && b['status'] == 'pending') {
        return 1;
      } else {
        // Sort challenges based on your criteria, you can adjust this part
        return 0;
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('All Notifications'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          DropdownButton<String>(
            value: showMyCreated ? 'My Created Events & Challenges' : 'All Notifications',
            items: [
              'All Notifications',
              'My Created Events & Challenges',
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                showMyCreated = newValue == 'My Created Events & Challenges';
              });
            },
          ),
          const SizedBox(height: 10),
          const SizedBox(height: 10),
          Expanded(
            child: showMyCreated
                ? Container()
                : ListView.builder(
              itemCount: eventDetails.length + challengeDetails.length,
              itemBuilder: (context, index) {
                if (index < challengeDetails.length) {
                  int challengeIndex = index;
                  bool buttonsVisible =
                      challengeDetails[challengeIndex]['Created By'] !=
                          currentUserFullName;
                  return Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                        ),
                        child: ListTile(
                          title: Text(
                            'Title: ${challengeDetails[challengeIndex]['title']}',
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Description: ${challengeDetails[challengeIndex]['Description']}',
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Challenge Created By: ${challengeDetails[challengeIndex]['Created By']}',
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Teams Challenged: ${challengeDetails[challengeIndex]['Teams']}',
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Accepted: ${challengeDetails[challengeIndex]['accepted']}',
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Status: ${challengeDetails[challengeIndex]['status']}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Visibility(
                                    visible: buttonsVisible,
                                    child: Expanded(
                                      child: StatusButton(
                                        buttonText: 'Accept',
                                        docRef: challengeDetails[challengeIndex]['challengeDocRef'],
                                        collection: 'team_challenges',
                                        currentStatus: challengeDetails[challengeIndex]['status'],
                                        onPressed: (status) {
                                          if (status != challengeDetails[challengeIndex]['status']) {
                                            // Only update if the new status is different from the current status
                                            _updateStatus(
                                              challengeDetails[challengeIndex]['challengeDocRef'],
                                              status,
                                              'team_challenges',
                                            );
                                            setState(() {
                                              challengeDetails[challengeIndex]['status'] = status;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  ),

                                  SizedBox(width: 8),
                                  Visibility(
                                    visible: buttonsVisible,
                                    child: Expanded(
                                      child: StatusButton(
                                        buttonText: 'Decline',
                                        docRef: challengeDetails[challengeIndex]['challengeDocRef'],
                                        collection: 'team_challenges',
                                        currentStatus: challengeDetails[challengeIndex]['status'],
                                        onPressed: (status) {
                                          if (status != challengeDetails[challengeIndex]['status']) {
                                            // Only update if the new status is different from the current status
                                            _updateStatus(
                                              challengeDetails[challengeIndex]['challengeDocRef'],
                                              status,
                                              'team_challenges',
                                            );
                                            setState(() {
                                              challengeDetails[challengeIndex]['status'] = status;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (!buttonsVisible) // hide 'x' when buttons are visible
                        Positioned(
                          top: 8,
                          right: 8,
                          child: IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () {
                              showDeleteConfirmationDialog(context, challengeDetails[challengeIndex]['challengeDocRef']);// Handle the removal action
                            },
                          ),
                        ),
                    ],
                  );
                } else {
                  int eventIndex = index - challengeDetails.length;
                  DateTime startDate =
                  eventDetails[eventIndex]['startDate'].toDate();
                  String formattedDate =
                  DateFormat('MMMM d, y').format(startDate);

                  bool buttonsVisible =
                      eventDetails[eventIndex]['Created By'] !=
                          currentUserFullName;

                  return Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                        ),
                        child: ListTile(
                          title: Text(
                            'Title: ${eventDetails[eventIndex]['title']}',
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Start Date: $formattedDate'),
                              Text(
                                'Start Time: ${eventDetails[eventIndex]['startTime']}',
                              ),
                              Text(
                                'Location: ${eventDetails[eventIndex]['eventLocation']}',
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Event Created By: ${eventDetails[eventIndex]['Created By']}',
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Attending: ${eventDetails[eventIndex]['attending']}',
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Team: ${eventDetails[eventIndex]['selectedTeam'].join(', ')}',
                              ),

                              SizedBox(height: 8),
                              Text(
                                'Status: ${eventDetails[eventIndex]['status']}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Visibility(
                                    visible: buttonsVisible,
                                    child: Expanded(
                                      child: StatusButton(
                                        buttonText: 'Going',
                                        docRef: eventDetails[eventIndex]['eventDocRef'],
                                        collection: 'team_events',
                                        currentStatus: eventDetails[eventIndex]['status'],
                                        onPressed: (status) async {
                                          if (eventDetails[eventIndex]['status'] != 'Going') {
                                            // Update the status only if it's not already "Going"
                                            await _updateStatus(
                                              eventDetails[eventIndex]['eventDocRef'],
                                              status,
                                              'team_events',
                                            );

                                            // Update the local state
                                            setState(() {
                                              eventDetails[eventIndex]['status'] = status;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  ),

                                  SizedBox(width: 8),
                                  Visibility(
                                    visible: buttonsVisible,
                                    child: Expanded(
                                      child: StatusButton(
                                        buttonText: 'Not Going',
                                        docRef: eventDetails[eventIndex]['eventDocRef'],
                                        collection: 'team_events',
                                        currentStatus: eventDetails[eventIndex]['status'],
                                        onPressed: (status) async {
                                          if (eventDetails[eventIndex]['status'] != 'Not Going') {
                                            // Update the status only if it's not already "Not Going"
                                            await _updateStatus(
                                              eventDetails[eventIndex]['eventDocRef'],
                                              status,
                                              'team_events',
                                            );

                                            // Update the local state
                                            setState(() {
                                              eventDetails[eventIndex]['status'] = status;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (!buttonsVisible) // hide 'x' when buttons are visible
                        Positioned(
                          top: 8,
                          right: 8,
                          child: IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () {
                              // Handle the removal action
                            },
                          ),
                        ),
                    ],
                  );
                }
              },
            ),
          ),
        ],
      ),
    );





  }
}