import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:random_color/random_color.dart';
import 'package:flutter/material.dart';
import 'package:snapchat_ui_clone/widgets/top_bar.dart';
import 'dart:io';
import '../style.dart';
import '../widgets/stories.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key, required String friendName}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with SingleTickerProviderStateMixin {
  late User? currentUser;
  late TabController _tabController;
  List<String> userNames = []; // List to store user names
  List<String> teamNames = []; // List to store team names
  Map<String, bool> newMessages = {}; // Map to store new message indicators

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadCurrentUserFriends();
    _loadCurrentUserTeams();
  }

  Future<void> _loadCurrentUserFriends() async {
    try {
      String? userName = await _loadCurrentUserName();
      if (userName != null) {
        QuerySnapshot userQuerySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('name', isEqualTo: userName)
            .limit(1)
            .get();

        if (userQuerySnapshot.docs.isNotEmpty) {
          DocumentSnapshot userSnapshot = userQuerySnapshot.docs.first;
          Map<String, dynamic> userData =
          userSnapshot.data() as Map<String, dynamic>;

          if (userData.containsKey('friends')) {
            List<dynamic> friends = userData['friends'];

            for (String friendEmail in friends) {
              QuerySnapshot friendQuerySnapshot = await FirebaseFirestore
                  .instance
                  .collection('users')
                  .where('email', isEqualTo: friendEmail)
                  .limit(1)
                  .get();

              if (friendQuerySnapshot.docs.isNotEmpty) {
                DocumentSnapshot friendSnapshot = friendQuerySnapshot.docs
                    .first;
                Map<String, dynamic> friendData =
                friendSnapshot.data() as Map<String, dynamic>;

                if (friendData.containsKey('name')) {
                  String friendName = friendData['name'] as String;
                  setState(() {
                    userNames.add(friendName);
                  });

                  // Check if the most recent message has been seen
                  await _checkNewMessages(userName, friendName);
                } else {
                  print(
                      'Name field not found for friend with email: $friendEmail');
                }
              } else {
                print(
                    'User document not found for friend with email: $friendEmail');
              }
            }
          } else {
            print('$userName has no friends.');
          }
        } else {
          print('User document not found for $userName');
        }
      } else {
        print('Current user name is null');
      }
    } catch (e) {
      print('Error loading user friends: $e');
    }
  }

  Future<void> _checkNewMessages(String userName, String friendName) async {
    try {
      QuerySnapshot userQuerySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('name', isEqualTo: userName)
          .limit(1)
          .get();

      if (userQuerySnapshot.docs.isNotEmpty) {
        DocumentSnapshot userSnapshot = userQuerySnapshot.docs.first;
        Map<String, dynamic> userData =
        userSnapshot.data() as Map<String, dynamic>;

        List<dynamic> messages =
        (userData['message_with_$friendName'] ?? []) as List<dynamic>;
        if (messages.isNotEmpty) {
          Map<String, dynamic> latestMessage = messages.last;
          bool seen = latestMessage['Seen'] == 'yes';
          setState(() {
            newMessages[friendName] =
            !seen; // Store the indicator for new messages
          });
        }
      }
    } catch (e) {
      print('Error checking new messages: $e');
    }
  }

  Future<String?> _loadCurrentUserName() async {
    currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      print('Current User Email: ${currentUser!.email}');

      try {
        QuerySnapshot userQuerySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: currentUser!.email)
            .limit(1)
            .get();

        if (userQuerySnapshot.docs.isNotEmpty) {
          DocumentSnapshot userSnapshot = userQuerySnapshot.docs.first;
          Map<String, dynamic> userData =
          userSnapshot.data() as Map<String, dynamic>;

          print('User Data: $userData');

          if (userData.containsKey('name')) {
            String userName = userData['name'] as String;
            return userName;
          } else {
            print('Name field not found in user document');
          }
        } else {
          print('User document not found for the current user');
        }
      } catch (e) {
        print('Error loading user document: $e');
      }
    }
    return null;
  }

  Future<void> _loadCurrentUserTeams() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        String currentUserEmail = currentUser.email!;
        QuerySnapshot userQuerySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: currentUserEmail)
            .limit(1)
            .get();

        if (userQuerySnapshot.docs.isNotEmpty) {
          DocumentSnapshot userSnapshot = userQuerySnapshot.docs.first;
          Map<String, dynamic> userData =
          userSnapshot.data() as Map<String, dynamic>;

          if (userData.containsKey('team_ids')) {
            List<dynamic> teamIds = userData['team_ids'];
            List<String> teamNames = [];

            for (String teamId in teamIds) {
              DocumentSnapshot teamSnapshot =
              await FirebaseFirestore.instance.collection('teams')
                  .doc(teamId)
                  .get();

              if (teamSnapshot.exists) {
                Map<String, dynamic> teamData =
                teamSnapshot.data() as Map<String, dynamic>;
                if (teamData.containsKey('team_name')) {
                  teamNames.add(teamData['team_name']);
                }
              }
            }
            setState(() {
              this.teamNames = teamNames;
            });
          } else {
            print('Team_ids field not found in user document');
          }
        } else {
          print('User document not found for the current user');
        }
      } else {
        print('Current user is null');
      }
    } catch (e) {
      print('Error fetching user teams: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Style.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          const TopBar(isCameraPage: false, text: 'Chats'),
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            height: MediaQuery
                .of(context)
                .size
                .height - 100 - (Platform.isIOS ? 90 : 60),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Style.sectionTitle('Friend Stories'),
                  const Stories(),
                  const SizedBox(height: 28),
                  TabBar(
                    controller: _tabController,
                    tabs: [
                      Tab(text: 'Friends'),
                      Tab(text: 'Teams'),
                      Tab(text: 'Community'),
                      Tab(text: 'Coaches'),
                    ],
                  ),
                  Container(
                    height: 300,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildFriendsList(),
                        _buildTeamsList(),
                        Center(child: Text('Community')),
                        Center(child: Text('Coaches')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendsList() {
    RandomColor _randomColor = RandomColor();
    List<Color> _friendColors =
    List.generate(userNames.length, (index) => _randomColor.randomColor());

    return ListView.builder(
      itemCount: userNames.length,
      itemBuilder: (context, index) {
        final friendName = userNames[index];
        final hasNewMessage =
            newMessages.containsKey(friendName) && newMessages[friendName] == true;

        return Column(
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundColor: _friendColors[index],
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: Text(friendName),
              trailing: hasNewMessage
                  ? Icon(Icons.circle, color: Colors.green, size: 12)
                  : null,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatDetailScreen(
                      friendName: friendName,
                    ),
                  ),
                );
              },
            ),
            Divider(
              height: 1,
              thickness: 1,
              color: Colors.grey[300],
            ),
          ],
        );
      },
    );
  }

  Widget _buildTeamsList() {
    RandomColor _randomColor = RandomColor();
    List<Color> _teamColors =
    List.generate(teamNames.length, (index) => _randomColor.randomColor());

    return ListView.builder(
      itemCount: teamNames.length,
      itemBuilder: (context, index) {
        final teamName = teamNames[index];

        return Column(
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundColor: _teamColors[index],
                child: Icon(Icons.group, color: Colors.white),
              ),
              title: Text(teamName),
              onTap: () {
                // Implement navigation to team details if needed
              },
            ),
            Divider(
              height: 1,
              thickness: 1,
              color: Colors.grey[300],
            ),
          ],
        );
      },
    );
  }
}

