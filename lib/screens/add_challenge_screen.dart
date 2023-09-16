import 'package:flutter/material.dart';
import 'package:snapchat_ui_clone/screens/team_select.dart';

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

  List<String> selectedTeams = []; // List to store selected teams

  bool areFieldsFilled() {
    return challengeDataList.isNotEmpty &&
        challengeDataList.every((data) => data.challengeTitle.isNotEmpty);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Activity Template!'),
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
              _buildTeamSelection(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: areFieldsFilled() ? () => postChallenge() : null,
                child: Text('Post Activity'),
              ),
              const SizedBox(height: 20),
              // Display selected teams below the button
              _buildSelectedTeamsList(),
            ],
          ),
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
        if (index == 0 && hasMultipleItems) // Display the title if index is 0 and there are multiple items
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0), // Add spacing below the title
            child: TextFormField(
              style: TextStyle(fontSize: 16),
              onChanged: (value) {
                // Handle changes to the title if needed
              },
              decoration: InputDecoration(
                hintText: 'Activity Title',
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
                  setState(() {}); // Rebuild the UI when a field changes
                },
                decoration: const InputDecoration(
                  hintText: 'Activity',
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
            if (hasMultipleItems) // Only display the close icon if there are multiple items
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

  Widget _buildTeamSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Team',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () async {
            final teams = await showDialog<List<String>>(
              context: context,
              builder: (BuildContext context) {
                return TeamSelect();
              },
            );
            if (teams != null) {
              setState(() {
                selectedTeams = teams;
              });
            }
          },
          child: Text('Select Team'),
        ),
      ],
    );
  }

  // Function to build the list of selected teams
  Widget _buildSelectedTeamsList() {
    return selectedTeams.isNotEmpty
        ? Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selected Teams:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          itemCount: selectedTeams.length,
          itemBuilder: (context, index) {
            return Text(selectedTeams[index]);
          },
        ),
      ],
    )
        : Container(); // Return an empty container if no teams are selected
  }

  void postChallenge() {
    // Implement your logic to post the challenge here
    print('Challenges Posted: ${challengeDataList.map((data) => data.challengeTitle).toList()}');
    print('Selected Frequency: $selectedFrequency');
    print('Selected Teams: $selectedTeams');
  }
}

class ChallengeData {
  String challengeTitle;
  TextEditingController controller;

  ChallengeData({required this.challengeTitle, required this.controller});
}
