import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapchat_ui_clone/screens/team_select.dart';
import 'package:snapchat_ui_clone/widgets/top_bar.dart';
import 'dart:io';
import '../style.dart';
import '../widgets/stories.dart';
import '../widgets/subscriptions.dart';
import 'add_challenge_screen.dart';
import 'add_event_screen.dart';
import 'calendar_screen.dart';
import 'events_filter_page.dart';

class EngagementsScreen extends StatefulWidget {
  const EngagementsScreen({Key? key}) : super(key: key);

  @override
  State<EngagementsScreen> createState() => _EngagementsScreenState();
}

class _EngagementsScreenState extends State<EngagementsScreen> {
  late User? currentUser;
  List<Map<String, dynamic>> challengeDetails = [];

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        print('Current User Email: ${currentUser!.email}');

        QuerySnapshot userQuerySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: currentUser!.email)
            .limit(1)
            .get();

        if (userQuerySnapshot.docs.isNotEmpty) {
          DocumentSnapshot userSnapshot = userQuerySnapshot.docs.first;
          await _addChallengeDetailsFromUser(userSnapshot);
        } else {
          print('User document not found for the current user');
        }
      }
    } catch (e) {
      print('Error loading user document: $e');
    }
  }

  Future<void> _addChallengeDetailsFromUser(DocumentSnapshot userSnapshot) async {
    List<dynamic> teamChallenges = userSnapshot['team_challenges'];

    for (Map<String, dynamic> challenge in teamChallenges) {
      await _addChallengeDetails(challenge);
    }

    setState(() {});
  }

  Future<void> _addChallengeDetails(Map<String, dynamic> challenge) async {
    String challengeDocRef = challenge['challengeDocRef'];

    DocumentSnapshot challengeSnapshot = await FirebaseFirestore.instance
        .collection('challenge_templates')
        .doc(challengeDocRef)
        .get();

    if (challengeSnapshot.exists) {
      Map<String, dynamic> challengeData =
      challengeSnapshot.data() as Map<String, dynamic>;

      print('Challenge Title: ${challengeData['template_name']}');
      print('Description: ${challengeData['frequency']}');
      print('Status: ${challenge['status']}');

      challengeDetails.add({
        'title': challengeData['template_name'],
        'Description': challengeData['frequency'],
        'status': challenge['status'] ?? '',
        'challengeDocRef': challengeDocRef,
      });
    } else {
      print('Challenge document not found for challengeDocRef: $challengeDocRef');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            // Top bar
            const TopBar(isCameraPage: false, text: 'Engagements'),
            Positioned(
              top: 100,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height - 100 - (Platform.isIOS ? 90 : 60),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stories
                    Style.sectionTitle('Team Stories'),
                    const Stories(),
                    const SizedBox(height: 18),
                    // Select A Challenge
                    Style.sectionTitle('Challenges'),
                    const SizedBox(height: 18),
                    // Display Challenges
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: challengeDetails.length,
                      itemBuilder: (context, index) {
                        return Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                          ),
                          child: ListTile(
                            title: Text('Title: ${challengeDetails[index]['title']}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Description: ${challengeDetails[index]['Description']}'),
                                SizedBox(height: 8),
                                Text(
                                  'Status: ${challengeDetails[index]['status']}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
