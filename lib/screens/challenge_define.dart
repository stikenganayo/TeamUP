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
  List<String> timeUnitOptions = ['Minutes', 'Hours', 'Days', 'Months'];
  String selectedOrder = 'Any Order';
  List<String> orderedTitles = [];
  Map<String, Duration?> expirationDurations = {}; // Maps title to expiration duration

  final TextEditingController _numberController = TextEditingController();
  String selectedUnit = 'Minutes';
  DateTime? selectedDateTime;

  @override
  void initState() {
    super.initState();
    orderedTitles = List.from(widget.challengeListTitles);
  }

  Future<void> _selectExpirationDuration(String title) async {
    Duration? selectedDuration = await showDialog<Duration>(
      context: context,
      builder: (context) {
        Duration? duration;
        return AlertDialog(
          title: Text('Select Expiration Duration'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _numberController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Enter duration'),
                    onChanged: (value) {
                      // Update duration calculation when the input changes
                      _updateDuration(title);
                      setState(() {}); // Refresh to show the updated duration
                    },
                  ),
                  DropdownButton<String>(
                    value: selectedUnit,
                    onChanged: (newValue) {
                      setState(() {
                        selectedUnit = newValue!;
                        _updateDuration(title);
                      });
                    },
                    items: timeUnitOptions.map((unit) {
                      return DropdownMenuItem<String>(
                        value: unit,
                        child: Text(unit),
                      );
                    }).toList(),
                  ),
                  if (expirationDurations[title] != null)
                    Text('Selected: ${durationToString(expirationDurations[title]!)}'),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        expirationDurations[title] = null;
                        _numberController.clear(); // Clear the input field
                      });
                      Navigator.pop(context);
                    },
                    child: Text('Remove Expiration Date', style: TextStyle(color: Colors.red)),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, expirationDurations[title]);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );

    setState(() {
      if (selectedDuration != null) {
        expirationDurations[title] = selectedDuration;
      }
    });
  }

  void _updateDuration(String title) {
    final int? number = int.tryParse(_numberController.text);
    if (number != null) {
      Duration? newDuration;
      switch (selectedUnit) {
        case 'Minutes':
          newDuration = Duration(minutes: number);
          break;
        case 'Hours':
          newDuration = Duration(hours: number);
          break;
        case 'Days':
          newDuration = Duration(days: number);
          break;
        case 'Months':
          newDuration = Duration(days: number * 30); // Approximation for months
          break;
      }
      setState(() {
        expirationDurations[title] = newDuration; // Update duration for the specific item
      });
    }
  }

  String durationToString(Duration duration) {
    if (duration.inDays > 0) return '${duration.inDays} Day(s)';
    if (duration.inHours > 0) return '${duration.inHours} Hour(s)';
    if (duration.inMinutes > 0) return '${duration.inMinutes} Minute(s)';
    return '0 Minute(s)';
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
                    // No need to update the expirationDurations map as keys remain the same
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
                        ? Text('Expires in: ${durationToString(expirationDurations[title]!)}')
                        : null,
                  );
                }),
              ),
            ],
            const SizedBox(height: 16),
            const Text(
              'Select Completion Date and Time',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose the date and time when the challenge should be completed. This is required to set a deadline for the challenge.',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _selectDate,
              child: Text(
                selectedDateTime == null
                    ? 'Select Date and Time'
                    : DateFormat('MMMM d, yyyy – h:mm a').format(selectedDateTime!),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (selectedDateTime == null) {
            _showErrorDialog('Please select a date and time before proceeding.');
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GoalScreen(
                  challengeHeader: widget.challengeHeader,
                  challengeDescription: widget.challengeDescription,
                  challengeListTitles: orderedTitles,
                  challengeTeams: widget.challengeTeams,
                  challengeFriends: widget.challengeFriends,
                  completionDate: selectedDateTime!,
                  expirationDurations: orderedTitles.map((title) => expirationDurations[title]).toList(),
                ),
              ),
            );
          }
        },
        child: Icon(Icons.navigate_next),
      ),
    );
  }
}