import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:snapchat_ui_clone/widgets/top_bar.dart';
import 'dart:io';
import 'package:intl/intl.dart'; // Import intl package for date formatting
import '../style.dart';
import '../widgets/discover_grid.dart';
import '../widgets/team_stories.dart';
import '../widgets/subscriptions.dart';
import 'events_filter_page.dart'; // Import your EventsFilter screen
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

class EngagementsScreen extends StatefulWidget {
  const EngagementsScreen({Key? key}) : super(key: key);

  @override
  State<EngagementsScreen> createState() => _EngagementsScreenState();
}

class _EngagementsScreenState extends State<EngagementsScreen> {
  List<Map<String, dynamic>> communityEvents = [];
  List<Map<String, dynamic>> communityChallenges = [];
  List<Map<String, dynamic>> communityCoaches = [];
  late User? currentUser;

  @override
  void initState() {
    super.initState();
    _loadCommunityChallenges();
  }

  Future<String?> _loadCurrentUserName() async {
    currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      print('Current User Email: ${currentUser!.email}');

      try {
        QuerySnapshot userQuerySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: currentUser!.email)
            .limit(1)
            .get();

        if (userQuerySnapshot.docs.isNotEmpty) {
          DocumentSnapshot userSnapshot = userQuerySnapshot.docs.first;
          Map<String, dynamic> userData =
          userSnapshot.data() as Map<String, dynamic>;

          print('User Data: $userData');

          if (userData.containsKey('name')) {
            String userName = userData['name'] as String;
            return userName;
          } else {
            print('Name field not found in user document');
          }
        } else {
          print('User document not found for the current user');
        }
      } catch (e) {
        print('Error loading user document: $e');
      }
    }
    return null;
  }

  Future<void> _loadCommunityChallenges() async {
    try {
      QuerySnapshot communityChallengesSnapshot = await FirebaseFirestore
          .instance
          .collection('challenges')
          .get();

      List<Map<String, dynamic>> challenges = [];

      for (DocumentSnapshot doc in communityChallengesSnapshot.docs) {
        if (doc.exists) {
          List<Map<String, dynamic>> challengeDataList = [];
          if (doc['challengeDataList'] != null) {
            var data = doc['challengeDataList'][0];
            challengeDataList.add({
              'challengeTitle': data['challengeTitle'] ?? '',
            });
          }

          Map<String, dynamic> challengeDetails = {
            'challengeId': doc.id,
            'challengeDataList': challengeDataList,
            'CurrentUserName': doc['CurrentUserName'] ?? '',
            'accepted': doc['accepted'] ?? 0,
            'isGoing': false,
          };
          challenges.add(challengeDetails);
        }
      }

      setState(() {
        communityChallenges = challenges;
      });
    } catch (e) {
      print('Error loading community challenges: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Style.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          const TopBar(isCameraPage: false, text: 'Community'),
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height -
                100 -
                (Platform.isIOS ? 90 : 60),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Style.sectionTitle('Community Stories   '),
                    ],
                  ),
                  const Stories(),
                  const SizedBox(height: 28),
                  Style.sectionTitle('Challenges To Try'),
                  const SizedBox(height: 28),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: communityChallenges.map((challenge) =>
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.4,
                            height: 300,
                            child: Card(
                              child: Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: double.infinity,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: challenge['challengeDataList']
                                                  .map<Widget>((challengeData) {
                                                return Text(challengeData['challengeTitle']);
                                              }).toList(),
                                            ),
                                          ),
                                          Text('Host: ${challenge['CurrentUserName']}'),
                                          Text('Accepted: ${challenge['accepted']}'),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ).toList(),
                    ),
                  ),
                  const SizedBox(height: 28),
                  const SizedBox(height: 28),
                  SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
