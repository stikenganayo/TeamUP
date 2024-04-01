import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:snapchat_ui_clone/widgets/top_bar.dart';
import 'dart:io';
import 'package:intl/intl.dart'; // Import intl package for date formatting
import '../style.dart';
import '../widgets/discover_grid.dart';
import '../widgets/team_stories.dart';
import '../widgets/subscriptions.dart';
import 'events_filter_page.dart'; // Import your EventsFilter screen
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

class StoriesScreen extends StatefulWidget {
  const StoriesScreen({Key? key}) : super(key: key);

  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> {
  List<Map<String, dynamic>> communityEvents = [];
  List<Map<String, dynamic>> communityChallenges = [];
  List<Map<String, dynamic>> communityCoaches = [];
  late User? currentUser;

  @override
  void initState() {
    super.initState();
    _loadCommunityEvents();
    _loadCommunityChallenges();
    _loadCommunityCoaches();
  }

  Future<String?> _loadCurrentUserName() async {
    currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      print('Current User Email: ${currentUser!.email}');

      try {
        QuerySnapshot userQuerySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: currentUser!.email)
            .limit(1)
            .get();

        if (userQuerySnapshot.docs.isNotEmpty) {
          DocumentSnapshot userSnapshot = userQuerySnapshot.docs.first;
          Map<String, dynamic> userData =
          userSnapshot.data() as Map<String, dynamic>;

          print('User Data: $userData');

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
    return null;
  }

  Future<void> _loadCommunityEvents() async {
    try {
      QuerySnapshot communityEventsSnapshot = await FirebaseFirestore.instance
          .collection('events')
          .where('communityEvent', isEqualTo: true)
          .get();

      List<Map<String, dynamic>> events = [];

      for (DocumentSnapshot doc in communityEventsSnapshot.docs) {
        if (doc.exists) {
          String formattedDate =
          DateFormat('MMMM dd, yyyy').format(doc['startDate'].toDate());

          Map<String, dynamic> eventDetails = {
            'eventId': doc.id,
            'eventTitle': doc['eventTitle'] ?? '',
            'startDate': formattedDate,
            'startTime': doc['startTime'] ?? '',
            'eventLocation': doc['eventLocation'] ?? '',
            'CurrentUserName': doc['CurrentUserName'],
            'attending': doc['attending'] ?? 0,
            'isGoing': false,
            // 'background': doc['background'] ?? '', // Added background field
          };
          events.add(eventDetails);
        }
      }

      setState(() {
        communityEvents = events;
      });
    } catch (e) {
      print('Error loading community events: $e');
    }
  }

  Future<void> _updateAttendance(String eventId, bool going) async {
    try {
      final eventRef =
      FirebaseFirestore.instance.collection('events').doc(eventId);

      await eventRef.update({
        'attending': FieldValue.increment(going ? 1 : -1),
      });

      setState(() {
        final eventIndex = communityEvents.indexWhere(
                (event) => event['eventId'] == eventId);
        if (eventIndex != -1) {
          communityEvents[eventIndex]['attending'] += going ? 1 : -1;
          communityEvents[eventIndex]['isGoing'] = going;
        }
      });
    } catch (e) {
      print('Error updating attendance: $e');
    }
  }

  Future<void> _acceptChallenge(String challengeId, bool accept) async {
    try {
      final challengeRef =
      FirebaseFirestore.instance.collection('challenges').doc(challengeId);

      await challengeRef.update({
        'accepted': FieldValue.increment(accept ? 1 : -1),
      });

      setState(() {
        final challengeIndex = communityChallenges.indexWhere(
                (challenge) => challenge['challengeId'] == challengeId);
        if (challengeIndex != -1) {
          communityChallenges[challengeIndex]['accepted'] += accept ? 1 : -1;
          communityChallenges[challengeIndex]['isGoing'] = accept;
        }
      });
    } catch (e) {
      print('Error updating acceptance: $e');
    }
  }

  Future<void> _loadCommunityChallenges() async {
    try {
      QuerySnapshot communityChallengesSnapshot = await FirebaseFirestore
          .instance
          .collection('challenges')
          .where('communityChallenge', isEqualTo: true)
          .get();

      List<Map<String, dynamic>> challenges = [];

      for (DocumentSnapshot doc in communityChallengesSnapshot.docs) {
        if (doc.exists) {
          List<Map<String, dynamic>> challengeDataList = [];
          if (doc['challengeDataList'] != null) {
            var data = doc['challengeDataList'][0];
            challengeDataList.add({
              'challengeTitle': data['challengeTitle'] ?? '',
            });
          }

          Map<String, dynamic> challengeDetails = {
            'challengeId': doc.id,
            'challengeDataList': challengeDataList,
            'CurrentUserName': doc['CurrentUserName'] ?? '',
            'accepted': doc['accepted'] ?? 0,
            'isGoing': false,
          };
          challenges.add(challengeDetails);
        }
      }

      setState(() {
        communityChallenges = challenges;
      });
    } catch (e) {
      print('Error loading community challenges: $e');
    }
  }

  void _showAddCoachDialog(BuildContext context) {
    String description = '';
    String yearsOfExperience = '';
    String coach = _loadCurrentUserName() as String;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Community Coach'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  description = value;
                },
                decoration: InputDecoration(
                  labelText: 'Description',
                ),
              ),
              TextField(
                onChanged: (value) {
                  yearsOfExperience = value;
                },
                decoration: InputDecoration(
                  labelText: 'Years of Experience',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('community_coaches')
                    .add({
                  'coach': coach,
                  'description': description,
                  'years_of_experience': yearsOfExperience,
                });
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadCommunityCoaches() async {
    try {
      QuerySnapshot communityCoachesSnapshot = await FirebaseFirestore.instance
          .collection('community_coaches')
          .get();

      List<Map<String, dynamic>> coaches = [];

      for (DocumentSnapshot doc in communityCoachesSnapshot.docs) {
        if (doc.exists) {
          Map<String, dynamic> coachDetails = {
            'coach': doc['coach'] ?? '',
            'coachId': doc.id,
            'description': doc['description'] ?? '',
            'years_of_experience': doc['years_of_experience'] ?? '',
          };
          coaches.add(coachDetails);
        }
      }

      setState(() {
        communityCoaches = coaches;
      });
    } catch (e) {
      print('Error loading community coaches: $e');
    }
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
          const TopBar(isCameraPage: false, text: 'Community'),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Style.sectionTitle('Community Stories   '),
                    ],
                  ),
                  const Stories(),
                  const SizedBox(height: 28),
                  const SizedBox(height: 28),
                  Style.sectionTitle('Community Events'),
                  const SizedBox(height: 28),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: communityEvents.map((event) =>
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.4,
                            height: 300,
                            child: Card(
                              child: Container(
                                // decoration: BoxDecoration(
                                //   image: DecorationImage(
                                //     image: NetworkImage(event['background']), // Use the background URL
                                //     fit: BoxFit.cover,
                                //   ),
                                // ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              event['eventTitle'],
                                              style: TextStyle(
                                                color: Colors.black, // Making the text bright red
                                                fontWeight: FontWeight.bold, // Making the text bold
                                                fontSize: 18, // Increasing the font size
                                                shadows: [
                                                  Shadow(
                                                    color: Colors.grey, // Shadow color
                                                    offset: Offset(2, 2), // Shadow offset
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Text(
                                              'Date: ${event['startDate']}',
                                              style: TextStyle(
                                                color: Colors.black, // Making the text bright red
                                                fontWeight: FontWeight.bold, // Making the text bold
                                                shadows: [
                                                  Shadow(
                                                    color: Colors.grey, // Shadow color
                                                    offset: Offset(2, 2), // Shadow offset
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Text(
                                              'Start Time: ${event['startTime']}',
                                              style: TextStyle(
                                                color: Colors.black, // Making the text bright red
                                                fontWeight: FontWeight.bold, // Making the text bold
                                                shadows: [
                                                  Shadow(
                                                    color: Colors.grey, // Shadow color
                                                    offset: Offset(2, 2), // Shadow offset
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Text(
                                              'Location: ${event['eventLocation']}',
                                              style: TextStyle(
                                                color: Colors.black, // Making the text bright red
                                                fontWeight: FontWeight.bold, // Making the text bold
                                                shadows: [
                                                  Shadow(
                                                    color: Colors.grey, // Shadow color
                                                    offset: Offset(2, 2), // Shadow offset
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Text(
                                              'Host: ${event['CurrentUserName']}',
                                              style: TextStyle(
                                                color: Colors.black, // Making the text bright red
                                                fontWeight: FontWeight.bold, // Making the text bold
                                                shadows: [
                                                  Shadow(
                                                    color: Colors.grey, // Shadow color
                                                    offset: Offset(2, 2), // Shadow offset
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Text(
                                              'Attending: ${event['attending']}',
                                              style: TextStyle(
                                                color: Colors.black, // Making the text bright red
                                                fontWeight: FontWeight.bold, // Making the text bold
                                                shadows: [
                                                  Shadow(
                                                    color: Colors.grey, // Shadow color
                                                    offset: Offset(2, 2), // Shadow offset
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            if (event['isGoing']) {
                                              _updateAttendance(event['eventId'], false);
                                            } else {
                                              _updateAttendance(event['eventId'], true);
                                            }
                                          },
                                          child: Text(event['isGoing']
                                              ? 'Spot Reserved. Press to cancel'
                                              : 'RSVP'),
                                          style: ButtonStyle(
                                            backgroundColor: event['isGoing']
                                                ? MaterialStateProperty.all(Colors.green)
                                                : null,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ).toList(),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Style.sectionTitle('Community Challenges'),
                  const SizedBox(height: 28),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: communityChallenges.map((challenge) =>
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.4,
                            height: 300,
                            child: Card(
                              child: Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: double.infinity,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: challenge['challengeDataList']
                                                    .map<Widget>((challengeData) {
                                                  return Text(challengeData['challengeTitle']);
                                                }).toList(),
                                              ),
                                            ),
                                            Text('Host: ${challenge['CurrentUserName']}'),
                                            Text('Accepted: ${challenge['accepted']}'),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            if (challenge['isGoing']) {
                                              _acceptChallenge(challenge['challengeId'], false);
                                            } else {
                                              _acceptChallenge(challenge['challengeId'], true);
                                            }
                                          },
                                          child: Text(challenge['isGoing']
                                              ? 'Accepted Challenge. Press to cancel'
                                              : 'Accept'),
                                          style: ButtonStyle(
                                            backgroundColor: challenge['isGoing']
                                                ? MaterialStateProperty.all(Colors.green)
                                                : null,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ).toList(),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Style.sectionTitle('Community Coaches'),
                            SizedBox(width: 10),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _showAddCoachDialog(context);
                        },
                        child: Text('Be a Community Coach'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: communityCoaches.map((coach) =>
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.4,
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 8),
                                    FutureBuilder<String?>(
                                      future: _loadCurrentUserName(),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return CircularProgressIndicator();
                                        } else if (snapshot.hasError) {
                                          return Text('Error: ${snapshot.error}');
                                        } else {
                                          return Text('');
                                        }
                                      },
                                    ),
                                    Text(
                                      'Coach ID: ${coach['coach']}',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 8),
                                    Text('Description: ${coach['description']}'),
                                    SizedBox(height: 8),
                                    Text('Years of Experience: ${coach['years_of_experience']}'),
                                    SizedBox(height: 8),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ).toList(),
                    ),
                  ),
                  SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}