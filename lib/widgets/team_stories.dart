import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:snapchat_ui_clone/widgets/story.dart';
import '../style.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

class Stories extends StatelessWidget {
  const Stories({Key? key}) : super(key: key);

  Future<List<String>> _loadUserTeamNames() async {
    try {
      // Fetch team IDs associated with the current user
      List<String> userTeamIds = await _getUserTeamIds();

      // Fetch team names corresponding to the team IDs
      List<String> teamNames = [];
      for (String teamId in userTeamIds) {
        String teamName = await _getTeamName(teamId);
        teamNames.add(teamName);
      }

      return teamNames;
    } catch (e) {
      // Handle error case
      print('Error loading user team names: $e');
      return [];
    }
  }

  Future<List<String>> _getUserTeamIds() async {
    try {
      // Fetch the user document based on the current user's email
      QuerySnapshot userQuerySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email)
          .limit(1)
          .get();

      if (userQuerySnapshot.docs.isNotEmpty) {
        DocumentSnapshot userSnapshot = userQuerySnapshot.docs.first;
        Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;

        // Check for team_ids in the user data
        if (userData.containsKey('team_ids')) {
          List<String> teamIds = List<String>.from(userData['team_ids']);
          return teamIds;
        } else {
          print('Team_ids field not found in user document');
          return [];
        }
      } else {
        print('User document not found for the current user');
        return [];
      }
    } catch (e) {
      // Handle error case
      print('Error loading user team IDs: $e');
      return [];
    }
  }

  Future<String> _getTeamName(String teamId) async {
    try {
      // Fetch the team document based on the team ID
      DocumentSnapshot teamSnapshot = await FirebaseFirestore.instance
          .collection('teams')
          .doc(teamId)
          .get();

      if (teamSnapshot.exists) {
        Map<String, dynamic> teamData = teamSnapshot.data() as Map<String, dynamic>;

        // Check for the 'team_name' field in the team data
        if (teamData.containsKey('team_name')) {
          String teamName = teamData['team_name'];
          return teamName;
        } else {
          print('Team name field not found in team document');
          return 'Unknown Team';
        }
      } else {
        print('Team document not found for $teamId');
        return 'Unknown Team';
      }
    } catch (e) {
      // Handle error case
      print('Error loading team document: $e');
      return 'Unknown Team';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _loadUserTeamNames(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Return a loading indicator while data is being fetched
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          // Handle error case
          return Text('Error: ${snapshot.error}');
        } else {
          // Generate widgets using the extracted team names
          List<String> teamNames = snapshot.data!;
          List<Widget> children = List.generate(
            teamNames.length,
                (index) => GestureDetector(
              onTap: () {
                // Navigate to the story screen when a story is clicked
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StoryScreen(teamName: teamNames[index])),
                );
              },
              child: Column(
                children: [
                  Story(index: index),
                  Style.friendName(teamNames[index]),
                ],
              ),
            ),
          );

          children.insert(0, const SizedBox(width: 10));
          children.add(const SizedBox(width: 10));

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            child: Row(
              children: children,
            ),
          );
        }
      },
    );
  }
}

class StoryScreen extends StatefulWidget {
  final String teamName;

  const StoryScreen({Key? key, required this.teamName}) : super(key: key);

  @override
  _StoryScreenState createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  int currentIndex = 0; // Index to track current image

  List<String> images = []; // List to store image URLs from Firestore

  @override
  void initState() {
    super.initState();
    // Fetch story images from Firestore when the widget is initialized
    _fetchStoryImages();
  }

  Future<void> _fetchStoryImages() async {
    try {
      // Fetch the team document based on the team name
      QuerySnapshot teamQuerySnapshot = await FirebaseFirestore.instance
          .collection('teams')
          .where('team_name', isEqualTo: widget.teamName)
          .limit(1)
          .get();

      if (teamQuerySnapshot.docs.isNotEmpty) {
        DocumentSnapshot teamSnapshot = teamQuerySnapshot.docs.first;
        Map<String, dynamic> teamData = teamSnapshot.data() as Map<String, dynamic>;

        // Check for the 'story' field in the team data
        if (teamData.containsKey('story')) {
          List<dynamic> story = teamData['story'];
          setState(() {
            // Convert dynamic list to List<String>
            images = story.cast<String>();
          });
        } else {
          print('Story images not found in team document');
        }
      } else {
        print('Team document not found for ${widget.teamName}');
      }
    } catch (e) {
      // Handle error case
      print('Error fetching story images: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Background color
      body: GestureDetector(
        onTap: () {
          setState(() {
            // Increment index to navigate to the next image
            currentIndex = (currentIndex + 1) % images.length;
          });
        },
        child: Stack(
          children: [
            // Image Background
            images.isNotEmpty
                ? Image.network(
              images[currentIndex],
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            )
                : SizedBox(), // Display nothing if images list is empty
            // Content Overlay
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 50), // Top padding
                    // Title
                    Text(
                      widget.teamName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20), // Spacer
                    // Story Content (You can replace this with your desired content)
                    Text(
                      'We gotta step it up team, 10 days to go!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Close Button
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}