import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({Key? key}) : super(key: key);

  // Placeholder data for friends and teams
  List<String> friends = ['Friend 1', 'Friend 2', 'Friend 3', 'Friend 4', ''];
  List<String> teams = ['Team A', 'Team B', 'Team C', 'Team D', ''];

  // Placeholder icons for friends and teams
  List<IconData> friendIcons = [Icons.person, Icons.face, Icons.child_care, Icons.pets, Icons.add];
  List<IconData> teamIcons = [Icons.group, Icons.sports_basketball, Icons.sports_soccer, Icons.emoji_events, Icons.add];

  // Placeholder colors for icons
  List<Color> friendIconColors = [Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.grey];
  List<Color> teamIconColors = [Colors.red, Colors.teal, Colors.yellow, Colors.deepOrange, Colors.grey];

  @override
  Widget build(BuildContext context) {
    // Placeholder data for the user profile
    String username = 'John Doe';
    int totalPoints = 1000;
    int totalStreaks = 5;
    String profilePictureUrl = 'https://csncollision.com/wp-content/uploads/2019/10/placeholder-circle.png';

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: Colors.red, // Set the app bar color to red
        actions: [
          IconButton(
            icon: const Icon(Icons.edit), // Add the edit icon
            onPressed: () {
              // Implement the edit functionality here
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(profilePictureUrl),
              backgroundColor: Colors.red, // Set the CircleAvatar color to red
            ),
            const SizedBox(height: 20),
            Text(
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
                          style: const TextStyle(fontSize: 16), // Set the font size for the names
                        ),
                      ],
                    ),
                  );
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
                          style: const TextStyle(fontSize: 16), // Set the font size for the names
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 30), // Increase the spacing between the teams section and the bottom
          ],
        ),
      ),
    );
  }
}