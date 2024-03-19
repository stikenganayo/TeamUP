import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

class _ChatScreenState extends State<ChatScreen> {
  late User? currentUser;
  List<String> userNames = []; // List to store user names

  @override
  void initState() {
    super.initState();
    _loadCurrentUserFriends();
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
          Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;

          if (userData.containsKey('friends')) {
            List<dynamic> friends = userData['friends'];

            for (String friendEmail in friends) {
              QuerySnapshot friendQuerySnapshot = await FirebaseFirestore.instance
                  .collection('users')
                  .where('email', isEqualTo: friendEmail)
                  .limit(1)
                  .get();

              if (friendQuerySnapshot.docs.isNotEmpty) {
                DocumentSnapshot friendSnapshot = friendQuerySnapshot.docs.first;
                Map<String, dynamic> friendData = friendSnapshot.data() as Map<String, dynamic>;

                if (friendData.containsKey('name')) {
                  String friendName = friendData['name'] as String;
                  setState(() {
                    userNames.add(friendName);
                  });
                } else {
                  print('Name field not found for friend with email: $friendEmail');
                }
              } else {
                print('User document not found for friend with email: $friendEmail');
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
          Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;

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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Style.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          const TopBar(isCameraPage: false, text: 'Friends'),
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
                  Style.sectionTitle('Friend Stories'),
                  const Stories(),
                  const SizedBox(height: 28),
                  Style.sectionTitle('Friends'),
                  SizedBox(
                    height: 300,
                    child: ListView.builder(
                      itemCount: userNames.isNotEmpty ? userNames.length * 2 - 1 : 0,
                      itemBuilder: (context, index) {
                        if (index.isOdd) {
                          return Divider(
                            height: 1,
                            thickness: 1,
                            color: Colors.grey[300],
                          );
                        }
                        final userNameIndex = index ~/ 2;
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatDetailScreen(
                                  friendName: userNames[userNameIndex],
                                ),
                              ),
                            );
                          },
                          child: ListTile(
                            title: Text(userNames[userNameIndex]),
                          ),
                        );
                      },
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
      String? currentUserEmail = FirebaseAuth.instance.currentUser?.email;

      if (currentUserEmail != null) {
        QuerySnapshot userQuerySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: currentUserEmail)
            .limit(1)
            .get();

        if (userQuerySnapshot.docs.isNotEmpty) {
          DocumentSnapshot userSnapshot = userQuerySnapshot.docs.first;

          List<dynamic> messages = (userSnapshot.data() as Map<String, dynamic>?)?['message_with_${widget.friendName}'] ?? [];

          setState(() {
            _messages = messages;
          });
        } else {
          print('User document not found for the current user');
        }
      } else {
        print('Current user email is null');
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
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isCurrentUserMessage = message['sender'] == FirebaseAuth.instance.currentUser!.email;
                final backgroundColor = isCurrentUserMessage ? Colors.blue[400] : Colors.grey[200];
                final textColor = isCurrentUserMessage ? Colors.white : Colors.black;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                  child: Align(
                    alignment: isCurrentUserMessage ? Alignment.centerRight : Alignment.centerLeft,
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
                          if (message['message'] != null && message['message'].contains('http'))
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