import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'dart:math';

import '../widgets/verification_phot.dart'; // Import for generating random pastel colors
import '../widgets/verified_photo.dart';
import 'challenge_story.dart';

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
  List<int> expirationDurations = [];

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

            // Extract challengeListCompleted from Firebase data in the new format
            challengeListCompleted = (data['challengeListCompleted'] as Map<String, dynamic>)?.map(
                  (key, value) {
                // Get player name, imageUrl, leader, and status from the new structure
                return MapEntry(key, {
                  'player': value['player'] ?? '',
                  'imageUrl': value['imageUrl'] ?? '',
                  'leader': value['leader'] ?? '',
                  'status': value['status'] ?? '',
                });
              },
            );

            // Fetch creationDate and expirationDurations
            DateTime creationDate = (data['creationDate'] as Timestamp).toDate(); // Convert Timestamp to DateTime
            expirationDurations = List<int>.from(data['expirationDurations'] ?? []);

            // Calculate the expiration time for each checklist item
            List<DateTime> expirationTimes = [];
            for (int i = 0; i < expirationDurations.length; i++) {
              if (i == 0) {
                // For the first item, add the first duration to creationDate
                expirationTimes.add(creationDate.add(Duration(minutes: expirationDurations[i])));
              } else {
                // For subsequent items, add the duration of the current item to the expiration time of the previous item
                expirationTimes.add(expirationTimes[i - 1].add(Duration(minutes: expirationDurations[i])));
              }
            }

            // Count how many items are completed by the current user
            int? completedItems = challengeListCompleted?.entries
                .where((entry) => entry.value['player'] == userName)
                .where((entry) => entry.value['status'] == 'approved' || entry.value['status'] == 'rejected' || entry.value['status'].isEmpty)
                .length;

            // Calculate the total number of items
            int totalItems = challengeListTitles.length;

            // Set progressStatus as completed/total in fraction format
            progressStatus = '$completedItems/$totalItems';
            double progressStatuses = (completedItems ?? 0) / totalItems;

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

    final allZero = expirationDurations.every((duration) => duration == 0);

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
                    FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('team_challenges')
                          .doc(id) // Use your specific challenge document ID
                          .get(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return CircularProgressIndicator(
                            value: null, // Show indeterminate progress if data is not ready
                            strokeWidth: 6,
                            color: Colors.green,
                            backgroundColor: Colors.grey,
                          );
                        }

                        var challengeData = snapshot.data!.data() as Map<String, dynamic>;
                        List<dynamic> challengeListTitles =
                            challengeData['challengeListTitles'] ?? [];
                        Map<String, dynamic> challengeListCompleted =
                            challengeData['challengeListCompleted'] ?? {};

                        // Total number of challenges
                        int totalChallenges = challengeListTitles.length;

                        // Count approved challenges for the current user
                        int approvedChallenges = challengeListCompleted.entries
                            .where((entry) =>
                        entry.value['player'] == userName &&
                            entry.value['status'] == 'approved')
                            .length;

                        // Calculate progress (approved challenges / total challenges)
                        double progress = totalChallenges > 0
                            ? approvedChallenges / totalChallenges
                            : 0.0;

                        return Row(
                          children: [
                            CircularProgressIndicator(
                              value: progress, // Set the calculated progress value
                              strokeWidth: 6, // Thicker stroke width for the progress indicator
                              color: Colors.green, // Custom color for the progress indicator
                              backgroundColor: Colors.grey, // Background color for the progress indicator
                            ),
                            SizedBox(width: 8),
                            Text(
                              "$approvedChallenges/$totalChallenges", // Display progress status
                              style: GoogleFonts.montserrat(
                                textStyle: Theme.of(context).textTheme.subtitle1?.copyWith(
                                  color: Colors.blueGrey,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
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
                              challengeDetails?['selectedRoles'][friendName] ?? []);
                          bool isCoach = roles.contains('leader');
                          bool isPlayer = roles.contains('player');

                          // Determine if the progress should be displayed based on roles
                          bool showProgress = isPlayer || (!isCoach);

                          List<Widget> roleIcons = [];

                          if (isCoach && isPlayer) {
                            roleIcons.addAll([
                              Icon(Icons.verified_user, size: 14, color: Colors.orange),
                              Icon(Icons.sports_soccer, size: 14, color: Colors.green),
                            ]);
                          } else if (isCoach) {
                            roleIcons.add(
                              Icon(Icons.verified_user, size: 14, color: Colors.orange),
                            );
                          } else if (isPlayer) {
                            roleIcons.add(
                              Icon(Icons.sports_soccer, size: 14, color: Colors.green),
                            );
                          }

                          return FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('team_challenges')
                                .doc(id) // Use your specific challenge document ID
                                .get(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return CircularProgressIndicator();
                              }

                              var challengeData = snapshot.data!.data() as Map<String, dynamic>;
                              List<dynamic> challengeListTitles =
                                  challengeData['challengeListTitles'] ?? [];
                              Map<String, dynamic> challengeListCompleted =
                                  challengeData['challengeListCompleted'] ?? {};

                              // Total number of challenges
                              int totalChallenges = challengeListTitles.length;

                              // Count approved challenges for the current friend
                              int approvedChallenges = challengeListCompleted.entries
                                  .where((entry) =>
                              entry.value['player'] == friendName &&
                                  entry.value['status'] == 'approved')
                                  .length;

                              return Container(
                                margin: EdgeInsets.only(right: 16),
                                child: Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        if (approvedChallenges > 0) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => MemberStoryScreen(
                                                documentId: id, // Pass the document ID
                                                memberName: friendName, // Pass the member name
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          // Only show story icon if approvedChallenges > 0
                                          if (approvedChallenges > 0)
                                            CircleAvatar(
                                              radius: 28, // Radius for story icon
                                              backgroundColor:
                                              Colors.blueAccent.withOpacity(0.5), // Background color for the story icon
                                            ),
                                          // Member's CircleAvatar
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
                                          // Role icons if any
                                          Positioned(
                                            bottom: 0,
                                            right: 0,
                                            child: Row(
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
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    // Display fraction only if the user is a player or has no leader role
                                    if (showProgress)
                                      Text(
                                        '$approvedChallenges/$totalChallenges', // Progress text based on calculation
                                        style: TextStyle(fontSize: 12, color: Colors.black),
                                      ),
                                  ],
                                ),
                              );
                            },
                          );
                        } else {
                          // Plus button with placeholder fraction below
                          return Container(
                            margin: EdgeInsets.only(right: 16),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 25, // Smaller radius
                                  backgroundColor: Colors.grey.shade300, // Grey color for the button
                                  child: Icon(
                                    Icons.add,
                                    color: Colors.black,
                                    size: 18, // Adjust icon size as needed
                                  ),
                                ),
                                SizedBox(height: 4),
                                // Placeholder fraction for the plus button
                                Text(
                                  '', // Placeholder fraction
                                  style: TextStyle(fontSize: 12, color: Colors.black),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                  ),
                if ((isCoach && !isPlayer) || (isCoach && isPlayer)) ...[
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
                    child: (challengeListCompleted != null && challengeListCompleted!.isNotEmpty)
                        ? ListView.builder(
                      itemCount: challengeListCompleted!.entries.where((entry) {
                        final completedData = entry.value;
                        return (completedData['status'] != 'approved' &&
                            completedData['status'] != 'rejected' &&
                            completedData['player'] != userName);
                      }).length,
                      itemBuilder: (context, index) {
                        final filteredEntries = challengeListCompleted!.entries.where((entry) {
                          final completedData = entry.value;
                          return (completedData['status'] != 'approved' &&
                              completedData['status'] != 'rejected' &&
                              completedData['player'] != userName);
                        }).toList();

                        if (filteredEntries.isEmpty) {
                          return Center(
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
                          );
                        }

                        final item = filteredEntries[index].key;
                        final completedData = filteredEntries[index].value;

                        final imageUrl = completedData['imageUrl'] ?? '';

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChallengeDetailScreen(
                                  imageUrl: imageUrl,
                                  userName: completedData['player'],
                                  itemTitle: item,
                                  challengeId: id,
                                  currentUser: userName ?? 'Unknown User',
                                ),
                              ),
                            );
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
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (imageUrl.isNotEmpty)
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      image: DecorationImage(
                                        image: NetworkImage(imageUrl),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                SizedBox(width: 8),
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
                                        'Completed by: ${completedData['player']}',
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

                if ((!isCoach && isPlayer) || (isCoach && isPlayer)) ...[
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
                        color: Colors.black,
                        size: 24,
                      ),
                    ],
                  ),
                  if (!allZero) ...[
                    SizedBox(height: 8),
                    // Message indicating the order requirement
                    Text(
                      'Checklist must be completed in consecutive order!',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                  SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: challengeListTitles.length,
                      itemBuilder: (context, index) {
                        final itemTitle = challengeListTitles[index];
                        final baseItemTitle = itemTitle.split(' ').takeWhile((part) => !RegExp(r'\d').hasMatch(part)).join(' ');

                        // Initialize verificationIcon with a default value
                        Icon verificationIcon = Icon(
                          Icons.check_circle,
                          color: Colors.grey,
                        );

                        // Initialize other variables
                        bool isCompleted = false;
                        Color verifiedUserColor = Colors.grey; // Default color
                        Color titleColor = Colors.black; // Default title color

                        // Check all items in challengeListCompleted
                        challengeListCompleted?.forEach((key, completedData) {
                          // Compare the base item title without unique identifiers
                          if (key.startsWith(baseItemTitle)) {
                            if (completedData['player'] == userName && completedData['status'] == '') {
                              isCompleted = false;
                              verificationIcon = Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              );
                              verifiedUserColor = Colors.grey; // Default if it's the user's item
                            } else if (completedData['player'] == userName && completedData['status'] == 'approved') {
                              isCompleted = true;
                              verificationIcon = Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              );
                              verifiedUserColor = Colors.green; // Change to green if approved
                              titleColor = Colors.green; // Change title color to green
                            } else if (completedData['player'] == userName && completedData['status'] == 'rejected') {
                              isCompleted = false;
                              verificationIcon = Icon(
                                Icons.cancel,
                                color: Colors.red,
                              );
                              verifiedUserColor = Colors.red; // Change to red if rejected
                              titleColor = Colors.red;
                            }
                          }
                        });

                        // Get expiration duration for the current checklist item
                        final expirationDuration = index < expirationDurations.length ? expirationDurations[index] : 0;

                        // Calculate cumulative expiration duration for the current item
                        int cumulativeExpirationDuration = 0;
                        for (int i = 0; i <= index; i++) {
                          cumulativeExpirationDuration += (i < expirationDurations.length) ? expirationDurations[i] : 0;
                        }

                        // Calculate expiration time for the current item
                        DateTime creationDate = (challengeDetails?['creationDate'] as Timestamp).toDate(); // Fetch from challengeDetails
                        DateTime expirationTime = creationDate.add(Duration(minutes: cumulativeExpirationDuration));

                        // Calculate remaining time
                        Duration remainingTime = expirationTime.difference(DateTime.now().toUtc());
                        double progressValue = (cumulativeExpirationDuration * 60 - remainingTime.inSeconds) / (cumulativeExpirationDuration * 60);
                        progressValue = progressValue.clamp(0.0, 1.0); // Ensure progress value is between 0 and 1

                        // Determine if the current item can be interacted with (remaining time must be greater than zero)
                        bool canInteract = allZero || remainingTime > Duration.zero;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    if (canInteract) { // Only allow interaction if time remains
                                      if (selectedVerification == 'photo' &&
                                          (verifiedUserColor == Colors.red || verifiedUserColor == Colors.grey)) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => VerifyCameraScreen(
                                              currentUser: userName ?? 'Unknown User',
                                              checklistItemTitle: itemTitle,
                                              itemTitle: itemTitle,
                                              challengeId: id,
                                            ),
                                          ),
                                        );
                                      } else {
                                        print('Selected Verification: $selectedVerification');
                                      }
                                    } else {
                                      print('Cannot interact, time has expired or item is not active yet.');
                                    }
                                  },
                                  child: Checkbox(
                                    value: isCompleted,
                                    onChanged: null, // Disable the checkbox interaction
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  itemTitle,
                                  style: TextStyle(color: titleColor), // Change text color based on status
                                ),
                                Spacer(),
                                Row(
                                  children: [
                                    verificationIcon,
                                    SizedBox(width: 8),
                                    Icon(Icons.verified_user, color: verifiedUserColor),
                                  ],
                                ),
                                // Display expiration duration if not all are zero
                                if (!allZero) ...[
                                  SizedBox(width: 8),
                                  Text(
                                    expirationDuration > 0 ? '$expirationDuration min' : '',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ],
                            ),
                            SizedBox(height: 4), // Space between checkbox and progress bar
                            // Only show progress bar if not all expiration durations are zero
                            if (!allZero)
                              LinearProgressIndicator(
                                value: progressValue, // Use calculated progress value
                                backgroundColor: Colors.grey[300],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  remainingTime <= Duration.zero ? Colors.grey : Colors.blue,
                                ), // Change color based on remaining time
                              ),
                            SizedBox(height: 8), // Space below the progress bar
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ],
       )
      )
      )
    );
  }
}