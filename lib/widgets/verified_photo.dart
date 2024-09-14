import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChallengeDetailScreen extends StatelessWidget {
  final String imageUrl;
  final String userName;
  final String itemTitle;
  final String challengeId;
  final String currentUser;

  ChallengeDetailScreen({
    required this.imageUrl,
    required this.userName,
    required this.itemTitle,
    required this.challengeId,
    required this.currentUser,
  }) {
    // Debugging: Print challengeId to check its value
    print('Challenge ID: $challengeId');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              itemTitle,
              style: Theme.of(context).textTheme.headline6?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Completed by: $userName',
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          // Display the image
          imageUrl.isNotEmpty
              ? Center(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          )
              : Center(
            child: Text('No Image Available'),
          ),
          // Buttons at the bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Handle reject action
                        _showFeedbackDialog(context, false); // Pass false for reject
                      },
                      icon: Icon(Icons.close, color: Colors.white),
                      label: Text(
                        'Reject',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red, // Red color for reject
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        textStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Handle approve action
                        _updateChallengeStatus(context, true); // Pass true for approve
                      },
                      icon: Icon(Icons.check, color: Colors.white),
                      label: Text(
                        'Approve',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green, // Green color for approve
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        textStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog(BuildContext context, bool isApproved) {
    final TextEditingController feedbackController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Leave feedback for $userName'),
          content: TextField(
            controller: feedbackController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Enter your feedback here...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _updateChallengeStatus(context, isApproved, feedback: feedbackController.text);
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateChallengeStatus(BuildContext context, bool isApproved, {String? feedback}) async {
    // Debugging: Check if challengeId is empty
    if (challengeId.isEmpty) {
      print("Error: challengeId is empty");
      return;
    }

    try {
      // Reference to Firestore document
      final docRef = FirebaseFirestore.instance.collection('team_challenges').doc(challengeId);

      // Check if the 'challengeListCompleted' map exists
      final docSnapshot = await docRef.get();
      final existingData = docSnapshot.data() as Map<String, dynamic>?;

      // Initialize the map if it doesn't exist
      final challengeListCompleted = existingData?['challengeListCompleted'] as Map<String, dynamic>? ?? {};

      // Construct the status string with roles
      final status = isApproved ? 'approved' : 'rejected: $feedback';
      final roleInfo = 'leader = $currentUser, player = $userName';

      // Update the map with the new entry
      final newEntry = '$status ($roleInfo)';

      // Add or update the item in the map without removing existing entries
      challengeListCompleted[itemTitle] = newEntry;

      await docRef.update({
        'challengeListCompleted': challengeListCompleted,
      });

      // Close the screen and any dialogs
      Navigator.of(context).pop(); // Close the dialog if it is still open
      Navigator.of(context).pop(); // Close the current screen

    } catch (e) {
      print("Error updating challenge status: $e");
    }
  }
}