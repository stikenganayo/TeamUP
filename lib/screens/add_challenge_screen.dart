import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapchat_ui_clone/screens/prebuilt_activity_template_screen.dart';

class CreateChallenge extends StatefulWidget {
  const CreateChallenge({Key? key}) : super(key: key);

  @override
  _CreateChallengeState createState() => _CreateChallengeState();
}

class _CreateChallengeState extends State<CreateChallenge> {
  List<ChallengeData> challengeDataList = [
    ChallengeData(challengeTitle: "", controller: TextEditingController())
  ];

  String selectedFrequency = "Once"; // Default value
  List<String> frequencyOptions = [
    "Once",
    "every 1 day",
    "every 2 days",
    "every 3 days",
    "every 4 days",
    "every 5 days",
    "every week",
    "every 2 weeks",
    // Add more options as needed
  ];

  bool areFieldsFilled() {
    return challengeDataList.isNotEmpty &&
        challengeDataList.every((data) => data.challengeTitle.isNotEmpty);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create Challenges'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Customize Challenge'),
              Tab(text: 'Select Challenge Template'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // First tab - Customize Activity
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    Column(
                      children: challengeDataList
                          .map((data) => _buildChallengeRow(data))
                          .toList(),
                    ),
                    const SizedBox(height: 20),
                    _buildFrequencySection(),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: areFieldsFilled() ? () => postChallenge(context) : null,
                      child: Text('Post Challenge'),
                    ),
                  ],
                ),
              ),
            ),
            // Second tab - Placeholder content
            const PrebuiltActivityTemplateScreen(),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengeRow(ChallengeData data) {
    int index = challengeDataList.indexOf(data);
    bool hasMultipleItems = challengeDataList.length > 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (index == 0 && hasMultipleItems)
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: TextFormField(
              style: TextStyle(fontSize: 16),
              onChanged: (value) {},
              decoration: InputDecoration(
                hintText: 'Challenge Title',
              ),
            ),
          ),
        Row(
          children: [
            const Icon(Icons.check_box_outline_blank),
            const SizedBox(width: 10),
            Flexible(
              child: TextFormField(
                onChanged: (value) {
                  data.challengeTitle = value;
                  setState(() {});
                },
                decoration: const InputDecoration(
                  hintText: 'Challenge',
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                controller: data.controller,
              ),
            ),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                setState(() {
                  challengeDataList.add(
                    ChallengeData(challengeTitle: "", controller: TextEditingController()),
                  );
                });
              },
            ),
            if (hasMultipleItems)
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    if (index >= 0) {
                      challengeDataList.removeAt(index);
                    }
                  });
                },
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildFrequencySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Set Frequency',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          alignment: Alignment.centerLeft,
          child: DropdownButton<String>(
            value: selectedFrequency,
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  selectedFrequency = newValue;
                });
              }
            },
            items: frequencyOptions.map<DropdownMenuItem<String>>(
                  (String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              },
            ).toList(),
            hint: Text('Select Frequency'),
          ),
        ),
      ],
    );
  }

  void postChallenge(BuildContext context) {
    // Implement your logic to post the challenge here
    print('Challenges Posted: ${challengeDataList.map((data) => data.challengeTitle).toList()}');
    print('Selected Frequency: $selectedFrequency');
  }
}

class ChallengeData {
  String challengeTitle;
  TextEditingController controller;

  ChallengeData({required this.challengeTitle, required this.controller});
}
