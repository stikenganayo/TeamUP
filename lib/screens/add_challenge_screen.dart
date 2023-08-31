import 'package:flutter/material.dart';

class CreateChallenge extends StatefulWidget {
  const CreateChallenge({Key? key}) : super(key: key);

  @override
  _CreateChallengeState createState() => _CreateChallengeState();
}

class _CreateChallengeState extends State<CreateChallenge> {
  List<ChallengeData> challengeDataList = [
    ChallengeData(challengeTitle: "", controller: TextEditingController())
  ];

  String selectedFrequency = "every day"; // Default value
  List<String> frequencyOptions = [
    "every day",
    "every 2 days",
    "every 3 days",
    "every 4 days",
    "every 5 days",
    "every 6 days",
    "every week",
    "every 2 weeks",
    // Add more options as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Challenge!'),
      ),
      body: SingleChildScrollView(
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
                onPressed: areFieldsFilled() ? () => postChallenge() : null,
                child: Text('Post Challenge'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChallengeRow(ChallengeData data) {
    return Row(
      children: [
        const Icon(Icons.check_box_outline_blank),
        const SizedBox(width: 10),
        Flexible(
          child: TextField(
            onChanged: (value) {
              data.challengeTitle = value;
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
              setState(() {
                selectedFrequency = newValue!;
              });
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

  bool areFieldsFilled() {
    return challengeDataList.isNotEmpty &&
        challengeDataList.every((data) => data.challengeTitle.isNotEmpty) &&
        selectedFrequency.isNotEmpty;
  }

  void postChallenge() {
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
