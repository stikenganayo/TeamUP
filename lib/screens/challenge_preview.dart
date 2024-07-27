import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:snapchat_ui_clone/screens/team_screen.dart';

import 'challenge_someone.dart';

class ReviewPostScreen extends StatelessWidget {
  final String challengeHeader;
  final String challengeDescription;
  final List<String> challengeListTitles;
  final List<String> challengeTeams;
  final List<String> challengeFriends;
  final DateTime completionDate;
  final List<Duration?> expirationDurations;
  final Map<String, Set<String>> selectedRoles;
  final String? selectedVerification;
  final String? customVerificationProcess;

  ReviewPostScreen({
    required this.challengeHeader,
    required this.challengeDescription,
    required this.challengeListTitles,
    required this.challengeTeams,
    required this.challengeFriends,
    required this.completionDate,
    required this.expirationDurations,
    required this.selectedRoles,
    required this.selectedVerification,
    this.customVerificationProcess,
  });

  Future<void> _postChallenge(BuildContext context) async {
    try {
      final challengeData = {
        'challengeHeader': challengeHeader,
        'challengeDescription': challengeDescription,
        'challengeListTitles': challengeListTitles,
        'challengeTeams': challengeTeams,
        'challengeFriends': challengeFriends,
        'completionDate': Timestamp.fromDate(completionDate),
        'expirationDurations': expirationDurations.map((e) => e?.inMinutes).toList(),
        'selectedRoles': selectedRoles,
        'selectedVerification': selectedVerification,
        'customVerificationProcess': customVerificationProcess,
      };

      // Add a new document to the collection
      await FirebaseFirestore.instance.collection('team_challenges').add(challengeData);

      // Pop back 3 screens (assuming you know the exact number)
      for (int i = 0; i < 4; i++) {
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error posting challenge: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Review & Confirm'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Details Section
              _buildInfoSection(
                icon: Icons.info,
                title: 'Details',
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailCard(
                      icon: Icons.title,
                      title: 'Title',
                      content: Text(
                        challengeHeader,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailCard(
                      icon: Icons.description,
                      title: 'Description',
                      content: Text(
                        challengeDescription,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Schedule Section
              _buildInfoSection(
                icon: Icons.calendar_today,
                title: 'Schedule',
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailCard(
                      icon: Icons.date_range,
                      title: 'Completion Date',
                      content: Text(
                        '${DateFormat('MMMM d, yyyy – h:mm a').format(completionDate)}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailCard(
                      icon: Icons.checklist,
                      title: 'Checklist',
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: challengeListTitles.asMap().entries.map((entry) {
                          final index = entry.key;
                          final title = entry.value;
                          final expirationDuration = expirationDurations[index];
                          return Text(
                            '• $title: ${expirationDuration != null ? _durationToString(expirationDuration) : 'No expiration'}',
                            style: TextStyle(fontSize: 16),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Roles and Verification Section
              _buildInfoSection(
                icon: Icons.group,
                title: 'Roles and Verification',
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoSection(
                      icon: Icons.person,
                      title: 'Assigned Roles',
                      content: _buildRolesContent(),
                      iconColor: Colors.grey, // Set the icon color to grey
                    ),
                    const SizedBox(height: 16),
                    _buildInfoSection(
                      icon: Icons.verified,
                      title: 'Verification Type',
                      content: Text(
                        selectedVerification == 'custom' && customVerificationProcess != null
                            ? '$selectedVerification: $customVerificationProcess'
                            : selectedVerification ?? 'None',
                        style: TextStyle(fontSize: 16),
                      ),
                      iconColor: Colors.grey, // Set the icon color to grey
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _postChallenge(context),
        child: Icon(Icons.check),
      ),
    );
  }

  Widget _buildInfoSection({required IconData icon, required String title, required Widget content, Color iconColor = Colors.blueAccent}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 24, color: iconColor), // Use the iconColor parameter
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard({required IconData icon, required String title, required Widget content}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 24, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildRolesContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: selectedRoles.entries.map((entry) {
        final friend = entry.key;
        final roles = entry.value;
        return Text(
          '• $friend: ${roles.join(' and ')}',
          style: TextStyle(fontSize: 16),
        );
      }).toList(),
    );
  }

  String _durationToString(Duration duration) {
    if (duration.inDays > 0) return '${duration.inDays} Day(s)';
    if (duration.inHours > 0) return '${duration.inHours} Hour(s)';
    if (duration.inMinutes > 0) return '${duration.inMinutes} Minute(s)';
    return '0 Minute(s)';
  }
}