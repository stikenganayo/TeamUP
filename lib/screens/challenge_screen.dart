import 'dart:math';

import 'package:flutter/material.dart';
import 'package:snapchat_ui_clone/widgets/top_bar.dart';
import 'dart:io';
import '../style.dart';
import '../widgets/stories.dart';

class ChallengeScreen extends StatefulWidget {
  const ChallengeScreen({Key? key}) : super(key: key);

  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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

                    Center(
                      // ListView with ExpansionTiles wrapping each _IconListItem
                      child: ListView(
                        padding: const EdgeInsets.all(2),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: const <Widget>[
                          _ExpansionIconListItem(icon: Icons.add_box, title: 'Custom Challenge'),
                          _ExpansionIconListItem(icon: Icons.book, title: 'Self-Awareness & Self-Reflection', subItems: [
                            'Emotional Awareness',
                            'Self-Identity',
                            'Sses',
                            'Tns',
                            'Gons',
                            'fdgdfg',
                            'MiAwareness',
                            'Pehers',
                            'Trins',
                            'Seing',
                            'Perrowth',
                            'Selon',

                          ]),
                          _ExpansionIconListItem(icon: Icons.sports, title: 'G'),
                          _ExpansionIconListItem(icon: Icons.group, title: 'L'),
                          _ExpansionIconListItem(icon: Icons.attach_money, title: 'He'),
                          _ExpansionIconListItem(icon: Icons.monitor_heart, title: 'R'),
                          _ExpansionIconListItem(icon: Icons.person, title: 'Ti'),
                          _ExpansionIconListItem(icon: Icons.person, title: 'F & Management'),
                          _ExpansionIconListItem(icon: Icons.person, title: 'Emotiona'),
                          _ExpansionIconListItem(icon: Icons.person, title: 'Spiri'),
                          _ExpansionIconListItem(icon: Icons.person, title: 'Creat'),
                          _ExpansionIconListItem(icon: Icons.person, title: 'Pers'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpansionIconListItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String>? subItems;

  const _ExpansionIconListItem({required this.icon, required this.title, this.subItems});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueGrey, width: 2),
        borderRadius: BorderRadius.circular(5),
      ),
      child: ExpansionTile(
        leading: Icon(icon),
        title: Text(title),
        children: <Widget>[
          if (subItems != null)
            Column(
              children: subItems!.map((item) {
                return ListTile(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return Container(
                          height: 200,
                          child: ListView(
                            children: const [

                              _SubExpansionIconListItem(icon: Icons.add_box, title: 'Emotional Awareness'),
                              _SubExpansionIconListItem(icon: Icons.add_box, title: 'Self-Identity'),

                            ],
                          ),
                        );
                      },
                    );
                  },
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item),
                      const Icon(Icons.expand_more),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class _SubExpansionIconListItem extends StatefulWidget {
  final IconData icon;
  final String title;

  const _SubExpansionIconListItem({required this.icon, required this.title});

  @override
  _SubExpansionIconListItemState createState() =>
      _SubExpansionIconListItemState();
}

class _SubExpansionIconListItemState extends State<_SubExpansionIconListItem> {
  Set<String> selectedItems = Set();

  @override
  Widget build(BuildContext context) {
    List<String> emotionalAwarenessItem = [
      'Emotion Journaling',
      'Emotion Wheel',
      'Mindfulness Meditation',
      'Guided Visualization',

      'Emotion Charades',
      'Feelings Thermometer',
      'Art Expression',
      'Emotion Cards',

      'Role Play',
      'Emotion Sharing Circles',
      'Reflective Writing',
      'Music Exploration',

      'Group Emotion Mapping',
      'Storytelling',
      'Emotion-focused Apps',


    ];

    List<String> selfIdentityItem = [
      'Self-Portrait',
      'Values Exploration',
      '"I Am" Collage',
      'Identity Timeline',

      'Personal Statement',
      'Cultural Exploration',
      'Letter to Your Younger Self',
      'Positive Affirmations',

      'Identity Wheel',
      'Strengths Assessment',
      'Identity Map',
      'Name Exploration',

      'Bucket List',
      'Reflective Writing Prompts',
      'Identity Interviews',


    ];

    List<String> items = widget.title == 'Emotional Awareness'
        ? emotionalAwarenessItem
        : widget.title == 'Self-Identity'
        ? selfIdentityItem
        : [];

    return Column(
      children: items.map((item) {
        bool isSelected = selectedItems.contains(item);

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey, width: 1),
            ),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      selectedItems.remove(item);
                    } else {
                      selectedItems.add(item);
                    }
                  });
                },
                child: Icon(
                  isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Navigate to the new app page
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        // Replace with the widget you want to display on the new app page
                        return NewItemScreen(itemName: item);
                      },
                    ),
                  );
                },
                child: const Icon(Icons.add_box),
              ),
              const SizedBox(width: 4),
              Text(item),
            ],
          ),
        );
      }).toList(),
    );
  }
}



