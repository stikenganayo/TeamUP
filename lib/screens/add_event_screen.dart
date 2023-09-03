import 'package:flutter/material.dart';

class CreateEvent extends StatefulWidget {
  const CreateEvent({Key? key}) : super(key: key);

  @override
  _CreateEventState createState() => _CreateEventState();
}

class _CreateEventState extends State<CreateEvent> {
  String eventTitle = "";
  DateTime startDate = DateTime.now();
  TimeOfDay startTime = TimeOfDay.now();
  DateTime endDate = DateTime.now();
  TimeOfDay endTime = TimeOfDay.now();
  String eventLocation = "";
  bool canPostEvent = false;

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime pickedDate = (await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    ))!;
    if (pickedDate != null && pickedDate != startDate) {
      setState(() {
        startDate = pickedDate;
      });
    }
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay pickedTime = (await showTimePicker(
      context: context,
      initialTime: startTime,
    ))!;
    if (pickedTime != null && pickedTime != startTime) {
      setState(() {
        startTime = pickedTime;
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime pickedDate = (await showDatePicker(
      context: context,
      initialDate: endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    ))!;
    if (pickedDate != null && pickedDate != endDate) {
      setState(() {
        endDate = pickedDate;
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay pickedTime = (await showTimePicker(
      context: context,
      initialTime: endTime,
    ))!;
    if (pickedTime != null && pickedTime != endTime) {
      setState(() {
        endTime = pickedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Event!'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              TextField(
                onChanged: (value) {
                  setState(() {
                    eventTitle = value;
                    canPostEvent = eventTitle.isNotEmpty && eventLocation.isNotEmpty;
                  });
                },
                decoration: const InputDecoration(labelText: 'Event Title'),
              ),
              const SizedBox(height: 20),
              Row(
                children: <Widget>[
                  TextButton(
                    onPressed: () => _selectStartDate(context),
                    child: const Text(
                      'Select Start Date',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    '${startDate.toLocal()}'.split(' ')[0],
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  TextButton(
                    onPressed: () => _selectStartTime(context),
                    child: const Text(
                      'Select Start Time',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  SizedBox(width: 20),
                  Text(
                    '${startTime.format(context)}',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),

              Row(
                children: <Widget>[
                  TextButton(
                    onPressed: () => _selectEndTime(context),
                    child: const Text(
                      'Select End Time',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    '${endTime.format(context)}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                onChanged: (value) {
                  setState(() {
                    eventLocation = value;
                    canPostEvent = eventTitle.isNotEmpty && eventLocation.isNotEmpty;
                  });
                },
                decoration: const InputDecoration(labelText: 'Event Location'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: canPostEvent ? postEvent : null, // Disable the button when fields are empty
                child: const Text('Post Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void postEvent() {
    // Implement your logic to post the event here
    print('Event Posted:');
    print('Event Title: $eventTitle');
    print('Start Date: $startDate');
    print('Start Time: ${startTime.format(context)}');
    print('End Date: $endDate');
    print('End Time: ${endTime.format(context)}');
    print('Event Location: $eventLocation');
  }
}