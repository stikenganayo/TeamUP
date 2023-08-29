import 'package:flutter/material.dart';
import 'search_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Placeholder data for friends and teams
  List<String> friends = ['Friend 1', 'Friend 2', 'Friend 3', 'Friend 4', ''];
  List<String> teams = ['Team A', 'Team B', 'Team C', 'Team D', ''];

  // Placeholder icons for friends and teams
  List<IconData> friendIcons = [Icons.person, Icons.face, Icons.child_care, Icons.pets, Icons.add];
  List<IconData> teamIcons = [Icons.group, Icons.sports_basketball, Icons.sports_soccer, Icons.emoji_events, Icons.add];

  // Placeholder colors for icons
  List<Color> friendIconColors = [Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.grey];
  List<Color> teamIconColors = [Colors.red, Colors.teal, Colors.yellow, Colors.deepOrange, Colors.grey];

  // Placeholder data for the user profile
  String username = 'John Doe';
  int totalPoints = 1000;
  int totalStreaks = 5;
  String profilePictureUrl = 'https://csncollision.com/wp-content/uploads/2019/10/placeholder-circle.png';

  // Add a TextEditingController for the name editing field
  final TextEditingController _nameController = TextEditingController();

  // Add a flag to track whether the name is being edited
  bool _isEditingName = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.lightBlue,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              setState(() {
                _isEditingName = !_isEditingName; // Toggle the editing flag
                if (_isEditingName) {
                  _nameController.text = username; // Set initial value to the current username
                }
              });
            },
          ),
        ],
      ),
    body: SingleChildScrollView( // Wrap the content in a SingleChildScrollView
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(profilePictureUrl),
              backgroundColor: Colors.red,
            ),
            const SizedBox(height: 20),
            _isEditingName
              ? TextFormField(
                  controller: _nameController,
                  style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    hintText: 'Enter your name',
                    labelText: 'Name',
                    ),
                  )
                : Text(
                  ' $username',
                  style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
            const SizedBox(height: 10),
            Text(
              'Total Points: $totalPoints',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'Total Streaks: $totalStreaks',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 30), // Increase the spacing between the user info and friends section
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                ' Friends:',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: friends.length,
                itemBuilder: (context, index) {
                  // Check if the icon represents the "add" icon
                  if (friendIcons[index] == Icons.add) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SearchScreen()), // Navigate to the search screen
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: friendIconColors[index],
                              child: Icon(
                                friendIcons[index],
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              friends[index],
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: friendIconColors[index],
                            child: Icon(
                              friendIcons[index],
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            friends[index],
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 30), // Increase the spacing between the friends and teams section
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Teams:',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: teams.length,
                itemBuilder: (context, index) {
                  // Check if the icon represents the "add" icon
                  if (teamIcons[index] == Icons.add) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SearchScreen()), // Navigate to the search screen
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: teamIconColors[index],
                              child: Icon(
                                teamIcons[index],
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              teams[index],
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: teamIconColors[index],
                            child: Icon(
                              teamIcons[index],
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            teams[index],
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 30), // Increase the spacing between the teams section and the bottom
          ],
        ),
      ),
    ),
    );
  }
}