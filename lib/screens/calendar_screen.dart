import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upcoming'),
      ),
      body: const CalendarWithActivities(),
    );
  }
}

class CalendarWithActivities extends StatefulWidget {
  const CalendarWithActivities({Key? key}) : super(key: key);

  @override
  _CalendarWithActivitiesState createState() => _CalendarWithActivitiesState();
}

class _CalendarWithActivitiesState extends State<CalendarWithActivities> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay; // Initialize as nullable

  final Map<DateTime, List<String>> _events = {
    DateTime(DateTime.now().year, DateTime.now().month, 10): ['Event 1', 'Event 2'],
    DateTime(DateTime.now().year, DateTime.now().month, 15): ['Event 3'],
    DateTime(2023, 9, 18): ['100 Push-ups'], // Placeholder activity for Monday, September 18, 2023
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
                  color: Colors.red, // Red circle background for selected date
                ),
                child: Text(
                  date.day.toString(),
                  style: const TextStyle(
                    color: Colors.white, // White text color for selected date
                  ),
                ),
              );
            },
            todayBuilder: (context, date, _) {
              // Add visual indication for today's date (you can customize this)
              return Container(
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue, // Blue circle background for today's date
                ),
                child: Text(
                  date.day.toString(),
                  style: const TextStyle(
                    color: Colors.white, // White text color for today's date
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
                    fontSize: 24, // Increase font size
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _events[_selectedDay!]?.join(', ') ?? 'No activities', // Use the null-aware operator to handle null
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8), // Add spacing
                const Text(
                  'No events', // Additional line for "No events"
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
