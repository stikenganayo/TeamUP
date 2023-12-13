import 'package:flutter/material.dart';
import 'package:snapchat_ui_clone/screens/prebuilt_activity_template_screen.dart';
import 'package:snapchat_ui_clone/screens/selection_screen.dart';

class CreateChallenge extends StatefulWidget {
  const CreateChallenge({Key? key}) : super(key: key);

  @override
  _CreateChallengeState createState() => _CreateChallengeState();
}

class _CreateChallengeState extends State<CreateChallenge> {
  List<ChallengeData> challengeDataList = [
    ChallengeData(challengeTitle: "", controller: TextEditingController())
  ];
  List<String> selectedFriends = [];
  List<String> selectedTeams = [];

  bool showFrequencyDropdowns = false;
  int selectedNumber = 1;
  String selectedTimeUnit = "Day";
  String selectedChallengeType = "CheckBox"; // Default value for challenge type dropdown
  List<String> timeUnitOptions = [
    "Second",
    "Minute",
    "Hour",
    "Day",
    "Week",
    "Month",
    "Year",
    "Meter",
    "Kilometer",
    "Gram",
    "Kilogram",
    "Liter",
    "Milliliter",
    "Celsius",
    "Fahrenheit",
    "Piece",
  ];

  late List<InputFieldData> inputFieldsDataList; // Initialize as late

  bool areFieldsFilled() {
    return challengeDataList.isNotEmpty &&
        challengeDataList.every((data) => data.challengeTitle.isNotEmpty);
  }

  @override
  void initState() {
    super.initState();
    inputFieldsDataList = List.generate(
      selectedNumber,
          (index) => InputFieldData(),
    );
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
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          showFrequencyDropdowns = !showFrequencyDropdowns;
                        });
                      },
                      child: Text(
                          showFrequencyDropdowns ? 'Remove Frequency' : 'Set Frequency?'),
                    ),
                    if (showFrequencyDropdowns) const SizedBox(height: 10),
                    if (showFrequencyDropdowns) _buildFrequencySection(),
                    const SizedBox(height: 20),

                    Column(
                      children: [
                        const Text(
                          'Tracking',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),
                        DropdownButton<String>(
                          value: selectedChallengeType,
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                selectedChallengeType = newValue;
                                if (newValue == "CheckBox") {
                                  // Reset tracking-related fields when CheckBox is selected
                                  selectedNumber = 1;
                                  selectedTimeUnit = "Day";
                                  inputFieldsDataList = [InputFieldData()];
                                } else {
                                  inputFieldsDataList = List.generate(
                                    selectedNumber,
                                        (index) => InputFieldData(),
                                  );
                                }
                              });
                            }
                          },
                          items: ["CheckBox", "1", "2", "3"]
                              .map<DropdownMenuItem<String>>(
                                (String value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            ),
                          )
                              .toList(),
                          hint: Text('Select Number'),
                        ),
                        if (selectedChallengeType != "CheckBox")
                          Column(
                            children: [
                              const SizedBox(height: 10), // Spacer
                              for (int index = 0; index < int.parse(selectedChallengeType); index++)
                                Row(
                                  children: [
                                    Flexible(
                                      child: TextFormField(
                                        onChanged: (value) {
                                          setState(() {
                                            if (value.isNotEmpty) {
                                              inputFieldsDataList[index].numberOfFields = int.parse(value);
                                            }
                                          });
                                        },
                                        decoration: InputDecoration(
                                          hintText: 'Input Field Name Here',
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Flexible(
                                      child: DropdownButton<String>(
                                        value: inputFieldsDataList[index].unit,
                                        onChanged: (String? newValue) {
                                          if (newValue != null) {
                                            setState(() {
                                              inputFieldsDataList[index].unit = newValue;
                                            });
                                          }
                                        },
                                        items: timeUnitOptions
                                            .map<DropdownMenuItem<String>>(
                                              (String value) => DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          ),
                                        )
                                            .toList(),
                                        hint: Text('Select Unit'),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                  ],
                                ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SelectionScreen(),
                          ),
                        ).then((result) {
                          if (result != null && result is Map<String, dynamic>) {
                            setState(() {
                              selectedFriends.clear();
                              if (result.containsKey('friends') && result['friends'] is List<String>) {
                                selectedFriends.addAll(result['friends']);
                              }

                              selectedTeams.clear();
                              if (result.containsKey('teams') && result['teams'] is List<String>) {
                                selectedTeams.addAll(result['teams']);
                              }
                            });
                          }
                        });
                      },
                      child: const Text('Challenge who?'),
                    ),
                    const SizedBox(height: 20),

                    if (selectedFriends.isNotEmpty || selectedTeams.isNotEmpty)
                      Column(
                        children: [
                          Text(
                            'Posting to:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Wrap(
                            alignment: WrapAlignment.center,
                            children: [
                              ...selectedFriends.map(
                                    (friendName) => Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Chip(
                                    label: Text(friendName),
                                    backgroundColor: Colors.grey,
                                  ),
                                ),
                              ),
                              ...selectedTeams.map(
                                    (teamName) => Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Chip(
                                    label: Text(teamName),
                                    backgroundColor: Colors.blue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: areFieldsFilled() ? () => postChallenge(context) : null,
                      child: const Text('Post Challenge'),
                    ),
                  ],
                ),
              ),
            ),
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
        Row(
          children: [
            Flexible(
              child: DropdownButton<int>(
                value: selectedNumber,
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedNumber = newValue;
                      inputFieldsDataList = List.generate(
                        selectedNumber,
                            (index) => InputFieldData(),
                      );
                    });
                  }
                },
                items: [1, 2, 3]
                    .map<DropdownMenuItem<int>>(
                      (int value) => DropdownMenuItem<int>(
                    value: value,
                    child: Text(value.toString()),
                  ),
                )
                    .toList(),
                hint: Text('Select Number'),
              ),
            ),
            const Text('/', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 10),

            Flexible(
              child: DropdownButton<String>(
                value: selectedTimeUnit,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedTimeUnit = newValue;
                    });
                  }
                },
                items: timeUnitOptions.map<DropdownMenuItem<String>>(
                      (String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  },
                ).toList(),
                hint: Text('Select Time Unit'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  void postChallenge(BuildContext context) {
    print('Challenges Posted: ${challengeDataList.map((data) => data.challengeTitle).toList()}');
    print('Selected Frequency: $selectedNumber $selectedTimeUnit');
    print('Selected Challenge Type: $selectedChallengeType');
    for (int i = 0; i < inputFieldsDataList.length; i++) {
      print('Input Field $i: ${inputFieldsDataList[i].numberOfFields} ${inputFieldsDataList[i].unit}');
    }
  }
}

class ChallengeData {
  String challengeTitle;
  TextEditingController controller;

  ChallengeData({required this.challengeTitle, required this.controller});
}

class InputFieldData {
  int numberOfFields = 1;
  String unit = "Second";
}
