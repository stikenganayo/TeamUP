import 'package:flutter/material.dart';
import 'package:snapchat_ui_clone/widgets/top_bar.dart';
import 'dart:io';
import '../style.dart';
import '../widgets/discover_grid.dart';
import '../widgets/stories.dart';
import '../widgets/subscriptions.dart';
import 'events_filter_page.dart'; // Import your EventsFilter screen

class StoriesScreen extends StatefulWidget {
  const StoriesScreen({Key? key}) : super(key: key);

  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Style.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          const TopBar(isCameraPage: false, text: 'Community'),
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height -
                100 -
                (Platform.isIOS ? 90 : 60),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start, // Align to the start (left)
                    children: [
                      Style.sectionTitle('Community Stories   '),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                              const EventsFilter(), // Navigate to EventsFilter
                            ),
                          );
                        },
                        child: Text('Filter'), // Add a Filter button
                      ),
                    ],
                  ),
                  const Stories(),
                  const SizedBox(height: 28),

                  Style.sectionTitle('Community Events'),
                  const Subscriptions(),
                  const SizedBox(height: 20),

                  Style.sectionTitle('Community Programs/Products'),
                  const Subscriptions(),
                  const SizedBox(height: 20),
                  // const DiscoverGrid(),

                  Style.sectionTitle('Community Projects'),
                  const Subscriptions(),
                  const SizedBox(height: 20),

                  Style.sectionTitle('Community Coaches'),
                  const Subscriptions(),
                  const SizedBox(height: 20),

                  Style.sectionTitle('Community Volunteering'),
                  const Subscriptions(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
