import 'package:flutter/material.dart';
import 'challenge_preview.dart';

class GoalScreen extends StatefulWidget {
  @override
  _GoalScreenState createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  String selectedGoal = 'Miles'; // Initialize with a default value
  List<String> goalOptions = ['Miles', 'Steps', 'Calories'];
  bool showUnitsDropdown = false;
  bool showFrequencyDropdowns = false;

  Widget _buildGoalField() {
    return Row(
      children: [
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Set a Goal',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        showUnitsDropdown = !showUnitsDropdown;
                      });
                    },
                    child: Text(showUnitsDropdown ? 'Remove Units' : 'Units'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Flexible(
                    child: TextFormField(
                      onChanged: (value) {
                        // Handle goal input
                      },
                      decoration: const InputDecoration(
                        hintText: 'Enter a Goal',
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (showUnitsDropdown)
                    DropdownButton<String>(
                      value: selectedGoal,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedGoal = newValue;
                          });
                        }
                      },
                      items: goalOptions.map<DropdownMenuItem<String>>(
                            (String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        },
                      ).toList(),
                      hint: Text('Units'),
                    ),
                  const SizedBox(width: 10),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Goal'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildGoalField(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ReviewPostScreen()),
          );
        },
        child: Icon(Icons.check),
      ),
    );
  }
}