class NewItemScreen extends StatefulWidget {
  final String itemName;

  const NewItemScreen({Key? key, required this.itemName}) : super(key: key);

  @override
  _NewItemScreenState createState() => _NewItemScreenState();
}

class _NewItemScreenState extends State<NewItemScreen> {
  late TextEditingController _textEditingController;
  late String updatedItemName;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController(text: widget.itemName);
    updatedItemName = widget.itemName;
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Challenge'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          TextFormField(
            controller: _textEditingController,
            decoration: const InputDecoration(
              labelText: 'Edit Challenge Name',
            ),
            onChanged: (newValue) {
              setState(() {
                updatedItemName = newValue;
              });
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Perform an action with the updated item name, if needed
            },
            child: const Text('Update Item Name'),
          ),
        ],
      ),
    );
  }
}
































//Code that contains the expansion tile only showing one level

// import 'package:flutter/material.dart';
// import 'package:snapchat_ui_clone/screens/login_screen.dart';
// import 'package:snapchat_ui_clone/widgets/top_bar.dart';
// import 'dart:io';
// import '../style.dart';
// import '../widgets/discover_grid.dart';
// import '../widgets/stories.dart';
// import '../widgets/subscriptions.dart';
// import 'add_challenge_screen.dart';
//
// class ChallengeScreen extends StatefulWidget {
//   const ChallengeScreen({Key? key}) : super(key: key);
//
//   @override
//   State<ChallengeScreen> createState() => _ChallengeScreenState();
// }
//
// class _ChallengeScreenState extends State<ChallengeScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Style.white,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Stack(
//         children: [
//           const TopBar(isCameraPage: false, text: 'Challenge'),
//           Positioned(
//             top: 100,
//             left: 0,
//             right: 0,
//             height: MediaQuery.of(context).size.height - 100 - (Platform.isIOS ? 90 : 60),
//             child: SingleChildScrollView(
//               physics: const BouncingScrollPhysics(),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Style.sectionTitle('Team Stories'),
//                   const Stories(),
//                   const SizedBox(height: 18),
//                   Style.sectionTitle('Select A Challenge'),
//                   const SizedBox(height: 18),
//
//                   // Center(
//                   //   child: GestureDetector(
//                   //     onTap: () {
//                   //       Navigator.push(
//                   //         context,
//                   //         MaterialPageRoute(builder: (context) => const AddChallenge()),
//                   //       );
//                   //     },
//                   //     child: Container(
//                   //       padding: const EdgeInsets.all(8),
//                   //       decoration: const BoxDecoration(
//                   //         shape: BoxShape.circle,
//                   //         color: Colors.blue,
//                   //       ),
//                   //       child: const Icon(Icons.add, size: 32, color: Colors.white),
//                   //     ),
//                   //   ),
//                   // ),
//                   Center(
//
//
//                     // ListView with ExpansionTiles wrapping each _IconListItem
//                     child: ListView(
//                       padding: const EdgeInsets.all(2),
//                       shrinkWrap: true,
//                       physics: const NeverScrollableScrollPhysics(), // Disable scrolling within the ListView
//                       children: const <Widget>[
//                         _ExpansionIconListItem(icon: Icons.add_box, title: 'Custom Challenge'),
//                         _ExpansionIconListItem(icon: Icons.book, title: 'Self-Awareness & Self-Reflection'),
//                         _ExpansionIconListItem(icon: Icons.sports, title: 'Goal Setting & Planning'),
//                         _ExpansionIconListItem(icon: Icons.group, title: 'Learning & Skill Development'),
//                         _ExpansionIconListItem(icon: Icons.attach_money, title: 'Health & Well-being'),
//                         _ExpansionIconListItem(icon: Icons.monitor_heart, title: 'Relationships & Communication'),
//                         _ExpansionIconListItem(icon: Icons.person, title: 'Time Management & Productivity'),
//                         _ExpansionIconListItem(icon: Icons.person, title: 'Financial Literacy & Management'),
//                         _ExpansionIconListItem(icon: Icons.person, title: 'Emotional Intelligence'),
//                         _ExpansionIconListItem(icon: Icons.person, title: 'Spirituality & Purpose'),
//                         _ExpansionIconListItem(icon: Icons.person, title: 'Creativity & Self-Expression'),
//                         _ExpansionIconListItem(icon: Icons.person, title: 'Personal Boundaries & Self-Care'),
//                       ],
//                     ),
//                   ),
//                   // Uncomment the following sections if needed:
//                   // Style.sectionTitle('Coaches'),
//                   // const Subscriptions(),
//                   // const SizedBox(height: 20),
//                   //
//                   // Style.sectionTitle('Programs/Products'),
//                   // const DiscoverGrid(),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
//
//
//
//
//
// class _ExpansionIconListItem extends StatelessWidget {
//   final IconData icon;
//   final String title;
//
//   const _ExpansionIconListItem({required this.icon, required this.title});
//
//   @override
//   Widget build(BuildContext context) {
//     List<String> SelfAwarenessSelfReflectionCategories = [
//       'Incline barbell',
//       'Pushups',
//       'Incline Bench',
//       'Side lunges',
//     ];
//
//     List<String> mentalWellnessItems = [
//       'Meditation',
//       'Deep breathing',
//       'Positive affirmations',
//     ];
//
//     List<String> socialWellnessItems = [
//       'Chat with a friend',
//       'Learn a language',
//       'Host a game night',
//       'Go for a drink with a friend',
//     ];
//
//     List<String> financialWellnessItems = [
//       'Build a financial plan',
//       'Minimize restaurant spending',
//       'Map out major purchases',
//       'Restrict online shopping',
//     ];
//
//     List<String> selectedItems = title == 'Self-Awareness & Self-Reflection'
//         ? SelfAwarenessSelfReflectionCategories
//         : title == 'Mental Wellness'
//         ? mentalWellnessItems
//         : title == 'Social Wellness'
//         ? socialWellnessItems
//         : title == 'Financial Wellness'
//         ? financialWellnessItems
//         : [];
//
//     return Container(
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.blueGrey, width: 2),
//         borderRadius: BorderRadius.circular(5),
//       ),
//       child: ExpansionTile(
//         leading: Icon(icon),
//         title: Text(title),
//         children: <Widget>[
//           if (selectedItems.isNotEmpty)
//             Container(
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.blueGrey, width: 2),
//                 borderRadius: BorderRadius.circular(18),
//               ),
//               margin: const EdgeInsets.all(4.0),
//               padding: const EdgeInsets.all(4.0),
//               child: ListView.builder(
//                 padding: const EdgeInsets.symmetric(vertical: 10),
//                 shrinkWrap: true,
//                 itemCount: selectedItems.length,
//                 itemBuilder: (context, index) {
//                   bool isItemSelected = false;
//
//                   return StatefulBuilder(
//                     builder: (context, setState) {
//                       return Container(
//                         padding: const EdgeInsets.symmetric(vertical: 10),
//                         decoration: const BoxDecoration(
//                           border: Border(
//                             bottom: BorderSide(color: Colors.grey, width: 1),
//                           ),
//                         ),
//                         child: Row(
//                           children: [
//                             GestureDetector(
//                               onTap: () {
//                                 setState(() {
//                                   isItemSelected = !isItemSelected;
//                                 });
//                               },
//                               child: Icon(
//                                 isItemSelected
//                                     ? Icons.check_box
//                                     : Icons.check_box_outline_blank,
//                               ),
//                             ),
//                             GestureDetector(
//                               onTap: () {
//                                 // Navigate to the new app page
//                                 Navigator.of(context).push(
//                                   MaterialPageRoute(
//                                     builder: (context) {
//                                       // Replace with the widget you want to display on the new app page
//                                       return NewItemScreen(itemName: selectedItems[index],);
//                                     },
//                                   ),
//                                 );
//                               },
//                               child: const Icon(Icons.add_box),
//                             ),
//                             const SizedBox(width: 4),
//                             Text(selectedItems[index]),
//                           ],
//                         ),
//                       );
//                     },
//                   );
//                 },
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
//
//
//
//
//
//
//
//
// class NewItemScreen extends StatefulWidget {
//   final String itemName;
//
//   const NewItemScreen({Key? key, required this.itemName}) : super(key: key);
//
//   @override
//   _NewItemScreenState createState() => _NewItemScreenState();
// }
//
// class _NewItemScreenState extends State<NewItemScreen> {
//   late TextEditingController _textEditingController;
//   late String updatedItemName;
//
//   @override
//   void initState() {
//     super.initState();
//     _textEditingController = TextEditingController(text: widget.itemName);
//     updatedItemName = widget.itemName;
//   }
//
//   @override
//   void dispose() {
//     _textEditingController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Set Challenge'),
//       ),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.end,
//         mainAxisAlignment: MainAxisAlignment.start,
//         children: [
//           const SizedBox(height: 20),
//           TextFormField(
//             controller: _textEditingController,
//             decoration: const InputDecoration(
//               labelText: 'Edit Challenge Name',
//             ),
//             onChanged: (newValue) {
//               setState(() {
//                 updatedItemName = newValue;
//               });
//             },
//           ),
//           const SizedBox(height: 20),
//           ElevatedButton(
//             onPressed: () {
//               // Perform an action with the updated item name, if needed
//             },
//             child: Text('Update Item Name'),
//           ),
//         ],
//       ),
//     );
//   }
// }
