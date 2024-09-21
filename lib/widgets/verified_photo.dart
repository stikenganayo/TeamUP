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
    print('Challenge ID: $challengeId');
    print('Item Title: $itemTitle');
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
                        _showFeedbackDialog(context, false);
                      },
                      icon: Icon(Icons.close, color: Colors.white),
                      label: Text(
                        'Reject',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
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
                        _updateChallengeStatus(context, true);
                      },
                      icon: Icon(Icons.check, color: Colors.white),
                      label: Text(
                        'Approve',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
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
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
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
    if (challengeId.isEmpty) {
      print("Error: challengeId is empty");
      return;
    }

    try {
      final docRef = FirebaseFirestore.instance.collection('team_challenges').doc(challengeId);
      final docSnapshot = await docRef.get();
      final existingData = docSnapshot.data() as Map<String, dynamic>?;

      final challengeListCompleted = existingData?['challengeListCompleted'] as Map<String, dynamic>? ?? {};

      // Check if the itemTitle exists in the map
      if (challengeListCompleted.containsKey(itemTitle)) {
        // Update fields without deleting existing data
        final currentEntry = challengeListCompleted[itemTitle] as Map<String, dynamic>;

        // Update leader field
        currentEntry['leader'] = currentUser;

        // Update feedback field only if feedback is provided
        if (feedback != null && feedback.isNotEmpty) {
          currentEntry['feedback'] = feedback;
        } else {
          currentEntry['feedback'] = ''; // Leave feedback empty if not provided
        }

        // Update status field
        currentEntry['status'] = isApproved ? 'approved' : 'rejected';

        // Update the entry in the map
        challengeListCompleted[itemTitle] = currentEntry;

        await docRef.update({
          'challengeListCompleted': challengeListCompleted,
        });

        // Close the screen
        Navigator.of(context).pop();
      } else {
        print("Error: Item title not found in challengeListCompleted");
      }
    } catch (e) {
      print("Error updating challenge status: $e");
    }
  }
}