import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class StatusButton extends StatefulWidget {
  final String buttonText;
  final String eventDocRef;
  final String currentStatus;
  final Function(String) onPressed;

  const StatusButton({
    Key? key,
    required this.buttonText,
    required this.eventDocRef,
    required this.currentStatus,
    required this.onPressed,
  }) : super(key: key);

  @override
  _StatusButtonState createState() => _StatusButtonState();
}

class _StatusButtonState extends State<StatusButton> {
  @override
  Widget build(BuildContext context) {
    // Check if the button text matches the current status text in Firebase
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
                print('Status: ${event['status']}'); // Fetch status from the event data

                // Handle potential null values for 'startTime' and 'eventLocation'
                eventDetails.add({
                  'title': eventData['eventTitle'],
                  'startDate': eventData['startDate'],
                  'startTime': eventData['startTime'] ?? '',
                  'eventLocation': eventData['eventLocation'] ?? '',
                  'status': event['status'] ?? '', // Fetch status from the event data
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
      } else {
        print('User document not found for the current user');
      }
    } catch (e) {
      print('Error updating status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sort events by status, placing "Pending" events at the top
    eventDetails.sort((a, b) {
      if (a['status'] == 'pending' && b['status'] != 'pending') {
        return -1;
      } else if (a['status'] != 'pending' && b['status'] == 'pending') {
        return 1;
      } else {
        // For non-pending events, sort by start date
        return a['startDate'].compareTo(b['startDate']);
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
              itemCount: eventDetails.length,
              itemBuilder: (context, index) {
                DateTime startDate = eventDetails[index]['startDate'].toDate();
                String formattedDate = DateFormat('MMMM d, y').format(startDate); // Updated date format

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
                        Text(
                          'Your Current Status: ${eventDetails[index]['status']}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ), // Added section to display current status
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(
                              child: StatusButton(
                                buttonText: 'Going',
                                eventDocRef: eventDetails[index]['eventDocRef'],
                                currentStatus: eventDetails[index]['status'],
                                onPressed: (status) {
                                  _updateStatus(eventDetails[index]['eventDocRef'], status);
                                  // Update the local eventDetails list with the new status
                                  setState(() {
                                    eventDetails[index]['status'] = status;
                                  });
                                },
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: StatusButton(
                                buttonText: 'Not Going',
                                eventDocRef: eventDetails[index]['eventDocRef'],
                                currentStatus: eventDetails[index]['status'],
                                onPressed: (status) {
                                  _updateStatus(eventDetails[index]['eventDocRef'], status);
                                  // Update the local eventDetails list with the new status
                                  setState(() {
                                    eventDetails[index]['status'] = status;
                                  });
                                },
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: StatusButton(
                                buttonText: 'Maybe',
                                eventDocRef: eventDetails[index]['eventDocRef'],
                                currentStatus: eventDetails[index]['status'],
                                onPressed: (status) {
                                  _updateStatus(eventDetails[index]['eventDocRef'], status);
                                  // Update the local eventDetails list with the new status
                                  setState(() {
                                    eventDetails[index]['status'] = status;
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
              },
            ),
          ),
        ],
      ),
    );
  }
}
