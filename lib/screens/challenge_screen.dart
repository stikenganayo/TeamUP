import 'package:flutter/material.dart';
import 'package:snapchat_ui_clone/widgets/top_bar.dart';
import 'dart:io';
import '../style.dart';
import '../widgets/discover_grid.dart';
import '../widgets/stories.dart';
import '../widgets/subscriptions.dart';
import 'add_challenge_screen.dart';

class ChallengeScreen extends StatefulWidget {
  const ChallengeScreen({Key? key}) : super(key: key);

  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Style.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          const TopBar(isCameraPage: false, text: 'Challenge'),
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height - 100 - (Platform.isIOS ? 90 : 60),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Style.sectionTitle('Team Stories'),
                  const Stories(),
                  const SizedBox(height: 18),
                  Style.sectionTitle('Select A Challenge'),
                  const SizedBox(height: 18),

                  // Center(
                  //   child: GestureDetector(
                  //     onTap: () {
                  //       Navigator.push(
                  //         context,
                  //         MaterialPageRoute(builder: (context) => const AddChallenge()),
                  //       );
                  //     },
                  //     child: Container(
                  //       padding: const EdgeInsets.all(8),
                  //       decoration: const BoxDecoration(
                  //         shape: BoxShape.circle,
                  //         color: Colors.blue,
                  //       ),
                  //       child: const Icon(Icons.add, size: 32, color: Colors.white),
                  //     ),
                  //   ),
                  // ),
                  Center(


                    // ListView with ExpansionTiles wrapping each _IconListItem
                    child: ListView(
                      padding: const EdgeInsets.all(2),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(), // Disable scrolling within the ListView
                      children: const <Widget>[
                        _ExpansionIconListItem(icon: Icons.add_box, title: 'Custom Challenge'),
                        _ExpansionIconListItem(icon: Icons.book, title: 'Mental Wellness'),
                        _ExpansionIconListItem(icon: Icons.sports, title: 'Physical Wellness'),
                        _ExpansionIconListItem(icon: Icons.group, title: 'Social Wellness'),
                        _ExpansionIconListItem(icon: Icons.attach_money, title: 'Financial Wellness'),
                        _ExpansionIconListItem(icon: Icons.monitor_heart, title: 'Spiritual Wellness'),
                        _ExpansionIconListItem(icon: Icons.person, title: 'Vocational Wellness'),
                      ],
                    ),
                  ),
                  // Uncomment the following sections if needed:
                  // Style.sectionTitle('Coaches'),
                  // const Subscriptions(),
                  // const SizedBox(height: 20),
                  //
                  // Style.sectionTitle('Programs/Products'),
                  // const DiscoverGrid(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpansionIconListItem extends StatelessWidget {
  final IconData icon;
  final String title;

  const _ExpansionIconListItem({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueGrey, width: 2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ExpansionTile(
        leading: Icon(icon),
        title: Text(title),
        children: const <Widget>[
          // Add additional content for each expansion tile if needed
          // You can put any widgets here that you want to display when the tile is expanded.
          // For example, you could include buttons, descriptions, or more information.
        ],
      ),
    );
  }
}