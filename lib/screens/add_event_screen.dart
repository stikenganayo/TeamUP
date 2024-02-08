import 'package:flutter/material.dart';
import 'package:snapchat_ui_clone/screens/selection_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateEvent extends StatefulWidget {
  const CreateEvent({Key? key}) : super(key: key);

  @override
  _CreateEventState createState() => _CreateEventState();
}

class _CreateEventState extends State<CreateEvent> {
  String eventTitle = "";
  DateTime startDate = DateTime.now();
  TimeOfDay startTime = TimeOfDay.now();
  DateTime endDate = DateTime.now();
  TimeOfDay endTime = TimeOfDay.now();
  String eventLocation = "";
  String eventDescription = "";
  bool canPostEvent = false;

  TextEditingController eventDescriptionController = TextEditingController();
  FocusNode eventDescriptionFocusNode = FocusNode();

  late User? currentUser;
  List<String> selectedFriends = [];
  List<String> selectedTeams = [];

  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      print('Current User ID: ${currentUser!.uid}');
    } else {
      print('Current User is null');
    }
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime pickedDate = (await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    ))!;
    if (pickedDate != null && pickedDate != startDate) {
      setState(() {
        startDate = pickedDate;
      });
    }
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay pickedTime = (await showTimePicker(
      context: context,
      initialTime: startTime,
    ))!;
    if (pickedTime != null && pickedTime != startTime) {
      setState(() {
        startTime = pickedTime;
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime pickedDate = (await showDatePicker(
      context: context,
      initialDate: endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    ))!;
    if (pickedDate != null && pickedDate != endDate) {
      setState(() {
        endDate = pickedDate;
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay pickedTime = (await showTimePicker(
      context: context,
      initialTime: endTime,
    ))!;
    if (pickedTime != null && pickedTime != endTime) {
      setState(() {
        endTime = pickedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Event Template!'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                TextField(
                  onChanged: (value) {
                    setState(() {
                      eventTitle = value;
                      canPostEvent =
                          eventTitle.isNotEmpty && eventLocation.isNotEmpty;
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Event Title'),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: eventDescriptionController,
                  focusNode: eventDescriptionFocusNode,
                  onChanged: (value) {
                    setState(() {
                      eventDescription = value;
                    });
                  },
                  onSubmitted: (_) {
                    eventDescriptionFocusNode.unfocus(); // Close the keyboard
                  },
                  decoration: InputDecoration(
                    labelText: 'Event Description',
                    labelStyle: TextStyle(fontSize: 16),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                Row(
                  children: <Widget>[
                    TextButton(
                      onPressed: () => _selectStartDate(context),
                      child: const Text(
                        'Select Start Date',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Text(
                      '${startDate.toLocal()}'.split(' ')[0],
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    TextButton(
                      onPressed: () => _selectEndDate(context),
                      child: const Text(
                        'Select End Date',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Text(
                      '${endDate.toLocal()}'.split(' ')[0],
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    TextButton(
                      onPressed: () => _selectStartTime(context),
                      child: const Text(
                        'Select Start Time',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    SizedBox(width: 20),
                    Text(
                      '${startTime.format(context)}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    TextButton(
                      onPressed: () => _selectEndTime(context),
                      child: const Text(
                        'Select End Time',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Text(
                      '${endTime.format(context)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  onChanged: (value) {
                    setState(() {
                      eventLocation = value;
                      canPostEvent =
                          eventTitle.isNotEmpty && eventLocation.isNotEmpty;
                    });
                  },
                  decoration: const InputDecoration(
                      labelText: 'Event Location'),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Checkbox(
                      value: canPostEvent,
                      onChanged: (value) {
                        setState(() {
                          canPostEvent = value!;
                        });
                      },
                    ),
                    Text(
                      'Post to community page',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                SizedBox(height: 10),

                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SelectionScreen(),
                      ),
                    ).then((result) {
                      if (result != null && result is Map<String, dynamic>) {
                        setState(() {
                          selectedFriends.clear();
                          if (result.containsKey('friends') &&
                              result['friends'] is List<String>) {
                            selectedFriends.addAll(result['friends']);
                          }

                          selectedTeams.clear();
                          if (result.containsKey('teams') &&
                              result['teams'] is List<String>) {
                            selectedTeams.addAll(result['teams']);
                          }

                          // Update canPostEvent based on selectedFriends and selectedTeams
                          canPostEvent = eventTitle.isNotEmpty &&
                              eventLocation.isNotEmpty &&
                              (selectedFriends.isNotEmpty ||
                                  selectedTeams.isNotEmpty);
                        });
                      }
                    });
                  },
                  child: const Text('Choose where to post Event'),
                ),

                const SizedBox(height: 20),


                // Display selected friends and teams
                if (selectedFriends.isNotEmpty || selectedTeams.isNotEmpty)
                  Column(
                    children: [
                      Text(
                        'Posting to:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          ...selectedFriends.map(
                                (friendName) =>
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Chip(
                                    label: Text(friendName),
                                    backgroundColor: Colors.grey,
                                  ),
                                ),
                          ),
                          ...selectedTeams.map(
                                (teamName) =>
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Chip(
                                    label: Text(teamName),
                                    backgroundColor: Colors
                                        .blue, // Choose the color for teams
                                  ),
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),

                const SizedBox(height: 20),


                ElevatedButton(
                  onPressed: canPostEvent
                      ? () async {
                    if (_isDisposed) return; // Check if the widget is disposed
                    try {
                      await postEvent();
                      if (!_isDisposed) {
                        Navigator.pop(context); // Close the screen if not disposed
                      }
                    } catch (e) {
                      if (!_isDisposed) {
                        print('Error posting event: $e');
                      }
                    }
                  }
                      : null,
                  child: const Text('Create Event'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> postEvent() async {
    try {
      currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        print('Current User Email: ${currentUser!.email}');

        // Fetch user data based on the provided email
        QuerySnapshot userQuerySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: currentUser!.email)
            .limit(1)
            .get();

        if (mounted && userQuerySnapshot.docs.isNotEmpty) {
          DocumentSnapshot userSnapshot = userQuerySnapshot.docs.first;
          Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;

          // Create a reference to the 'events' collection
          CollectionReference eventsCollection = FirebaseFirestore.instance.collection('events');

          if (mounted) {
            // Add the event data as a new document in the 'events' collection
            DocumentReference eventDocRef = await eventsCollection.add({
              'CurrentUserEmail': currentUser!.email,
              'CurrentUserName': userData['name'], // Store the user's name
              'eventTitle': eventTitle,
              'startDate': startDate,
              'startTime': startTime.format(context),
              'endDate': endDate,
              'endTime': endTime.format(context),
              'eventLocation': eventLocation,
              'eventDescription': eventDescription,
              'selectedFriends': selectedFriends,
              'selectedTeams': selectedTeams,
              'attending': 0,
              'communityEvent': canPostEvent,
            });

            print('Event Posted:');
            print('Event Title: $eventTitle');
            print('Start Date: $startDate');
            print('Start Time: ${startTime.format(context)}');
            print('End Date: $endDate');
            print('End Time: ${endTime.format(context)}');
            print('Event Location: $eventLocation');
            print('Event Description: $eventDescription');
            print('Selected Friends: $selectedFriends');
            print('Selected Teams: $selectedTeams');

            // Iterate through selectedFriends and update user's events
            for (String friendName in selectedFriends) {
              // Find friend's ID in the 'users' collection
              QuerySnapshot friendQuerySnapshot = await FirebaseFirestore.instance
                  .collection('users')
                  .where('name', isEqualTo: friendName)
                  .limit(1)
                  .get();

              if (mounted && friendQuerySnapshot.docs.isNotEmpty) {
                DocumentSnapshot friendSnapshot = friendQuerySnapshot.docs.first;
                String friendId = friendSnapshot.id;

                // Update the user's document with the event data
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(friendId)
                    .update({
                  'user_events': FieldValue.arrayUnion([
                    {
                      'eventTitle': eventTitle,
                      'eventDocRef': eventDocRef.id, // Store a reference to the event document
                      'status': 'pending',
                    }
                  ])
                });
              }
            }
            // Iterate through selectedTeams and update users' events
            for (String teamName in selectedTeams) {
              // Find team's ID in the 'teams' collection
              QuerySnapshot teamQuerySnapshot = await FirebaseFirestore.instance
                  .collection('teams')
                  .where('team_name', isEqualTo: teamName)
                  .limit(1)
                  .get();

              if (mounted && teamQuerySnapshot.docs.isNotEmpty) {
                DocumentSnapshot teamSnapshot = teamQuerySnapshot.docs.first;
                String teamId = teamSnapshot.id;

                // Get the list of users in the selected team
                List<String> teamMembers = List<String>.from(teamSnapshot['users'] ?? []);

                // Print the users in the selected team
                print('Users in $teamName:');
                for (String teamMember in teamMembers) {
                  print('- $teamMember');
                }

                // Update the team's document with the event data
                await FirebaseFirestore.instance
                    .collection('teams')
                    .doc(teamId)
                    .update({
                  'user_events': FieldValue.arrayUnion([
                    {
                      'eventTitle': eventTitle,
                      'eventDocRef': eventDocRef.id, // Store a reference to the event document
                      'status': 'pending',
                    }
                  ])
                });

                // Iterate through each user and update their 'team_events'
                for (String teamMember in teamMembers) {
                  // Find the user's ID in the 'users' collection
                  QuerySnapshot userQuerySnapshot = await FirebaseFirestore.instance
                      .collection('users')
                      .where('name', isEqualTo: teamMember)
                      .limit(1)
                      .get();

                  if (userQuerySnapshot.docs.isNotEmpty) {
                    DocumentSnapshot userSnapshot = userQuerySnapshot.docs.first;
                    String userId = userSnapshot.id;

                    // Update the user's document with the event data
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(userId)
                        .update({
                      'team_events': FieldValue.arrayUnion([
                        {
                          'eventTitle': eventTitle,
                          'eventDocRef': eventDocRef.id, // Store a reference to the event document
                          'status': 'pending',
                        }
                      ])
                    });
                  }
                }
              }
            }
          }
        } else {
          if (!_isDisposed) {
            print('User document not found for the current user');
          }
        }
      } else {
        if (!_isDisposed) {
          print('Current User is null');
        }
      }
    } catch (e, stackTrace) {
      if (!_isDisposed) {
        print('Error posting event: $e');
        print('StackTrace: $stackTrace');
      }
    }
  }





}
