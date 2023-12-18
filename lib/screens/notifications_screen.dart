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
        primary: isButtonActive ? Colors.green : null,
        onPrimary: Colors.white,
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

  // Set to keep track of added event IDs
  Set<String> _addedEventIds = Set();

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
        'status': event['status'] ?? '',
        'eventDocRef': eventDocRef,
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
        'status': challenge['status'] ?? '',
        'challengeDocRef': challengeDocRef,
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

      if (userQuerySnapshot.docs.isNotEmpty) {
        DocumentSnapshot userSnapshot = userQuerySnapshot.docs.first;

        List<dynamic> events = List.from(userSnapshot[collection]);
        for (int i = 0; i < events.length; i++) {
          if (events[i]['eventDocRef'] == docRef || events[i]['challengeDocRef'] == docRef) {
            events[i]['status'] = status;
            await userSnapshot.reference.update({collection: events});

            // Check the collection type and call the appropriate update function
            if (collection == 'team_events') {
              await _updateUserEventsStatus(docRef, status);
            } else if (collection == 'team_challenges') {
              // Add any specific handling for team_challenges if needed
            } else if (collection == 'user_events') {
              await _updateUserEventsStatus(docRef, status);
            }

            break;
          }
        }
      } else {
        print('User document not found for the current user');
      }
    } catch (e) {
      print('Error updating status: $e');
    }
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
          Expanded(
            child: ListView.builder(
              itemCount: eventDetails.length + challengeDetails.length,
              itemBuilder: (context, index) {
                if (index < challengeDetails.length) {
                  int challengeIndex = index;
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                    ),
                    child: ListTile(
                      title: Text(
                          'Title: ${challengeDetails[challengeIndex]['title']}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              'Description: ${challengeDetails[challengeIndex]['Description']}'),
                          SizedBox(height: 8),
                          Text(
                            'Status: ${challengeDetails[challengeIndex]['status']}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Expanded(
                                child: StatusButton(
                                  buttonText: 'Accept',
                                  docRef: challengeDetails[challengeIndex]['challengeDocRef'],
                                  collection: 'team_challenges',
                                  currentStatus: challengeDetails[challengeIndex]['status'],
                                  onPressed: (status) {
                                    _updateStatus(
                                      challengeDetails[challengeIndex]['challengeDocRef'],
                                      status,
                                      'team_challenges',
                                    );
                                    setState(() {
                                      challengeDetails[challengeIndex]['status'] =
                                          status;
                                    });
                                  },
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: StatusButton(
                                  buttonText: 'Decline',
                                  docRef: challengeDetails[challengeIndex]['challengeDocRef'],
                                  collection: 'team_challenges',
                                  currentStatus: challengeDetails[challengeIndex]['status'],
                                  onPressed: (status) {
                                    _updateStatus(
                                      challengeDetails[challengeIndex]['challengeDocRef'],
                                      status,
                                      'team_challenges',
                                    );
                                    setState(() {
                                      challengeDetails[challengeIndex]['status'] =
                                          status;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  int eventIndex = index - challengeDetails.length;
                  DateTime startDate = eventDetails[eventIndex]['startDate']
                      .toDate();
                  String formattedDate = DateFormat('MMMM d, y').format(
                      startDate);

                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                    ),
                    child: ListTile(
                      title: Text(
                          'Title: ${eventDetails[eventIndex]['title']}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Start Date: $formattedDate'),
                          Text(
                              'Start Time: ${eventDetails[eventIndex]['startTime']}'),
                          Text(
                              'Location: ${eventDetails[eventIndex]['eventLocation']}'),
                          SizedBox(height: 8),
                          Text(
                            'Status: ${eventDetails[eventIndex]['status']}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Expanded(
                                child: StatusButton(
                                  buttonText: 'Going',
                                  docRef: eventDetails[eventIndex]['eventDocRef'],
                                  collection: 'team_events',
                                  currentStatus: eventDetails[eventIndex]['status'],
                                  onPressed: (status) {
                                    _updateStatus(
                                      eventDetails[eventIndex]['eventDocRef'],
                                      status,
                                      'team_events',
                                    );
                                    setState(() {
                                      eventDetails[eventIndex]['status'] =
                                          status;
                                    });
                                  },
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: StatusButton(
                                  buttonText: 'Not Going',
                                  docRef: eventDetails[eventIndex]['eventDocRef'],
                                  collection: 'team_events',
                                  currentStatus: eventDetails[eventIndex]['status'],
                                  onPressed: (status) {
                                    _updateStatus(
                                      eventDetails[eventIndex]['eventDocRef'],
                                      status,
                                      'team_events',
                                    );
                                    setState(() {
                                      eventDetails[eventIndex]['status'] =
                                          status;
                                    });
                                  },
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: StatusButton(
                                  buttonText: 'Maybe',
                                  docRef: eventDetails[eventIndex]['eventDocRef'],
                                  collection: 'team_events',
                                  currentStatus: eventDetails[eventIndex]['status'],
                                  onPressed: (status) {
                                    _updateStatus(
                                      eventDetails[eventIndex]['eventDocRef'],
                                      status,
                                      'team_events',
                                    );
                                    setState(() {
                                      eventDetails[eventIndex]['status'] =
                                          status;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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