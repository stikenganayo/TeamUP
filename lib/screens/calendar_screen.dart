import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'add_event_screen.dart';
import 'add_challenge_screen.dart'; // Import the CreateChallenge screen

import 'list_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calendar App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CalendarScreen(),
    );
  }
}

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('View Events/Activities'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Calendar View'),
              Tab(text: 'List View'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            // First tab - CalendarScreen
            CalendarWithActivities(),
            // Second tab - NotificationScreen
            ListScreen(),
          ],
        ),
        floatingActionButton: Align(
          alignment: Alignment.bottomCenter,
          child: FloatingActionButton(
            onPressed: () {
              // Your existing FAB logic
              String? _menuSelected;
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ListTile(
                        leading: const Icon(CupertinoIcons.stopwatch),
                        title: const Text('Add Challenge'),
                        onTap: () {
                          _menuSelected = 'Challenge';
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CreateChallenge(),
                            ),
                          );
                        },
                      ),
                      GestureDetector(
                        onTap: () {
                          _menuSelected = 'Event';
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CreateEvent(),
                            ),
                          );
                        },
                        child: const ListTile(
                          leading: Icon(CupertinoIcons.globe),
                          title: Text('Add Event'),
                        ),
                      ),
                    ],
                  );
                },
              ).then((value) {
                // Handle the selected option (_menuSelected)
                if (_menuSelected == 'Challenge') {
                  // Handle Challenge option
                } else if (_menuSelected == 'Event') {
                  // Handle Event option
                }
              });
            },
            child: const Icon(Icons.add, size: 36.0),
          ),
        ),
      ),
    );
  }
}

class CalendarWithActivities extends StatefulWidget {
  const CalendarWithActivities({Key? key}) : super(key: key);

  @override
  _CalendarWithActivitiesState createState() =>
      _CalendarWithActivitiesState();
}

class _CalendarWithActivitiesState extends State<CalendarWithActivities> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final Map<DateTime, List<String>> _events = {
    DateTime(DateTime.now().year, DateTime.now().month, 10): ['Event 1', 'Event 2'],
    DateTime(DateTime.now().year, DateTime.now().month, 15): ['Event 3'],
    DateTime(2023, 9, 18): ['100 Push-ups'],
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime.utc(2023, 1, 1),
          lastDay: DateTime.utc(2023, 12, 31),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          onFormatChanged: (format) {
            setState(() {
              _calendarFormat = format;
            });
          },
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          eventLoader: (day) {
            return _events[day] ?? [];
          },
          calendarBuilders: CalendarBuilders(
            selectedBuilder: (context, date, _) {
              return Container(
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red,
                ),
                child: Text(
                  date.day.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              );
            },
            todayBuilder: (context, date, _) {
              return Container(
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue,
                ),
                child: Text(
                  date.day.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        if (_selectedDay != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              children: [
                Text(
                  DateFormat('EEEE').format(_selectedDay!),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _events[_selectedDay!]?.join(', ') ?? 'No activities',
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'No events',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
