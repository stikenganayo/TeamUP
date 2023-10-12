import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:snapchat_ui_clone/widgets/story.dart';
import '../style.dart';

class Stories extends StatelessWidget {
  const Stories({Key? key}) : super(key: key);

  Future<List<String>> _loadTeamNamesFromJson() async {
    // Load JSON data from assets
    String jsonData = await rootBundle.loadString('assets/images/data/team_data.json');

    // Decode JSON data
    List<dynamic> teamDataList = json.decode(jsonData)['data'];

    // Extract team names from team_data.json
    List<String> teamNames = [];
    for (var userTeams in teamDataList.map((user) => user['UserTeams'])) {
      for (var team in userTeams.values) {
        teamNames.add(team['teamname']);
      }
    }

    return teamNames;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _loadTeamNamesFromJson(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Return a loading indicator while data is being fetched
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          // Handle error case
          return Text('Error: ${snapshot.error}');
        } else {
          // Generate widgets using the extracted team names
          List<String> teamNames = snapshot.data!;
          List<Widget> children = List.generate(
            teamNames.length,
                (index) => Column(
              children: [
                Story(index: index),
                Style.friendName(teamNames[index]),
              ],
            ),
          );

          children.insert(0, const SizedBox(width: 10));
          children.add(const SizedBox(width: 10));

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            child: Row(
              children: children,
            ),
          );
        }
      },
    );
  }
}
