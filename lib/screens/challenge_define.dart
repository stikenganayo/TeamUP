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
  int recurrenceValue = 2;
  String selectedUnit = 'Day';
  int expirationValue = 1;
  String expirationUnit = 'Day';

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
        if (finalDateTime.isBefore(DateTime.now())) {
          _showErrorDialog('The selected date and time cannot be in the past.');
          return; // Exit the function if the date is invalid
        }
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
                  if (recurrenceValue <= 1) ...[
                    Text(
                      '',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
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
                if (recurrenceValue > 1) {
                  Navigator.pop(context, [recurrenceValue, selectedUnit]);
                } else {
                  _showErrorDialog('Please enter a number greater than 1.');
                }
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


  Future<void> _bulkSelectExpiration() async {
    Duration? selectedDuration = await showDialog<Duration>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select Expiration Duration for All Items'),
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
                        expirationValue = int.tryParse(value) ?? 1; // Update to use expirationValue
                      });
                    },
                  ),
                  DropdownButton<String>(
                    value: expirationUnit, // Update to use expirationUnit
                    onChanged: (newValue) {
                      setState(() {
                        expirationUnit = newValue!; // Update to use expirationUnit
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
                switch (expirationUnit) { // Update to use expirationUnit
                  case 'Day':
                    duration = Duration(days: expirationValue); // Update to use expirationValue
                    break;
                  case 'Hour':
                    duration = Duration(hours: expirationValue); // Update to use expirationValue
                    break;
                  case 'Week':
                    duration = Duration(days: expirationValue * 7); // Update to use expirationValue
                    break;
                  case 'Month':
                    duration = Duration(days: expirationValue * 30); // Update to use expirationValue
                    break;
                  default:
                    duration = Duration(days: expirationValue); // Update to use expirationValue
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
        for (var title in orderedTitles) {
          expirationDurations[title] = selectedDuration;
        }
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
              Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 35.0),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            IconButton(
                              icon: Icon(Icons.timer_outlined), // or another appropriate icon
                              onPressed: _bulkSelectExpiration,
                              tooltip: 'Bulk select expiration',
                              color: Colors.deepPurple[300], // Optional: Color to make it stand out
                            ),
                            Positioned(
                              right: 0,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                                decoration: BoxDecoration(
                                  color: Colors.deepPurple[300],
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  'All',
                                  style: TextStyle(color: Colors.white, fontSize: 10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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
                      ? 'Repeat the challenge every $selectedUnit for $recurrenceValue ${selectedUnit}s'
                      : "",
                ),
              ),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (selectedRecurrenceOption == 'Recurrence' && recurrenceValue <= 1) {
            _showErrorDialog('Please enter a number greater than 1 for repetitions.');
            return;
          }
          if (selectedRecurrenceOption == 'DateTime' && selectedDateTime != null && selectedDateTime!.isBefore(DateTime.now())) {
            _showErrorDialog('The selected date and time cannot be in the past.');
            return;
          }
          if (selectedRecurrenceOption == null) {
            _showErrorDialog('Please select a completion option before proceeding.');
          } else if (selectedRecurrenceOption == 'DateTime' && selectedDateTime == null) {
            _showErrorDialog('Please select a date and time before proceeding.');
          } else {
            // Get the current date
            DateTime currentDate = DateTime.now();

            // Initialize the completionDate variable
            DateTime? completionDate;

            // Calculate the completionDate if 'Set Repetition' is selected
            if (selectedRecurrenceOption == 'Recurrence') {
              // Calculate based on selected unit
              switch (selectedUnit) {
                case 'Hour': // For hour, add 1 hour
                  completionDate = currentDate.add(Duration(hours: 1));
                  break;
                case 'Day': // For day, add 1 day
                  completionDate = currentDate.add(Duration(days: 1));
                  break;
                case 'Week': // For week, add 7 days
                  completionDate = currentDate.add(Duration(days: 7));
                  break;
                case 'Month': // For month, add 1 month
                  completionDate = DateTime(
                    currentDate.year,
                    currentDate.month + 1,
                    currentDate.day,
                  );
                  break;
                default:
                  completionDate = DateTime(0); // Default fallback if no valid unit
              }
            } else if (selectedRecurrenceOption == 'DateTime') {
              completionDate = selectedDateTime;
            }

            // Ensure that completionDate is not null
            if (completionDate == null || completionDate.isAtSameMomentAs(DateTime(0))) {
              _showErrorDialog('Unable to determine the completion date.');
              return;
            }

            List<Duration> durations = orderedTitles.map((title) => expirationDurations[title] ?? Duration.zero).toList();

            // Print all parameters to the console
            print('Challenge Header: ${widget.challengeHeader}');
            print('Challenge Description: ${widget.challengeDescription}');
            print('Challenge List Titles: ${orderedTitles}');
            print('Challenge Teams: ${widget.challengeTeams}');
            print('Challenge Friends: ${widget.challengeFriends}');
            print('Completion Date: ${completionDate}');
            print('Expiration Durations: ${durations}');
            print('Recurrence Value: $recurrenceValue');
            print('Recurrence Unit: $selectedUnit');

            // Navigate to GoalScreen, passing the calculated completion date
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GoalScreen(
                  challengeHeader: widget.challengeHeader,
                  challengeDescription: widget.challengeDescription,
                  challengeListTitles: orderedTitles,
                  challengeTeams: widget.challengeTeams,
                  challengeFriends: widget.challengeFriends,
                  completionDate: completionDate ?? DateTime(0), // Pass a valid date
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
                        expirationValue = int.tryParse(value) ?? 1;
                      });
                    },
                  ),
                  DropdownButton<String>(
                    value: expirationUnit,
                    onChanged: (newValue) {
                      setState(() {
                        expirationUnit = newValue!;
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
                switch (expirationUnit) {
                  case 'Day':
                    duration = Duration(days: expirationValue);
                    break;
                  case 'Hour':
                    duration = Duration(hours: expirationValue);
                    break;
                  case 'Week':
                    duration = Duration(days: expirationValue * 7);
                    break;
                  default:
                    duration = Duration(days: expirationValue);
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