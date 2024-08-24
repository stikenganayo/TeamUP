import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'challenge_preview.dart';

class GoalScreen extends StatefulWidget {
  final String challengeHeader;
  final String challengeDescription;
  final List<String> challengeListTitles;
  final List<String> challengeTeams;
  final List<String> challengeFriends;
  final DateTime completionDate;
  final List<Duration?> expirationDurations;
  final int recurrenceValue;
  final String recurrenceUnit;

  GoalScreen({
    required this.challengeHeader,
    required this.challengeDescription,
    required this.challengeListTitles,
    required this.challengeTeams,
    required this.challengeFriends,
    required this.completionDate,
    required this.expirationDurations,
    required this.recurrenceValue,
    required this.recurrenceUnit,
  });

  @override
  _GoalScreenState createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  String? selectedVerification = 'photo';
  TextEditingController customVerificationController = TextEditingController();
  late Map<String, Set<String>> selectedRoles; // Changed to late initialization

  final String currentUserPlaceholder = 'You'; // Placeholder for current user

  @override
  void initState() {
    super.initState();
    // Initialize selectedRoles with 'player' for each friend
    selectedRoles = {
      for (var friend in widget.challengeFriends) friend: {'player'}
    };
  }

  void _validateAndContinue() {
    bool isValid = true;
    String errorMessage = '';

    // Check if all friends have at least one role
    for (final friend in widget.challengeFriends) {
      if (selectedRoles[friend]?.isEmpty ?? true) {
        isValid = false;
        errorMessage = 'All friends must have at least one role assigned.';
        break;
      }
    }

    // Check if Custom verification is selected and custom text is empty
    if (selectedVerification == 'custom' &&
        customVerificationController.text.trim().isEmpty) {
      isValid = false;
      errorMessage = 'Please enter a custom verification process.';
    }

    // Check if at least one role is assigned as Coach or Player
    bool hasCoach = false;
    bool hasPlayer = false;
    for (final roles in selectedRoles.values) {
      if (roles.contains('leader')) hasCoach = true;
      if (roles.contains('player')) hasPlayer = true;
    }

    if (!hasCoach || !hasPlayer) {
      isValid = false;
      errorMessage = 'You must assign at least one Coach and one Player role.';
    }

    if (isValid) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReviewPostScreen(
            challengeHeader: widget.challengeHeader,
            challengeDescription: widget.challengeDescription,
            challengeListTitles: widget.challengeListTitles,
            challengeTeams: widget.challengeTeams,
            challengeFriends: widget.challengeFriends,
            completionDate: widget.completionDate,
            expirationDurations: widget.expirationDurations,
            recurrenceValue: widget.recurrenceValue,
            recurrenceUnit: widget.recurrenceUnit,
            selectedRoles: selectedRoles,
            selectedVerification: selectedVerification,
            customVerificationProcess: selectedVerification == 'custom'
                ? customVerificationController.text
                : null,
          ),
        ),
      );
    } else {
      _showErrorDialog(errorMessage);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Exclude the current user placeholder from the list
    List<String> friendsList = widget.challengeFriends;

    return Scaffold(
      appBar: AppBar(
        title: Text('Challenge Roles & Verification'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // "Select Roles" Section
              Text(
                'Select Roles',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8), // Reduced space

              // Instructions for "Select Roles"
              Text(
                'Drag and drop the following icons onto the friends to assign them roles. To remove a role, tap the icon next to their name:',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              const SizedBox(height: 16),

              // Draggable Icons
              Row(
                children: [
                  Column(
                    children: [
                      Draggable<String>(
                        data: 'leader',
                        child: Icon(
                          Icons.verified_user,
                          size: 50,
                          color: Colors.orange,
                        ),
                        feedback: Icon(
                          Icons.verified_user,
                          size: 50,
                          color: Colors.orange.withOpacity(0.5),
                        ),
                        childWhenDragging: Container(),
                      ),
                      const SizedBox(height: 8),
                      Text('Coach', style: TextStyle(color: Colors.orange)),
                    ],
                  ),
                  const SizedBox(width: 32),
                  Column(
                    children: [
                      Draggable<String>(
                        data: 'player',
                        child: Icon(
                          Icons.sports_soccer,
                          size: 50,
                          color: Colors.green,
                        ),
                        feedback: Icon(
                          Icons.sports_soccer,
                          size: 50,
                          color: Colors.green.withOpacity(0.5),
                        ),
                        childWhenDragging: Container(),
                      ),
                      const SizedBox(height: 8),
                      Text('Player', style: TextStyle(color: Colors.green)),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16), // Reduced space

              // List of friends with DragTargets
              Container(
                height: 200, // Fixed height to prevent overflow
                child: ListView.builder(
                  itemCount: friendsList.length,
                  itemBuilder: (context, index) {
                    final friend = friendsList[index];
                    return DragTarget<String>(
                      builder: (context, candidateData, rejectedData) {
                        final roles = selectedRoles[friend] ?? {};
                        return ListTile(
                          title: Text(friend),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (roles.contains('leader'))
                                IconButton(
                                  icon: Icon(Icons.verified_user, color: Colors.orange),
                                  onPressed: () {
                                    setState(() {
                                      selectedRoles[friend]?.remove('leader');
                                      if (selectedRoles[friend]?.isEmpty ?? true) {
                                        selectedRoles.remove(friend);
                                      }
                                    });
                                  },
                                ),
                              if (roles.contains('player'))
                                IconButton(
                                  icon: Icon(Icons.sports_soccer, color: Colors.green),
                                  onPressed: () {
                                    setState(() {
                                      selectedRoles[friend]?.remove('player');
                                      if (selectedRoles[friend]?.isEmpty ?? true) {
                                        selectedRoles.remove(friend);
                                      }
                                    });
                                  },
                                ),
                              if (roles.isEmpty) Icon(Icons.person_outline),
                            ],
                          ),
                          tileColor: Colors.grey[200], // Default tile color
                        );
                      },
                      onAccept: (data) {
                        setState(() {
                          if (data == 'leader' || data == 'player') {
                            if (selectedRoles.containsKey(friend)) {
                              selectedRoles[friend]!.add(data);
                            } else {
                              selectedRoles[friend] = {data};
                            }
                          }
                        });
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 16), // Reduced space

              // "Select Verification" Section
              Text(
                'Select Verification',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8), // Reduced space

              // Instructions for "Select Verification"
              Text(
                'Choose the type of verification you want to use for this challenge. If you select "Custom," you can specify your own process:',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              const SizedBox(height: 16),

              // Verification Options
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    color: Colors.grey[200], // Grey background
                    child: RadioListTile<String>(
                      title: Text('Photo'),
                      value: 'photo',
                      groupValue: selectedVerification,
                      onChanged: (value) {
                        setState(() {
                          selectedVerification = value;
                        });
                      },
                      secondary: Icon(Icons.photo_camera),
                    ),
                  ),
                  Container(
                    color: Colors.grey[200], // Grey background
                    child: RadioListTile<String>(
                      title: Text('Video'),
                      value: 'video',
                      groupValue: selectedVerification,
                      onChanged: (value) {
                        setState(() {
                          selectedVerification = value;
                        });
                      },
                      secondary: Icon(Icons.video_collection_rounded),
                    ),
                  ),
                  Container(
                    color: Colors.grey[200], // Grey background
                    child: RadioListTile<String>(
                      title: Text('Text'),
                      value: 'text',
                      groupValue: selectedVerification,
                      onChanged: (value) {
                        setState(() {
                          selectedVerification = value;
                        });
                      },
                      secondary: Icon(Icons.text_fields),
                    ),
                  ),
                  Container(
                    color: Colors.grey[200], // Grey background
                    child: RadioListTile<String>(
                      title: Text('Location'),
                      value: 'location',
                      groupValue: selectedVerification,
                      onChanged: (value) {
                        setState(() {
                          selectedVerification = value;
                        });
                      },
                      secondary: Icon(Icons.location_on),
                    ),
                  ),
                  Container(
                    color: Colors.grey[200], // Grey background
                    child: RadioListTile<String>(
                      title: Text('Live Chat'),
                      value: 'live_chat',
                      groupValue: selectedVerification,
                      onChanged: (value) {
                        setState(() {
                          selectedVerification = value;
                        });
                      },
                      secondary: Icon(Icons.video_camera_front),
                    ),
                  ),
                  Container(
                    color: Colors.grey[200], // Grey background
                    child: RadioListTile<String>(
                      title: Text('Custom'),
                      value: 'custom',
                      groupValue: selectedVerification,
                      onChanged: (value) {
                        setState(() {
                          selectedVerification = value;
                        });
                      },
                      secondary: Icon(Icons.edit),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16), // Reduced space

              // Custom Verification Text Box
              if (selectedVerification == 'custom')
                TextField(
                  controller: customVerificationController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Custom Verification Process',
                    hintText: 'Enter your custom verification process here...',
                  ),
                  maxLines: 3,
                ),

              const SizedBox(height: 24), // Reduced space
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _validateAndContinue,
        child: Icon(Icons.check),
      ),
    );
  }
}