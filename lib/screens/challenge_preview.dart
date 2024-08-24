import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../dimensions.dart';

class ReviewPostScreen extends StatefulWidget {
  final String challengeHeader;
  final String challengeDescription;
  final List<String> challengeListTitles;
  final List<String> challengeTeams;
  final List<String> challengeFriends;
  final DateTime? completionDate;
  final List<Duration?> expirationDurations;
  final int recurrenceValue;
  final String recurrenceUnit;
  final Map<String, Set<String>> selectedRoles;
  final String? selectedVerification;
  final String? customVerificationProcess;

  ReviewPostScreen({
    required this.challengeHeader,
    required this.challengeDescription,
    required this.challengeListTitles,
    required this.challengeTeams,
    required this.challengeFriends,
    this.completionDate,
    required this.expirationDurations,
    required this.recurrenceValue,
    required this.recurrenceUnit,
    required this.selectedRoles,
    required this.selectedVerification,
    this.customVerificationProcess,
  });

  @override
  _ReviewPostScreenState createState() => _ReviewPostScreenState();
}

class _ReviewPostScreenState extends State<ReviewPostScreen> {
  String _selectedDimension = 'emotional'; // Default dimension
  bool _isEditingDimension = false; // Track editing state

  // Mapping dimensions to icons
  final Map<String, IconData> _dimensionIcons = {
    'emotional': Icons.heart_broken,
    'physical': Icons.fitness_center,
    'occupational': Icons.work,
    'social': Icons.groups,
    'spiritual': Icons.spa,
    'intellectual': Icons.lightbulb,
    'environmental': Icons.eco,
    'financial': Icons.attach_money,
  };

  @override
  void initState() {
    super.initState();
    _setDimension();
  }

  void _setDimension() {
    final challengeWords = widget.challengeHeader.toLowerCase().split(' ');

    final Map<String, List<String>> dimensions = {
      'emotional': emotionalWords,
      'physical': physicalWords,
      'occupational': occupationalWords,
      'social': socialWords,
      'spiritual': spiritualWords,
      'intellectual': intellectualWords,
      'environmental': environmentalWords,
      'financial': financialWords,
    };

    String bestMatch = 'emotional'; // Default to emotional if no match

    double highestMatchScore = 0;

    dimensions.forEach((dimension, words) {
      double matchScore = challengeWords
          .where((word) => words.contains(word))
          .length
          .toDouble();

      if (matchScore > highestMatchScore) {
        highestMatchScore = matchScore;
        bestMatch = dimension;
      }
    });

    setState(() {
      _selectedDimension = bestMatch;
    });
  }

  Future<void> _postChallenge(BuildContext context) async {
    try {
      final challengeData = {
        'challengeHeader': widget.challengeHeader,
        'challengeDescription': widget.challengeDescription,
        'challengeListTitles': widget.challengeListTitles,
        'challengeTeams': widget.challengeTeams,
        'challengeFriends': widget.challengeFriends,
        'completionDate': widget.completionDate != null && widget.completionDate != DateTime(0)
            ? Timestamp.fromDate(widget.completionDate!)
            : null, // Handle invalid completionDate
        'expirationDurations': widget.expirationDurations.map((e) => e?.inMinutes).toList(),
        'recurrenceValue': widget.recurrenceValue,
        'recurrenceUnit': widget.recurrenceUnit,
        'selectedRoles': widget.selectedRoles,
        'selectedVerification': widget.selectedVerification,
        'customVerificationProcess': widget.customVerificationProcess,
        'dimension': _selectedDimension, // Include dimension in the challenge data
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
                        widget.challengeHeader,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailCard(
                      icon: Icons.description,
                      title: 'Description',
                      content: Text(
                        widget.challengeDescription,
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
                        widget.completionDate != null && widget.completionDate != DateTime(0)
                            ? '${DateFormat('MMMM d, yyyy – h:mm a').format(widget.completionDate!)}'
                            : 'Repeat the challenge every ${widget.recurrenceValue} ${widget.recurrenceUnit}(s)',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailCard(
                      icon: Icons.checklist,
                      title: 'Checklist',
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: widget.challengeListTitles.asMap().entries.map((entry) {
                          final index = entry.key;
                          final title = entry.value;
                          final expirationDuration = widget.expirationDurations[index];
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
                        widget.selectedVerification == 'custom' && widget.customVerificationProcess != null
                            ? '${widget.selectedVerification}: ${widget.customVerificationProcess}'
                            : widget.selectedVerification ?? 'None',
                        style: TextStyle(fontSize: 16),
                      ),
                      iconColor: Colors.grey, // Set the icon color to grey
                    ),
                    const SizedBox(height: 16),

                    // Dimension Section - Embedded in Roles and Verification
                    // Dimension Section - Embedded in Roles and Verification
                    Stack(
                      children: [
                        _buildInfoSection(
                          icon: _dimensionIcons[_selectedDimension]!,
                          title: 'Dimension of Wellness',
                          content: _isEditingDimension
                              ? DropdownButton<String>(
                            value: _selectedDimension,
                            items: <String>[
                              'emotional',
                              'physical',
                              'occupational',
                              'social',
                              'spiritual',
                              'intellectual',
                              'environmental',
                              'financial'
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Row(
                                  children: [
                                    Icon(_dimensionIcons[value]),
                                    const SizedBox(width: 8),
                                    Text(value.capitalize()),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedDimension = newValue!;
                                _isEditingDimension = false;
                              });
                            },
                          )
                              : Text(
                            _selectedDimension.capitalize(),
                            style: TextStyle(fontSize: 16),
                          ),
                          iconColor: Colors.grey, // Set the icon color to grey
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: IconButton(
                            icon: Icon(Icons.edit, color: Colors.grey),
                            onPressed: () {
                              setState(() {
                                _isEditingDimension = !_isEditingDimension;
                              });
                            },
                          ),
                        ),
                      ],
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
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 24, color: iconColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard({required IconData icon, required String title, required Widget content}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(icon, size: 24, color: Colors.blueAccent),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  content,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRolesContent() {
    final rolesContent = widget.selectedRoles.entries.map((entry) {
      final friend = entry.key;
      final roles = entry.value;
      return Text(
        '$friend: ${roles.isEmpty ? 'None' : roles.join(' and ')}',
        style: TextStyle(fontSize: 16),
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rolesContent,
    );
  }

  String _durationToString(Duration duration) {
    final minutes = duration.inMinutes;
    final hours = duration.inHours;
    final days = duration.inDays;
    if (days > 0) return '$days day${days > 1 ? 's' : ''}';
    if (hours > 0) return '$hours hour${hours > 1 ? 's' : ''}';
    return '$minutes minute${minutes > 1 ? 's' : ''}';
  }
}

extension CapitalizeExtension on String {
  String capitalize() {
    if (this == null || this.isEmpty) return '';
    return '${this[0].toUpperCase()}${this.substring(1).toLowerCase()}';
  }
}