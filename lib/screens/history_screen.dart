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
        foregroundColor: Colors.white,
        backgroundColor: isButtonActive ? Colors.green : null,
      ),
      child: Text(widget.buttonText),
    );
  }
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late User? currentUser;
  List<String> teamIds = [];
  List<Map<String, dynamic>> eventDetails = [];
  List<Map<String, dynamic>> challengeDetails = [];
  String currentUserName = '';

  // New variable to store the current user's name
  String currentUserFullName = '';
  bool showMoreInfo = false;
  List<bool> showMoreInfoListEvents = [];
  List<bool> showMoreInfoListChallenges = [];

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

    // Initialize showMoreInfoListEvents and showMoreInfoListChallenges after eventDetails and challengeDetails are populated
    showMoreInfoListEvents = List.generate(
      eventDetails.length,
          (index) => false,
    );

    showMoreInfoListChallenges = List.generate(
      challengeDetails.length,
          (index) => false,
    );
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
        'challengeLength': challengeData['challengeLength'],
        'emotionalCategory': challengeData['emotionalCategory'] ?? '',
        'environmentalCategory': challengeData['environmentalCategory'] ?? '',
        'financialCategory': challengeData['financialCategory'] ?? '',
        'intellectualCategory': challengeData['intellectualCategory'] ?? '',
        'occupationalCategory': challengeData['occupationalCategory'] ?? '',
        'physicalCategory': challengeData['physicalCategory'] ?? '',
        'socialCategory': challengeData['socialCategory'] ?? '',
        'spiritualCategory': challengeData['spiritualCategory'] ?? '',
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
        title: Text('Activity History'),
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
                        child: Column(
                          children: [
                            ListTile(
                              title: Row(
                                children: [
                                  // Loop through each category and display icon images
                                  for (final category in streaks)
                                    if (challengeDetails[challengeIndex]['${category['name'].toLowerCase()}Category'] ?? false)
                                      Padding(
                                        padding: EdgeInsets.only(right: 8),
                                        child: Image.asset(
                                          category['icon'],
                                          height: 24,
                                          width: 24,
                                        ),
                                      ),
                                  Expanded(
                                    child: Text(
                                      'Challenge: ${challengeDetails[challengeIndex]['title']}',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.info),
                                onPressed: () {
                                  setState(() {
                                    showMoreInfoListChallenges[challengeIndex] =
                                    !showMoreInfoListChallenges[challengeIndex];
                                  });
                                },
                              ),
                            ),
                            Visibility(
                              visible: showMoreInfoListChallenges[challengeIndex],
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Challenge: ${challengeDetails[challengeIndex]['title']}',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Description: ${challengeDetails[challengeIndex]['Description']}',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Challenge Length: ${challengeDetails[challengeIndex]['challengeLength']}',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Challenge Created By: ${challengeDetails[challengeIndex]['Created By']}',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Teams Challenged: ${challengeDetails[challengeIndex]['Teams']}',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Accepted: ${challengeDetails[challengeIndex]['accepted']}',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 8),
                                ],
                              ),
                            ),
                          ],
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
                        child: Column(
                          children: [
                            ListTile(
                              title: Row(
                                children: [
                                  // Display the social icon dynamically
                                  Image.asset(
                                    streaks[6]['icon'],
                                    height: 24, // Adjust the size as needed
                                    width: 24,
                                  ),
                                  SizedBox(width: 8), // Add some spacing between the icon and the event title
                                  Text(
                                    'Event: ${eventDetails[eventIndex]['title']}',
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.info),
                                onPressed: () {
                                  setState(() {
                                    showMoreInfoListEvents[eventIndex] =
                                    !showMoreInfoListEvents[eventIndex];
                                  });
                                },
                              ),
                            ),
                            Visibility(
                              visible: showMoreInfoListEvents[eventIndex],
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Start Date: $formattedDate',
                                  ),
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
                                ],
                              ),
                            ),
                          ],
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
final List<Map<String, dynamic>> streaks = [
  {'name': 'Emotional', 'icon': 'assets/images/Emotional-mini.png'},
  {'name': 'Environmental', 'icon': 'assets/images/Environmental-mini.png'},
  {'name': 'Financial', 'icon': 'assets/images/Financial-mini.png'},
  {'name': 'Intellectual', 'icon': 'assets/images/Intellectual-mini.png'},
  {'name': 'Occupational', 'icon': 'assets/images/Occupational-mini.png'},
  {'name': 'Physical', 'icon': 'assets/images/Physical-mini.png'},
  {'name': 'Social', 'icon': 'assets/images/Social-mini.png'},
  {'name': 'Spiritual', 'icon': 'assets/images/Spiritual-mini.png'},
];