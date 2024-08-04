import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'challenge_details.dart';

class FrequencyScreen extends StatefulWidget {
  final String challengeHeader;
  final String challengeDescription;
  final List<String> challengeListTitles;
  final List<String> challengeTeams;
  final List<String> challengeFriends;

  FrequencyScreen({
    required this.challengeHeader,
    required this.challengeDescription,
    required this.challengeListTitles,
    required this.challengeTeams,
    required this.challengeFriends,
  });

  @override
  _FrequencyScreenState createState() => _FrequencyScreenState();
}

class _FrequencyScreenState extends State<FrequencyScreen> {
  List<String> timeUnitOptions = ['Hour', 'Day', 'Week', 'Month'];
  String selectedOrder = 'Any Order';
  List<String> orderedTitles = [];
  String selectedRecurrenceOption = 'DateTime';
  String recurrenceFrequency = 'Day';
  int recurrenceValue = 1;
  String selectedUnit = 'Day';

  final TextEditingController _numberController = TextEditingController();
  DateTime? selectedDateTime;
  Map<String, Duration?> expirationDurations = {}; // Map to hold expiration durations

  @override
  void initState() {
    super.initState();
    orderedTitles = List.from(widget.challengeListTitles);
  }

  Future<void> _selectDate() async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (selectedDate != null) {
      TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (selectedTime != null) {
        DateTime finalDateTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );
        setState(() {
          selectedDateTime = finalDateTime;
        });
      }
    }
  }

  Future<void> _selectRecurrence() async {
    final result = await showDialog<List<dynamic>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(''),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _numberController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Enter number of repetitions'),
                    onChanged: (value) {
                      setState(() {
                        recurrenceValue = int.tryParse(value) ?? 1;
                      });
                    },
                  ),
                  DropdownButton<String>(
                    value: selectedUnit,
                    onChanged: (newValue) {
                      setState(() {
                        selectedUnit = newValue!;
                      });
                    },
                    items: timeUnitOptions.map((unit) {
                      return DropdownMenuItem<String>(
                        value: unit,
                        child: Text(unit),
                      );
                    }).toList(),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, [recurrenceValue, selectedUnit]);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      setState(() {
        recurrenceValue = result[0];
        selectedUnit = result[1];
      });
    }
  }

  String durationToString(Duration duration) {
    if (duration.inDays > 0) return '${duration.inDays} Day';
    if (duration.inHours > 0) return '${duration.inHours} Hour';
    return '0 Hour';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Challenge Schedule'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Checklist Order',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose the order in which you want the checklist items to be completed. You can select "Any Order" if the sequence does not matter, or "Consecutive" to require items to be completed in the order listed.',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            RadioListTile<String>(
              title: Text('Any Order'),
              value: 'Any Order',
              groupValue: selectedOrder,
              onChanged: (value) {
                setState(() {
                  selectedOrder = value!;
                });
              },
            ),
            RadioListTile<String>(
              title: Text('Consecutive'),
              value: 'Consecutive',
              groupValue: selectedOrder,
              onChanged: (value) {
                setState(() {
                  selectedOrder = value!;
                });
              },
            ),
            if (selectedOrder == 'Consecutive') ...[
              const SizedBox(height: 10),
              ReorderableListView(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) newIndex--;
                    final item = orderedTitles.removeAt(oldIndex);
                    orderedTitles.insert(newIndex, item);
                  });
                },
                children: List.generate(orderedTitles.length, (index) {
                  final title = orderedTitles[index];
                  return ListTile(
                    key: ValueKey(title),
                    leading: Icon(Icons.drag_handle),
                    title: Text(title),
                    trailing: ElevatedButton(
                      onPressed: () => _selectExpirationDuration(title),
                      child: Icon(Icons.timer_outlined),
                    ),
                    subtitle: expirationDurations[title] != null
                        ? Text('Expires in: ${durationToString(expirationDurations[title]!)}(s)')
                        : null,
                  );
                }),
              ),
            ],
            const SizedBox(height: 16),
            const Text(
              'Choose Completion Option',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose the completion method for the challenge. You can either set a specific date and time to complete the challenge or set to repeat the challenge for a set duration.',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            RadioListTile<String>(
              title: Text('Set Deadline'),
              value: 'DateTime',
              groupValue: selectedRecurrenceOption,
              onChanged: (value) {
                setState(() {
                  selectedRecurrenceOption = value!;
                  selectedDateTime = null;
                });
              },
            ),
            RadioListTile<String>(
              title: Text('Set Repetition'),
              value: 'Recurrence',
              groupValue: selectedRecurrenceOption,
              onChanged: (value) {
                setState(() {
                  selectedRecurrenceOption = value!;
                  selectedDateTime = null;
                });
              },
            ),
            if (selectedRecurrenceOption == 'DateTime') ...[
              ElevatedButton(
                onPressed: _selectDate,
                child: Text(
                  selectedDateTime == null
                      ? 'Select Date and Time'
                      : DateFormat('MMMM d, yyyy – h:mm a').format(selectedDateTime!),
                ),
              ),
            ] else if (selectedRecurrenceOption == 'Recurrence') ...[
              ElevatedButton(
                onPressed: _selectRecurrence,
                child: Text(
                  recurrenceValue > 0
                      ? 'Repeat the challenge every $selectedUnit for $recurrenceValue ${selectedUnit}(s)'
                      : "",
                ),
              ),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (selectedRecurrenceOption == null) {
            _showErrorDialog('Please select a completion option before proceeding.');
          } else if (selectedRecurrenceOption == 'DateTime' && selectedDateTime == null) {
            _showErrorDialog('Please select a date and time before proceeding.');
          } else {
            List<Duration> durations = orderedTitles.map((title) => expirationDurations[title] ?? Duration.zero).toList();

            // Print all parameters to the console
            print('Challenge Header: ${widget.challengeHeader}');
            print('Challenge Description: ${widget.challengeDescription}');
            print('Challenge List Titles: ${orderedTitles}');
            print('Challenge Teams: ${widget.challengeTeams}');
            print('Challenge Friends: ${widget.challengeFriends}');
            print('Completion Date: ${selectedDateTime}');
            print('Expiration Durations: ${durations}');
            print('Recurrence Value: $recurrenceValue');
            print('Recurrence Unit: $selectedUnit');

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GoalScreen(
                  challengeHeader: widget.challengeHeader,
                  challengeDescription: widget.challengeDescription,
                  challengeListTitles: orderedTitles,
                  challengeTeams: widget.challengeTeams,
                  challengeFriends: widget.challengeFriends,
                  completionDate: selectedDateTime ?? DateTime(0), // Pass an empty value if no date is selected
                  expirationDurations: durations,
                  recurrenceValue: recurrenceValue,
                  recurrenceUnit: selectedUnit,
                ),
              ),
            );
          }
        },
        child: Icon(Icons.navigate_next),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectExpirationDuration(String title) async {
    Duration? selectedDuration = await showDialog<Duration>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select Expiration Duration for $title'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _numberController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Enter number of'),
                    onChanged: (value) {
                      setState(() {
                        recurrenceValue = int.tryParse(value) ?? 1;
                      });
                    },
                  ),
                  DropdownButton<String>(
                    value: selectedUnit,
                    onChanged: (newValue) {
                      setState(() {
                        selectedUnit = newValue!;
                      });
                    },
                    items: timeUnitOptions.map((unit) {
                      return DropdownMenuItem<String>(
                        value: unit,
                        child: Text(unit),
                      );
                    }).toList(),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Duration duration;
                switch (selectedUnit) {
                  case 'Day':
                    duration = Duration(days: recurrenceValue);
                    break;
                  case 'Hour':
                    duration = Duration(hours: recurrenceValue);
                    break;
                  case 'Week':
                    duration = Duration(days: recurrenceValue * 7);
                    break;
                  default:
                    duration = Duration(days: recurrenceValue);
                }
                Navigator.pop(context, duration);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );

    if (selectedDuration != null) {
      setState(() {
        expirationDurations[title] = selectedDuration;
      });
    }
  }
}