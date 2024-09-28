import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:story_view/story_view.dart';

class MemberStoryScreen extends StatefulWidget {
  final String memberName;
  final String documentId;

  const MemberStoryScreen({
    Key? key,
    required this.memberName,
    required this.documentId,
  }) : super(key: key);

  @override
  _MemberStoryScreenState createState() => _MemberStoryScreenState();
}

class _MemberStoryScreenState extends State<MemberStoryScreen> {
  late Future<List<StoryItem>> _fetchStoryItems;
  final StoryController controller = StoryController();

  @override
  void initState() {
    super.initState();
    _fetchStoryItems = _getStoryItems();
  }

  Future<List<StoryItem>> _getStoryItems() async {
    List<StoryItem> storyItems = [];

    DocumentSnapshot challengeDoc = await FirebaseFirestore.instance
        .collection('team_challenges')
        .doc(widget.documentId)
        .get();

    Map<String, dynamic> challengeData =
    challengeDoc.data() as Map<String, dynamic>;

    Map<String, dynamic> challengeListCompleted =
    challengeData['challengeListCompleted'] as Map<String, dynamic>;

    challengeListCompleted.forEach((key, value) {
      if (value['player'] == widget.memberName &&
          value['status'] == 'approved') {
        // Add inline image story item with detailed caption
        storyItems.add(StoryItem.inlineImage(
          url: value['imageUrl'],
          controller: controller,
          caption: Text(
            "Player: ${value['player']}\n"
                "Challenge: ${key.replaceAll('_', ' ')}\n",
            style: TextStyle(
              color: Colors.white,
              backgroundColor: Colors.black54,
              fontSize: 17,
            ),
          ),
        ));
      }
    });

    return storyItems;
  }

  Color _generateRandomColor() {
    // Generate a random color (customize this function as needed)
    return Colors.primaries[DateTime.now().second % Colors.primaries.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<StoryItem>>(
        future: _fetchStoryItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text(snapshot.hasError ? 'Error: ${snapshot.error}' : 'No stories available.'));
          }

          List<StoryItem> storyItems = snapshot.data!;

          return StoryView(
            controller: controller,
            storyItems: storyItems,
            onStoryShow: (s, i) {
              print("Showing a story");
            },
            onComplete: () {
              print("Completed a cycle");
              Navigator.pop(context);  // Close the screen when the story is completed
            },
            progressPosition: ProgressPosition.bottom,
            repeat: false,
            inline: true,
          );
        },
      ),
    );
  }
}