class ChatDetailScreen extends StatefulWidget {
  final String friendName;

  const ChatDetailScreen({Key? key, required this.friendName}) : super(key: key);

  @override
  _ChatDetailScreenState createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  List<dynamic> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        QuerySnapshot userQuerySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: currentUser.email)
            .limit(1)
            .get();

        if (userQuerySnapshot.docs.isNotEmpty) {
          DocumentSnapshot userSnapshot = userQuerySnapshot.docs.first;
          Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;

          List<dynamic> messages =
          (userData['message_with_${widget.friendName}'] ?? []) as List<dynamic>;

          setState(() {
            _messages = messages;
          });
        }
      }
    } catch (e) {
      print('Error loading messages: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.friendName}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true, // Reverse the list order
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final reversedIndex = _messages.length - 1 - index; // Compute reversed index
                final message = _messages[reversedIndex];
                final isCurrentUserMessage =
                    message['sender'] == FirebaseAuth.instance.currentUser!.email;
                final backgroundColor =
                isCurrentUserMessage ? Colors.blue[400] : Colors.grey[200];
                final textColor = isCurrentUserMessage ? Colors.white : Colors.black;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                  child: Align(
                    alignment:
                    isCurrentUserMessage ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      padding: EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${message['sender']}:', // Display sender's name
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          if (message['message'] != null &&
                              message['message'].contains('http'))
                            Image.network(
                              message['message'],
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                            )
                          else
                            Text(
                              message['message'],
                              style: TextStyle(color: textColor),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    _sendMessage();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() async {
    String message = _messageController.text.trim();
    if (message.isNotEmpty) {
      try {
        String? currentUserEmail = FirebaseAuth.instance.currentUser?.email;

        if (currentUserEmail != null) {
          QuerySnapshot currentUserQuerySnapshot = await FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: currentUserEmail)
              .limit(1)
              .get();

          if (currentUserQuerySnapshot.docs.isNotEmpty) {
            DocumentSnapshot currentUserSnapshot = currentUserQuerySnapshot.docs.first;
            String currentUserId = currentUserSnapshot.id;

            String? currentUserName = currentUserSnapshot.get('name');

            if (currentUserName != null) {
              QuerySnapshot friendQuerySnapshot = await FirebaseFirestore.instance
                  .collection('users')
                  .where('name', isEqualTo: widget.friendName)
                  .limit(1)
                  .get();

              if (friendQuerySnapshot.docs.isNotEmpty) {
                DocumentSnapshot friendSnapshot = friendQuerySnapshot.docs.first;
                String friendUserId = friendSnapshot.id;

                Map<String, dynamic> messageData = {
                  'sender': currentUserName,
                  'receiver': widget.friendName,
                  'message': message,
                  'Seen': 'no', // Added "Seen" parameter with value "yes"
                };

                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(currentUserId)
                    .update({
                  'message_with_${widget.friendName}': FieldValue.arrayUnion([messageData]),
                });

                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(friendUserId)
                    .update({
                  'message_with_$currentUserName': FieldValue.arrayUnion([messageData]),
                });

                setState(() {
                  _messages.add({'sender': currentUserName, 'message': message});
                  _messageController.clear();
                });
              } else {
                print('Friend document not found for ${widget.friendName}');
              }
            } else {
              print('Name field not found in current user document');
            }
          } else {
            print('Current user document not found');
          }
        } else {
          print('Current user email is null');
        }
      } catch (e) {
        print('Error sending message: $e');
      }
    }
  }
}