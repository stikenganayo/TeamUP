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

class ListScreen extends StatefulWidget {
  const ListScreen({Key? key}) : super(key: key);

  @override
  _ListScreenScreenState createState() => _ListScreenScreenState();
}

class _ListScreenScreenState extends State<ListScreen> {
  late User? currentUser;
  List<String> teamIds = [];
  List<Map<String, dynamic>> eventDetails = [];
  String selectedFilter = 'All';

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

          List<Map<String, dynamic>> filteredEvents = [];

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
                print('Status: ${event['status']}');

                if (selectedFilter == 'All' || event['status'] == selectedFilter) {
                  filteredEvents.add({
                    'title': eventData['eventTitle'],
                    'startDate': eventData['startDate'],
                    'startTime': eventData['startTime'] ?? '',
                    'eventLocation': eventData['eventLocation'] ?? '',
                    'status': event['status'] ?? '',
                    'eventDocRef': eventDocRef,
                  });
                }
              } else {
                print('Event document not found for eventDocRef: $eventDocRef');
              }
            }

            // Sort and filter events based on the start date
            filteredEvents = _filterEvents(selectedFilter, filteredEvents);
          } else {
            print('team_events field not found in user document');
          }

          if (userData.containsKey('team_ids')) {
            setState(() {
              teamIds = List.from(userData['team_ids']);
              eventDetails = filteredEvents;
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

        List<dynamic> teamEvents = List.from(userSnapshot['team_events']);
        for (int i = 0; i < teamEvents.length; i++) {
          if (teamEvents[i]['eventDocRef'] == eventDocRef) {
            teamEvents[i]['status'] = status;
            break;
          }
        }

        await userSnapshot.reference.update({'team_events': teamEvents});
      } else {
        print('User document not found for the current user');
      }
    } catch (e) {
      print('Error updating status: $e');
    }
  }

  List<Map<String, dynamic>> _filterEvents(String filter, List<Map<String, dynamic>> events) {
    DateTime currentDate = DateTime.now();

    List<Map<String, dynamic>> upcomingEvents = events
        .where((event) =>
    (filter == 'All' || event['status'] == filter) &&
        event['startDate'].toDate().isAfter(currentDate))
        .toList();

    List<Map<String, dynamic>> pastEvents = events
        .where((event) =>
    (filter == 'All' || event['status'] == filter) &&
        event['startDate'].toDate().isBefore(currentDate))
        .toList();

    upcomingEvents.sort((a, b) => a['startDate'].compareTo(b['startDate']));
    pastEvents.sort((a, b) => b['startDate'].compareTo(a['startDate']));

    return [...upcomingEvents, ...pastEvents];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButton<String>(
                value: selectedFilter,
                items: ['All', 'Going', 'Not Going', 'Maybe', 'Pending']
                    .map((filter) => DropdownMenuItem<String>(
                  value: filter,
                  child: Text(filter),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedFilter = value!;
                    _loadCurrentUser();
                  });
                },
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: eventDetails.length,
              itemBuilder: (context, index) {
                DateTime startDate = eventDetails[index]['startDate'].toDate();
                String formattedDate = DateFormat('MMMM d, y').format(startDate);

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
                        ),
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
