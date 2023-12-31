import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Add this import for rootBundle
import 'dart:convert';
import 'package:snapchat_ui_clone/widgets/story.dart';
import '../style.dart';

class Stories extends StatelessWidget {
  const Stories({Key? key}) : super(key: key);

  Future<List<String>> _loadNamesFromJson() async {
    // Load JSON data from assets
    String jsonData = await rootBundle.loadString('assets/images/data/team_data.json');

    // Decode JSON data
    Map<String, dynamic> teamData = json.decode(jsonData);

    // Extract names from team_data.json
    List<String> names = [];
    for (var user in teamData['data']) {
      for (var team in user['UserTeams'].values) {
        for (var teammate in team['teammates']) {
          names.add(teammate['name']);
        }
      }
    }

    return names;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _loadNamesFromJson(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Return a loading indicator while data is being fetched
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          // Handle error case
          return Text('Error: ${snapshot.error}');
        } else {
          // Generate widgets using the extracted names
          List<String> names = snapshot.data!;
          List<Widget> children = List.generate(
            names.length,
                (index) => Column(
              children: [
                Story(index: index),
                Style.friendName(names[index]),
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
