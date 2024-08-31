import 'dart:async'; // Import for Timer
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts
import 'package:snapchat_ui_clone/widgets/top_bar.dart';
import 'challenge_do.dart';
import 'challenge_someone.dart'; // Import ChallengeInputScreen

class TeamScreen extends StatefulWidget {
  const TeamScreen({Key? key}) : super(key: key);

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> with SingleTickerProviderStateMixin {
  late User? currentUser;
  late TabController _tabController;

  final Map<String, String> _dimensionImages = {
    'emotional': 'assets/images/bitmojis/Emotional.png',
    'environmental': 'assets/images/bitmojis/Environmental.png',
    'financial': 'assets/images/bitmojis/Financial.png',
    'intellectual': 'assets/images/bitmojis/Intellectual.png',
    'occupational': 'assets/images/bitmojis/Occupational.png',
    'physical': 'assets/images/bitmojis/Physical.png',
    'social': 'assets/images/bitmojis/Social.png',
    'spiritual': 'assets/images/bitmojis/Spiritual.png',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCurrentUser();
  }

  @override
  void dispose() {
    _tabController.dispose(); // Dispose the TabController to free up resources
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    try {
      currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        // Use setState to trigger rebuild and display current user
        setState(() {});
      } else {
        print('Current user is null');
      }
    } catch (e) {
      print('Error loading user document: $e');
    }
  }

  Future<Map<String, List<Map<String, dynamic>>>> _fetchChallenges() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('team_challenges')
          .get();

      DateTime now = DateTime.now();
      List<Map<String, dynamic>> activeChallenges = [];
      List<Map<String, dynamic>> previousChallenges = [];
      List<Map<String, dynamic>> discoveryChallenges = [];

      String? userEmail = currentUser?.email;
      String? userLocalPart = userEmail?.split('@').first; // Extract local part before @

      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> challengeData = {
          'id': doc.id, // Include the document ID
          'title': doc['challengeHeader'] as String,
          'dimension': doc['dimension'] as String,
          'description': doc['challengeDescription'] as String, // Add this line
        };
        Timestamp? completionDateTimestamp = doc['completionDate'] as Timestamp?;
        List<dynamic> challengeFriends = doc['challengeFriends'] as List<dynamic>;

        bool isCurrentUserInChallenge = challengeFriends.contains(userLocalPart);

        if (completionDateTimestamp == null) {
          // No completion date, check if user is in challengeFriends
          if (isCurrentUserInChallenge) {
            activeChallenges.add(challengeData);
          } else {
            discoveryChallenges.add(challengeData);
          }
        } else {
          DateTime completionDate = completionDateTimestamp.toDate();
          if (completionDate.isBefore(now)) {
            // Completion date is in the past, check if user is in challengeFriends
            if (isCurrentUserInChallenge) {
              previousChallenges.add(challengeData);
            } else {
              discoveryChallenges.add(challengeData);
            }
          } else {
            // Future completion dates are ignored in this logic
            if (isCurrentUserInChallenge) {
              activeChallenges.add(challengeData);
            } else {
              discoveryChallenges.add(challengeData);
            }
          }
        }
      }

      return {
        'active': activeChallenges,
        'previous': previousChallenges,
        'discovery': discoveryChallenges,
      };
    } catch (e) {
      print('Error fetching challenges: $e');
      return {'active': [], 'previous': [], 'discovery': []};
    }
  }

  String _getImagePathForDimension(String dimension) {
    return _dimensionImages[dimension.toLowerCase()] ?? 'assets/images/bitmojis/Default.png';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Stack(
          children: [
            const TopBar(isCameraPage: false, text: 'Teams'),
            Positioned(
              top: 100,
              left: 0,
              right: 0,
              bottom: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TabBar(
                    controller: _tabController,
                    tabs: [
                      Tab(text: 'Challenges'),
                      Tab(text: 'Teams'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Challenges Tab
                        FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
                          future: _fetchChallenges(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Center(child: Text('Error: ${snapshot.error}'));
                            } else if (!snapshot.hasData) {
                              return Center(child: Text('No challenges available'));
                            } else {
                              var challenges = snapshot.data!;
                              return SingleChildScrollView(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildSection('Active', challenges['active']!),
                                      SizedBox(height: 16),
                                      _buildSection('Previous', challenges['previous']!),
                                      SizedBox(height: 16),
                                      _buildSection('Discovery', challenges['discovery']!),
                                    ],
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                        // Teams Tab
                        Center(
                          child: currentUser == null
                              ? Text('Loading...')
                              : Text('Current User Email: ${currentUser!.email?.split('@').first}'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChallengeInputScreen(),
            ),
          );
        },
        child: Icon(Icons.add),
        tooltip: 'Create Challenge',
      ),
    );
  }

  Widget _buildSection(String title, List<Map<String, dynamic>> challenges) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.montserrat(
            textStyle: Theme.of(context).textTheme.headline6?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        SizedBox(height: 8),
        SizedBox(
          height: 220, // Adjust the height as needed
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: challenges.length,
            itemBuilder: (context, index) {
              String imagePath = _getImagePathForDimension(challenges[index]['dimension'] as String);
              double progress = 0.5; // Placeholder progress value
              String progressText = '${(progress * 100).toInt()}%';

              return GestureDetector(
                onTap: () {
                  if (title == 'Active') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DoChallenge(
                          challenge: challenges[index], // Pass the challenge data if needed
                        ),
                      ),
                    );
                  }
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  elevation: 16, // Increase the elevation to make the shadow more prominent
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16), // Rounded corners
                  ),
                  child: Stack(
                    children: [
                      Container(
                        width: 140, // Adjust the width as needed
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset(
                              imagePath,
                              height: 50, // Adjust the size as needed
                              width: 50,
                              fit: BoxFit.cover,
                            ),
                            SizedBox(height: 8),
                            Text(
                              challenges[index]['title'] as String,
                              style: GoogleFonts.montserrat(
                                textStyle: Theme.of(context).textTheme.bodyText1?.copyWith(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14, // Adjust the font size if needed
                                ),
                              ),
                            ),
                            if (title != 'Active') ...[
                              SizedBox(height: 8),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    challenges[index]['description'] as String,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.montserrat(
                                      textStyle: Theme.of(context).textTheme.bodyText2?.copyWith(
                                        color: Colors.black54,
                                        fontSize: 12, // Adjust the font size if needed
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            if (title == 'Active') ...[
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: LinearProgressIndicator(
                                      value: progress,
                                      backgroundColor: Colors.grey[300],
                                      color: Colors.blue,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    progressText,
                                    style: GoogleFonts.montserrat(
                                      textStyle: Theme.of(context).textTheme.bodyText1?.copyWith(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12, // Adjust the font size if needed
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            Spacer(), // Pushes content to the top and bottom space
                          ],
                        ),
                      ),
                      // Add comment icon button only for Active challenges
                      if (title == 'Active')
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: IconButton(
                            icon: Icon(Icons.comment, color: Colors.blue),
                            onPressed: () {
                              // Add your onPressed logic here
                            },
                          ),
                        ),
                      // Add repeat icon button only for Previous challenges
                      if (title == 'Previous')
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: IconButton(
                            icon: Icon(Icons.repeat, color: Colors.blue),
                            onPressed: () {
                              // Add your onPressed logic here
                            },
                          ),
                        ),
                      // Add plus icon button only for Discovery challenges
                      if (title == 'Discovery')
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: IconButton(
                            icon: Icon(Icons.add, color: Colors.blue),
                            onPressed: () {
                              // Add your onPressed logic here
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}