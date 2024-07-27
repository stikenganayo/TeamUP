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

  GoalScreen({
    required this.challengeHeader,
    required this.challengeDescription,
    required this.challengeListTitles,
    required this.challengeTeams,
    required this.challengeFriends,
    required this.completionDate,
    required this.expirationDurations,
  });

  @override
  _GoalScreenState createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  String? selectedVerification = 'photo';
  TextEditingController customVerificationController = TextEditingController();
  Map<String, Set<String>> selectedRoles = {};
  final String currentUserPlaceholder = 'You'; // Placeholder for current user

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
                'Drag and drop the following icons onto the friends to assign them roles. To remove a role, tap the icon next to their  name:',
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
                    ),
                  ),
                  if (selectedVerification == 'custom')
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: TextFormField(
                        controller: customVerificationController,
                        decoration: InputDecoration(
                          labelText: 'Enter Custom Process',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                    ),
                ],
              ),
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