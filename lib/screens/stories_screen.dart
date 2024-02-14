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
  List<Map<String, dynamic>> communityEvents = [
  ]; // Hold community events details
  List<Map<String, dynamic>> communityChallenges = [
  ]; // Hold community challenges details

  @override
  void initState() {
    super.initState();
    _loadCommunityEvents();
    _loadCommunityChallenges();
  }

  Future<void> _loadCommunityEvents() async {
    try {
      QuerySnapshot communityEventsSnapshot = await FirebaseFirestore.instance
          .collection('events')
          .where('communityEvent', isEqualTo: true)
          .get();

      List<Map<String, dynamic>> events = []; // Temporary list to hold events

      // Extract details from community events
      for (DocumentSnapshot doc in communityEventsSnapshot.docs) {
        if (doc.exists) {
          // Format the date using DateFormat
          String formattedDate = DateFormat('MMMM dd, yyyy').format(
              doc['startDate'].toDate());

          Map<String, dynamic> eventDetails = {
            'eventId': doc.id, // Add event ID
            'eventTitle': doc['eventTitle'] ?? '',
            'startDate': formattedDate, // Use formatted date
            'startTime': doc['startTime'] ?? '',
            'eventLocation': doc['eventLocation'] ?? '',
            'CurrentUserName': doc['CurrentUserName'],
            'attending': doc['attending'] ?? 0, // Default to 0 if not set
            'isGoing': false, // Track button state
          };
          events.add(eventDetails);
        }
      }

      setState(() {
        communityEvents =
            events; // Update the state with community event details
      });
    } catch (e) {
      print('Error loading community events: $e');
    }
  }

  Future<void> _updateAttendance(String eventId, bool going) async {
    try {
      final eventRef = FirebaseFirestore.instance.collection('events').doc(
          eventId);

      await eventRef.update({
        'attending': FieldValue.increment(going ? 1 : -1),
        // Increment or decrement attending count
      });

      // Update UI
      setState(() {
        final eventIndex = communityEvents.indexWhere((
            event) => event['eventId'] == eventId);
        if (eventIndex != -1) {
          communityEvents[eventIndex]['attending'] += going ? 1 : -1;
          communityEvents[eventIndex]['isGoing'] = going; // Update button state
        }
      });
    } catch (e) {
      print('Error updating attendance: $e');
    }
  }

  Future<void> _acceptChallenge(String challengeId, bool accept) async {
    try {
      final challengeRef = FirebaseFirestore.instance.collection('challenges').doc(
          challengeId);

      await challengeRef.update({
        'accepted': FieldValue.increment(accept ? 1 : -1), // Increment or decrement accepted count
      });

      // Update UI
      setState(() {
        final challengeIndex = communityChallenges.indexWhere((challenge) => challenge['challengeId'] == challengeId);
        if (challengeIndex != -1) {
          communityChallenges[challengeIndex]['accepted'] += accept ? 1 : -1;
          communityChallenges[challengeIndex]['isGoing'] = accept; // Update isGoing based on accept value
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

      List<Map<String, dynamic>> challenges = [
      ]; // Temporary list to hold challenges

      // Extract details from community challenges
      for (DocumentSnapshot doc in communityChallengesSnapshot.docs) {
        if (doc.exists) {
          List<Map<String, dynamic>> challengeDataList = [];
          if (doc['challengeDataList'] != null) {
            var data = doc['challengeDataList'][0]; // Get only the first item from challengeDataList
            challengeDataList.add({
              'challengeTitle': data['challengeTitle'] ?? '',
            });
          }

          Map<String, dynamic> challengeDetails = {
            'challengeId': doc.id, // Add event ID
            'challengeDataList': challengeDataList,
            'CurrentUserName': doc['CurrentUserName'] ?? '',
            'accepted': doc['accepted'] ?? 0, // Default to 0 if not set
            'isGoing': false, // Track button state
          };
          challenges.add(challengeDetails);
        }
      }

      setState(() {
        communityChallenges =
            challenges; // Update the state with community challenge details
      });
    } catch (e) {
      print('Error loading community challenges: $e');
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
            height: MediaQuery
                .of(context)
                .size
                .height - 100 - (Platform.isIOS ? 90 : 60),
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
                            width: MediaQuery
                                .of(context)
                                .size
                                .width * 0.4,
                            height: 300,
                            child: Card(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment
                                            .start,
                                        children: [
                                          Text(event['eventTitle']),
                                          Text('Date: ${event['startDate']}'),
                                          Text(
                                              'Start Time: ${event['startTime']}'),
                                          Text(
                                              'Location: ${event['eventLocation']}'),
                                          Text(
                                              'Host: ${event['CurrentUserName']}'),
                                          Text(
                                              'Attending: ${event['attending']}'),
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
                                            _updateAttendance(
                                                event['eventId'], false);
                                          } else {
                                            _updateAttendance(
                                                event['eventId'], true);
                                          }
                                        },
                                        child: Text(event['isGoing']
                                            ? 'Spot Reserved. Press to cancel'
                                            : 'RSVP'),
                                        style: ButtonStyle(
                                          backgroundColor: event['isGoing']
                                              ? MaterialStateProperty.all(
                                              Colors.green)
                                              : null,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )).toList(),
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
                            width: MediaQuery
                                .of(context)
                                .size
                                .width * 0.4,
                            height: 300,
                            child: Card(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment
                                            .start,
                                        children: [
                                          SizedBox(
                                            width: double.infinity,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment
                                                  .start,
                                              children: challenge['challengeDataList']
                                                  .map<Widget>((challengeData) {
                                                return Text(
                                                    challengeData['challengeTitle']);
                                              }).toList(),
                                            ),
                                          ),
                                          Text(
                                              'Host: ${challenge['CurrentUserName']}'),
                                          Text(
                                              'Accepted: ${challenge['accepted']}'),
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
                                            _acceptChallenge(
                                                challenge['challengeId'], false);
                                          } else {
                                            _acceptChallenge(
                                                challenge['challengeId'], true);
                                          }
                                        },
                                        child: Text(challenge['isGoing']
                                            ? 'Accepted Challenge. Press to cancel'
                                            : 'Accept'),
                                        style: ButtonStyle(
                                          backgroundColor: challenge['isGoing']
                                              ? MaterialStateProperty.all(
                                              Colors.green)
                                              : null,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )).toList(),
                    ),
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