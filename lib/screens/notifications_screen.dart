import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late User? currentUser;
  List<String> teamIds = [];
  List<Map<String, dynamic>> eventDetails = [];

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
          Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;

          print('User Data: $userData');
          print("Are you working?");
          print(userData['team_events']);

          // Clear the eventDetails list before adding new events
          eventDetails.clear();

          // Fetch and print details for each event in team_events
          if (userData.containsKey('team_events')) {
            List<dynamic> teamEvents = userData['team_events'];
            for (Map<String, dynamic> event in teamEvents) {
              String eventDocRef = event['eventDocRef'];

              DocumentSnapshot eventSnapshot = await FirebaseFirestore.instance
                  .collection('events')
                  .doc(eventDocRef)
                  .get();

              if (eventSnapshot.exists) {
                Map<String, dynamic> eventData = eventSnapshot.data() as Map<String, dynamic>;
                print('Event Details:');
                print('Event Title: ${eventData['eventTitle']}');
                print('Start Date: ${eventData['startDate']}');
                print('Start Time: ${eventData['startTime']}');
                print('Event Location: ${eventData['eventLocation']}');
                print('Status: ${eventData['status']}');

                // Handle potential null values for 'startTime' and 'eventLocation'
                eventDetails.add({
                  'title': eventData['eventTitle'],
                  'startDate': eventData['startDate'],
                  'startTime': eventData['startTime'] ?? '',
                  'eventLocation': eventData['eventLocation'] ?? '',
                  'status': eventData['status'] ?? '', // Added status field
                  'eventDocRef': eventDocRef,
                });
              } else {
                print('Event document not found for eventDocRef: $eventDocRef');
              }
            }
          } else {
            print('team_events field not found in user document');
          }

          if (userData.containsKey('team_ids')) {
            setState(() {
              teamIds = List.from(userData['team_ids']);
            });
          } else {
            print('Team_ids field not found in user document');
          }
        } else {
          print('User document not found for the current user');
        }
      }
    } catch (e) {
      print('Error loading user document: $e');
    }
  }

  Future<void> _updateStatus(String eventDocRef, String status) async {
    try {
      QuerySnapshot userQuerySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: currentUser!.email)
          .limit(1)
          .get();

      if (userQuerySnapshot.docs.isNotEmpty) {
        DocumentSnapshot userSnapshot = userQuerySnapshot.docs.first;

        // Update the team_events field in the current user's document
        List<dynamic> teamEvents = List.from(userSnapshot['team_events']);
        for (int i = 0; i < teamEvents.length; i++) {
          if (teamEvents[i]['eventDocRef'] == eventDocRef) {
            teamEvents[i]['status'] = status;
            break; // Stop iterating once the correct event is found and updated
          }
        }

        // Update the user's document with the modified team_events
        await userSnapshot.reference.update({'team_events': teamEvents});

        // Reload the current user's data
        await _loadCurrentUser();

        // Find the updated event in eventDetails and update its status
        int eventIndex = eventDetails.indexWhere((event) => event['eventDocRef'] == eventDocRef);
        if (eventIndex != -1) {
          setState(() {
            eventDetails[eventIndex]['status'] = status;
          });
        } else {
          print('Event not found in eventDetails: $eventDocRef');
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose where to post!'),
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
              itemCount: eventDetails.length,
              itemBuilder: (context, index) {
                DateTime startDate = eventDetails[index]['startDate'].toDate();
                String formattedDate = DateFormat('yyyy-MM-dd').format(startDate);

                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                  ),
                  child: ListTile(
                    title: Text('Event Title: ${eventDetails[index]['title']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Start Date: $formattedDate'),
                        Text('Start Time: ${eventDetails[index]['startTime']}'),
                        Text('Event Location: ${eventDetails[index]['eventLocation']}'),
                        SizedBox(height: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                _updateStatus(eventDetails[index]['eventDocRef'], 'Going');
                              },
                              style: ElevatedButton.styleFrom(
                                primary: eventDetails[index]['status'] == 'Going' ? Colors.green : null,
                              ),
                              child: Text('Going'),
                            ),

                            SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                _updateStatus(eventDetails[index]['eventDocRef'], 'Not Going');
                              },
                              style: ElevatedButton.styleFrom(
                                primary: eventDetails[index]['status'] == 'Not Going' ? Colors.green : null,
                              ),
                              child: Text('Not Going'),
                            ),
                            SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                _updateStatus(eventDetails[index]['eventDocRef'], 'Maybe');
                              },
                              style: ElevatedButton.styleFrom(
                                primary: eventDetails[index]['status'] == 'Maybe' ? Colors.green : null,
                              ),
                              child: Text('Maybe'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
