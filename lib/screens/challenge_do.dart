import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'dart:math';

import '../widgets/verification_phot.dart'; // Import for generating random pastel colors
import '../widgets/verified_photo.dart';

class DoChallenge extends StatefulWidget {
  final Map<String, dynamic> challenge;

  const DoChallenge({
    Key? key,
    required this.challenge,
  }) : super(key: key);

  @override
  _DoChallengeState createState() => _DoChallengeState();
}

class _DoChallengeState extends State<DoChallenge> {
  String? userName;
  bool isLoading = true;
  bool isFriendsLoading = true;
  Map<String, dynamic>? challengeDetails;
  List<String> challengeFriends = [];
  List<String> challengeListTitles = []; // New list to hold checklist items
  Map<String, bool> checkedItems = {}; // New map to track checked items
  Color backgroundColor = Colors.white;
  Color appBarColor = Colors.pink.shade100;
  String selectedVerification = '';
  String id = '';
  Map<String, dynamic>? challengeListCompleted;
  String progressStatus = '0/0';
  double progressStatuses = 0.0;


  @override
  void initState() {
    super.initState();
    _loadCurrentUserName();
    _fetchChallengeDetails();
    _setColorsBasedOnDimension();
  }

  Future<void> _loadCurrentUserName() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        print('Current User Email: ${currentUser.email}');

