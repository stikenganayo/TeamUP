import 'package:flutter/material.dart';
import 'package:snapchat_ui_clone/widgets/top_bar.dart';
import 'dart:io';
import '../style.dart';
import '../widgets/discover_grid.dart';
import '../widgets/stories.dart';
import '../widgets/subscriptions.dart';

class TeamScreen extends StatefulWidget {
  const TeamScreen({Key? key}) : super(key: key);

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Style.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children:  [
          const TopBar(isCameraPage: false, text: 'Team'),
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
                    const SizedBox(height: 28),

                    // Style.sectionTitle('Coaches'),
                    // const Subscriptions(),
                    // const SizedBox(height: 20),
                    //
                    // Style.sectionTitle('Programs/Products'),
                    // const DiscoverGrid(),
                  ],
                ),
              )
          )
        ],
      ),
    );
  }
}