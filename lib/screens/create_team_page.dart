import 'package:flutter/material.dart';

class CreateTeam extends StatefulWidget {
  const CreateTeam({Key? key}) : super(key: key);

  @override
  _CreateTeamState createState() => _CreateTeamState();
}

class _CreateTeamState extends State<CreateTeam> {
  String selectedTeamType = 'All Teams'; // Initial value for team type dropdown
  String selectedEventType = 'All Events'; // Initial value for event type dropdown

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Team'),
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