        QuerySnapshot userQuerySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: currentUser.email)
            .limit(1)
            .get();

        if (userQuerySnapshot.docs.isNotEmpty) {
          DocumentSnapshot userSnapshot = userQuerySnapshot.docs.first;
          Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;

          print('User Data: $userData');

          if (userData.containsKey('name')) {
            setState(() {
              userName = userData['name'] as String;
            });
          } else {
            print('Name field not found in user document');
          }
        } else {
          print('User document not found for the current user');
        }
      }
    } catch (e) {
      print('Error loading user document: $e');
    }
  }

  Future<void> _fetchChallengeDetails() async {
    try {
      String id = widget.challenge['id'] ?? '';
      if (id.isNotEmpty) {
        DocumentSnapshot challengeSnapshot = await FirebaseFirestore.instance
            .collection('team_challenges')
            .doc(id)
            .get();

        if (challengeSnapshot.exists) {
          Map<String, dynamic> data = challengeSnapshot.data() as Map<String, dynamic>;

          setState(() {
            challengeDetails = data;
            challengeFriends = List<String>.from(data['challengeFriends'] ?? []);
            challengeListTitles = List<String>.from(data['challengeListTitles'] ?? []);

            // Initialize checkedItems and challengeListCompleted
            checkedItems = Map.fromIterable(
              challengeListTitles,
              key: (item) => item as String,
              value: (item) => false,
            );

            // Extract challengeListCompleted from Firebase data
            challengeListCompleted = Map<String, dynamic>.from(data['challengeListCompleted'] ?? {});

            // Count how many items are completed by the current user
            int? completedItems = challengeListCompleted?.entries
                .where((entry) => entry.value.contains(userName ?? 'Unknown User'))
                .length;

            // Calculate the total number of items
            int totalItems = challengeListTitles.length;

            // Set progressStatus as completed/total in fraction format
            progressStatus = '$completedItems/$totalItems';
            double progressStatuses = completedItems!/totalItems;

            // Update Firestore with the new progressStatuses
            FirebaseFirestore.instance
                .collection('team_challenges')
                .doc(id)
                .update({'progressStatuses': progressStatuses});

            // Set additional fields
            selectedVerification = data['selectedVerification'] ?? 'unknown';
            isLoading = false;
            isFriendsLoading = false;
            _setColorsBasedOnDimension();
          });

          await _fetchSelectedRoles(id);
          print('Challenge Details: $challengeDetails');
          print('Challenge Friends: $challengeFriends');
          print('Progress Status: $progressStatus');
        } else {
          print('Challenge document not found for ID: $id');
        }
      } else {
        print('No challenge ID provided');
      }
    } catch (e) {
      print('Error fetching challenge details: $e');
    }
  }

  Future<void> _fetchSelectedRoles(String challengeId) async {
    try {
      DocumentSnapshot challengeSnapshot = await FirebaseFirestore.instance
          .collection('team_challenges')
          .doc(challengeId)
          .collection('selectedRoles')
          .doc('roles')
          .get();

      if (challengeSnapshot.exists) {
        Map<String, dynamic> selectedRoles = challengeSnapshot.data() as Map<String, dynamic>;
        setState(() {
          // Update roles based on Firestore data
          challengeFriends.forEach((friend) {
            List<String> roles = List<String>.from(selectedRoles[friend] ?? []);
            bool isCoach = roles.contains('leader');
            bool isPlayer = roles.contains('player');

            // You can now use isCoach and isPlayer for display purposes
            // For example, update a list or map with this information if needed
          });
        });
      } else {
        print('Selected roles document not found for challenge ID: $challengeId');
      }
    } catch (e) {
      print('Error fetching selected roles: $e');
    }
  }

  void _setColorsBasedOnDimension() {
    String dimension = challengeDetails?['dimension'] ?? '';
    switch (dimension) {
      case 'emotional':
        backgroundColor = Colors.pink.shade100;
        break;
      case 'physical':
        backgroundColor = Colors.blueGrey.shade100;
        break;
      case 'occupational':
        backgroundColor = Colors.orange.shade100;
        break;
      case 'social':
        backgroundColor = Colors.blueGrey.shade100;
        break;
      case 'spiritual':
        backgroundColor = Colors.purple.shade100;
        break;
      case 'intellectual':
        backgroundColor = Colors.yellow.shade100;
        break;
      case 'environmental':
        backgroundColor = Colors.green.shade100;
        break;
      case 'financial':
        backgroundColor = Colors.lightBlue.shade100;
        break;
      default:
        backgroundColor = Colors.white;
    }
  }

  Color _generatePastelColor() {
    Random random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(128) + 127, // Light red component
      random.nextInt(128) + 127, // Light green component
      random.nextInt(128) + 127, // Light blue component
    );
  }

  String _getInitials(String name) {
    List<String> parts = name.split(' ');
    if (parts.length > 1) {
      return '${parts[0].substring(0, min(3, parts[0].length))}${parts[1].substring(0, min(3, parts[1].length))}'.toUpperCase();
    } else if (parts.isNotEmpty) {
      return '${parts[0].substring(0, min(3, parts[0].length))}'.toUpperCase();
    } else {
      return '';
    }
  }

  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return '';
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    bool isCoach = false;
    bool isPlayer = false;

    challengeFriends.forEach((friend) {
      if (friend == userName) { // Check if current user is in the list
        List<String> roles = List<String>.from(challengeDetails?['selectedRoles'][friend] ?? []);
        isCoach = roles.contains('leader');
        isPlayer = roles.contains('player');
      }
    });

    String title = widget.challenge['title'] ?? 'No Title';
    String id = widget.challenge['id'] ?? 'No id';
    String description = widget.challenge['description'] ?? 'No Description';

    String formattedDate = '';
    if (challengeDetails != null) {
      DateTime? completionDate = (challengeDetails!['completionDate'] as Timestamp?)?.toDate();
      if (completionDate != null) {
        formattedDate = DateFormat('MMM d').format(completionDate);
        String time = DateFormat('h:mm a').format(completionDate);
        formattedDate = '$formattedDate\n$time';
      }
    }

    return Scaffold(
        backgroundColor: backgroundColor, // Set background color based on dimension
        appBar: AppBar(
          toolbarHeight: 100, // Increased height for better spacing
          backgroundColor: backgroundColor, // Set app bar color based on dimension
          title: null, // We will use FlexibleSpace for custom title
          flexibleSpace: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  ' ', // Added title
                  style: GoogleFonts.montserrat(
                    textStyle: Theme.of(context).textTheme.headline5?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 24, // Adjust the font size as needed
                      color: Colors.black, // Customize color if needed
                    ),
                  ),
                ),
                SizedBox(height: 8), // Space between "HELLO" and the existing title
                Text(
                  challengeDetails?['challengeHeader'] ?? 'No Header',
                  style: GoogleFonts.montserrat(
                    textStyle: Theme.of(context).textTheme.headline4?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 28, // Adjust the font size as needed
                    ),
                  ),
                ),
                SizedBox(height: 8), // Increased space between title and date/progress
                if (challengeDetails != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_month, color: Colors.blueGrey), // Calendar icon
                      SizedBox(width: 16), // Space between icon and text
                      Text(
                        formattedDate.isNotEmpty ? formattedDate : 'No Date',
                        style: GoogleFonts.montserrat(
                          textStyle: Theme.of(context).textTheme.subtitle1?.copyWith(
                            color: Colors.blueGrey,
                          ),
                        ),
                      ),
                      SizedBox(width: 80),
                      CircularProgressIndicator(
                        value: progressStatuses, // Use the calculated progress value
                        strokeWidth: 6, // Thicker stroke width for the progress indicator
                        color: Colors.green, // Custom color for the progress indicator
                        backgroundColor: Colors.grey, // Background color for the progress indicator
                      ),
                      SizedBox(width: 8),
                      Text(
                        progressStatus, // Display progress status
                        style: GoogleFonts.montserrat(
                          textStyle: Theme.of(context).textTheme.subtitle1?.copyWith(
                            color: Colors.blueGrey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
        body: Center(
          child: isLoading
              ? CircularProgressIndicator()
              : Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: Offset(0, 4), // Changes position of shadow
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_capitalizeFirstLetter(challengeDetails?['dimension'] ?? 'No Dimension')} Challenge',
                  style: GoogleFonts.montserrat(
                    textStyle: Theme.of(context).textTheme.headline6?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                Text(
                  description,
                  style: GoogleFonts.montserrat(
                    textStyle: Theme.of(context).textTheme.bodyText1?.copyWith(
                      fontSize: 16,
                    ),
                  ),
                ),
                SizedBox(height: 32),
                Row(
                  children: [
                    Icon(Icons.group, size: 24), // Members icon
                    SizedBox(width: 8),
                    Text(
                      'Members:',
                      style: GoogleFonts.montserrat(
                        textStyle: Theme.of(context).textTheme.headline6?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                if (isFriendsLoading)
                  Center(child: CircularProgressIndicator())
                else
                  Container(
                    height: 80, // Adjust height to accommodate text
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: challengeFriends.length + 1,
                      // +1 for the plus button
                      itemBuilder: (context, index) {
                        if (index < challengeFriends.length) {
                          String friendName = challengeFriends[index];

                          // Fetch roles from Firestore
                          List<String> roles = List<String>.from(
                              challengeDetails?['selectedRoles'][friendName] ?? [
                              ]);
                          bool isCoach = roles.contains('leader');
                          bool isPlayer = roles.contains('player');

                          List<Widget> roleIcons = [];

                          if (isCoach && isPlayer) {
                            roleIcons.addAll([
                              Icon(Icons.verified_user, size: 14,
                                  color: Colors.orange),
                              Icon(Icons.sports_soccer, size: 14,
                                  color: Colors.green),
                            ]);
                          } else if (isCoach) {
                            roleIcons.add(
                              Icon(Icons.verified_user, size: 14,
                                  color: Colors.orange),
                            );
                          } else if (isPlayer) {
                            roleIcons.add(
                              Icon(Icons.sports_soccer, size: 14,
                                  color: Colors.green),
                            );
                          }
                          return Container(
                            margin: EdgeInsets.only(right: 16),
                            child: Column(
                              children: [
                                Stack(
                                  alignment: Alignment.bottomRight,
                                  children: [
                                    CircleAvatar(
                                      radius: 25, // Smaller radius
                                      backgroundColor: _generatePastelColor(), // Pastel color
                                      child: Text(
                                        _getInitials(friendName),
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14, // Smaller font size
                                        ),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: roleIcons.map((icon) {
                                        return Padding(
                                          padding: const EdgeInsets.only(left: 2.0),
                                          child: CircleAvatar(
                                            radius: 8,
                                            backgroundColor: Colors.white,
                                            child: icon,
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '1/3', // Progress text
                                  style: TextStyle(fontSize: 12, color: Colors.black),
                                ),
                              ],
                            ),
                          );
                        } else {
                          // Plus button
                          return Container(
                            margin: EdgeInsets.only(right: 16),
                            child: CircleAvatar(
                              radius: 25, // Smaller radius
                              backgroundColor: Colors.grey.shade300, // Grey color for the button
                              child: Icon(
                                Icons.add,
                                color: Colors.black,
                                size: 18, // Adjust icon size as needed
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                if (isCoach && !isPlayer || isCoach && isPlayer) ...[ // Show Verify section if user is a leader only
                  SizedBox(height: 32),
                  Row(
                    children: [
                      Icon(Icons.verified, size: 24), // Added "Verify" icon
                      SizedBox(width: 8),
                      Text(
                        'Verify:',
                        style: GoogleFonts.montserrat(
                          textStyle: Theme.of(context).textTheme.headline6?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8), // Add some space between the header and the items
                  Expanded(
                    child: challengeListCompleted?.entries.any((entry) {
                      final completedData = entry.value;
                      // Check if any item has neither 'approved' nor 'rejected'
                      return !completedData.contains('approved') && !completedData.contains('rejected');
                    }) ?? false
                        ? ListView.builder(
                      itemCount: (challengeListCompleted?.entries.where((entry) {
                        final completedData = entry.value;
                        // Filter out items with 'approved' or 'rejected'
                        return !completedData.contains('approved') && !completedData.contains('rejected');
                      }).toList().length ?? 0),
                      itemBuilder: (context, index) {
                        final filteredEntries = challengeListCompleted?.entries.where((entry) {
                          final completedData = entry.value;
                          // Filter out items with 'approved' or 'rejected'
                          return !completedData.contains('approved') && !completedData.contains('rejected');
                        }).toList() ?? [];

                        final item = filteredEntries[index].key;
                        final completedData = filteredEntries[index].value;

                        // Determine the status and icon color
                        Color iconColor = Colors.grey; // Default to grey
                        final completedStatus = completedData.contains('approved') ? 'approved' :
                        completedData.contains('rejected') ? 'rejected' : '';
                        if (completedStatus == 'approved') {
                          iconColor = Colors.green;
                        } else if (completedStatus == 'rejected') {
                          iconColor = Colors.red;
                        }

                        final parts = completedData.split(' - ');
                        final user = parts.first;
                        final imageUrl = parts.length > 1 ? parts.last : '';

                        return GestureDetector(
                          onTap: () {
                            // Allow interaction only if item is neither approved nor rejected
                            if (iconColor == Colors.grey) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChallengeDetailScreen(
                                    imageUrl: imageUrl,
                                    userName: user,
                                    itemTitle: item,
                                    challengeId: id,
                                    currentUser: userName ?? 'Unknown User', // Pass challengeId here
                                  ),
                                ),
                              );
                            }
                          },
                          child: Container(
                            margin: EdgeInsets.only(bottom: 16),
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  spreadRadius: 2,
                                  blurRadius: 4,
                                  offset: Offset(0, 2), // Changes position of shadow
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Display image if available
                                if (imageUrl.isNotEmpty)
                                  Container(
                                    width: 60, // Smaller width for the image
                                    height: 60, // Smaller height for the image
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      image: DecorationImage(
                                        image: NetworkImage(imageUrl),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                SizedBox(width: 8),
                                // Display challenge item title
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item ?? 'No Title',
                                        style: GoogleFonts.montserrat(
                                          textStyle: Theme.of(context).textTheme.subtitle1?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Completed by: $user',
                                        style: GoogleFonts.montserrat(
                                          textStyle: Theme.of(context).textTheme.bodyText2?.copyWith(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 8),
                                // Display check icon with dynamic color
                                Icon(
                                  Icons.check_circle,
                                  color: iconColor, // Set the icon color based on status
                                  size: 24,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                        : Center(
                      child: Text(
                        'Nothing to verify',
                        style: GoogleFonts.montserrat(
                          textStyle: Theme.of(context).textTheme.headline6?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                if (!isCoach && isPlayer || isCoach && isPlayer) ...[
                  SizedBox(height: 32),
                  Row(
                    children: [
                      Icon(Icons.checklist, size: 24), // Checklist icon
                      SizedBox(width: 8),
                      Text(
                        'Checklist:',
                        style: GoogleFonts.montserrat(
                          textStyle: Theme.of(context).textTheme.headline6?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Spacer(),
                      Icon(
                        selectedVerification == 'photo'
                            ? Icons.photo_camera
                            : selectedVerification == 'video'
                            ? Icons.video_call_rounded
                            : selectedVerification == 'text'
                            ? Icons.text_snippet
                            : selectedVerification == 'location'
                            ? Icons.location_on
                            : selectedVerification == 'live_chat'
                            ? Icons.video_camera_front_rounded
                            : selectedVerification == 'custom'
                            ? Icons.dashboard_customize
                            : Icons.help, // Default icon if no match
                        color: Colors.black, // Set the color for the header icon
                        size: 24,
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: challengeListTitles.length,
                      itemBuilder: (context, index) {
                        final itemTitle = challengeListTitles[index];

                        // Initialize verificationIcon with a default value
                        Icon verificationIcon = Icon(
                          Icons.check_circle,
                          color: Colors.grey,
                        );

                        // Initialize other variables
                        bool isCompleted = false;
                        Color verifiedUserColor = Colors.grey; // Default color

                        if (challengeListCompleted!.containsKey(itemTitle)) {
                          String completedData = challengeListCompleted?[itemTitle] ?? '';
                          if (completedData.startsWith(userName ?? 'Unknown User')) {
                            isCompleted = true;
                            verificationIcon = Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            );
                            verifiedUserColor = Colors.grey;
                          } else if (completedData.startsWith('approved')) {
                            isCompleted = true;
                            verificationIcon = Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            );
                            verifiedUserColor = Colors.green;
                          } else if (completedData.startsWith('rejected')) {
                            isCompleted = false;
                            verificationIcon = Icon(
                              Icons.cancel,
                              color: Colors.red,
                            );
                            verifiedUserColor = Colors.red;
                          }
                        }

                        return Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (selectedVerification == 'photo' &&
                                    (verifiedUserColor == Colors.red || verifiedUserColor == Colors.grey)) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => VerifyCameraScreen(
                                        currentUser: userName ?? 'Unknown User',
                                        checklistItemTitle: itemTitle,
                                        itemTitle: itemTitle,
                                        challengeId: id, // Pass the challenge ID here
                                      ),
                                    ),
                                  );
                                } else {
                                  print('Selected Verification: $selectedVerification');
                                }
                              },
                              child: Checkbox(
                                value: isCompleted, // Set the checkbox state based on completion
                                onChanged: null, // Disable the checkbox interaction
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(itemTitle),
                            Spacer(),
                            Row(
                              children: [
                                verificationIcon, // Show the icon based on selectedVerification and completion status
                                SizedBox(width: 8), // Add spacing between the icons
                                Icon(Icons.verified_user, color: verifiedUserColor), // Add the verified_user icon
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        )
    );
  }
}