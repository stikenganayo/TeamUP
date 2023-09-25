import 'package:flutter/material.dart';

class EventsFilter extends StatefulWidget {
  const EventsFilter({Key? key}) : super(key: key);

  @override
  _EventsFilterState createState() => _EventsFilterState();
}

class _EventsFilterState extends State<EventsFilter> {
  String selectedTeamType = 'All Teams'; // Initial value for team type dropdown
  String selectedEventType = 'All Events'; // Initial value for event type dropdown

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Filters'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Search Event',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextFormField(
              decoration: InputDecoration(
                hintText: 'Enter event name',
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Search Location',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextFormField(
              decoration: InputDecoration(
                hintText: 'Enter location',
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Select Team Type',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              value: selectedTeamType,
              onChanged: (String? newValue) {
                setState(() {
                  selectedTeamType = newValue!;
                });
              },
              items: <String>[
                'All Teams',
                'Team Type 1',
                'Team Type 2',
                'Team Type 3',
                // Add more team types as needed
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            Text(
              'Select Event Type',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              value: selectedEventType,
              onChanged: (String? newValue) {
                setState(() {
                  selectedEventType = newValue!;
                });
              },
              items: <String>[
                'All Events',
                'Event Type 1',
                'Event Type 2',
                'Event Type 3',
                // Add more event types as needed
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Implement filter logic here based on selected options
        },
        child: Icon(Icons.filter_list),
      ),
    );
  }
}