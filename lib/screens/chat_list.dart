import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'image_list_screen.dart'; // Import the ImageListScreen

class ChatScreen extends StatefulWidget {
  final String friendName;

  const ChatScreen({Key? key, required this.friendName}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    // Set focus on the TextField when the screen loads
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  String getConversationId(String userId, String friendId) {
    List<String> ids = [userId, friendId];
    ids.sort(); // Sort IDs to ensure consistency
    return ids.join('_'); // Concatenate sorted IDs with underscore
  }

  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      // Redirect to login screen if the user is not logged in
      return CircularProgressIndicator();
    }

    final String userId = currentUser.uid;
    final String friendId = widget.friendName; // Replace with the actual friend's ID

    final String conversationId = getConversationId(userId, friendId);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.friendName),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('conversations')
                  .doc(conversationId)
                  .collection('messages')
                  .orderBy('dateTime')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                if (!snapshot.hasData ||
                    snapshot.data == null ||
                    snapshot.data!.docs.isEmpty) {
                  return Text('No messages found');
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (BuildContext context, int index) {
                    final message = messages[index].data() as Map<String, dynamic>;
                    return MessageItem(
                      text: message['text'],
                      isMe: message['isMe'],
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _openImageListScreen,
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.camera_alt),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    focusNode: _focusNode,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: () {
                    _sendMessage(userId, friendId, conversationId);
                  },
                  child: const Text('Send'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage(String userId, String friendId, String conversationId) {
    final messageText = _messageController.text;
    if (messageText.isNotEmpty) {
      final now = DateTime.now();

      FirebaseFirestore.instance
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .add({
        'text': messageText,
        'isMe': true,
        'dateTime': now,
      });

      // If you want to notify the other user, you can send a push notification or update their conversation
      // FirebaseFirestore.instance.collection('conversations').doc(conversationId).update({
      //   'hasUnreadMessages': true,
      // });

      // Add the message to the recipient's conversation as well
      FirebaseFirestore.instance
          .collection('conversations')
          .doc(getConversationId(friendId, userId))
          .collection('messages')
          .add({
        'text': messageText,
        'isMe': false,
        'dateTime': now,
      });

      setState(() {
        _messageController.clear();
      });
    }
  }

  void _openImageListScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ImageListScreen(images: [],),
      ),
    );
  }
}

class MessageItem extends StatelessWidget {
  final String text;
  final bool isMe;

  const MessageItem({
    Key? key,
    required this.text,
    required this.isMe,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: isMe ? Colors.blue : Colors.grey[300],
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.all(8.0),
            child: Text(
              text,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

