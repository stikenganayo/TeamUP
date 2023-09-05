import 'package:flutter/material.dart';
import 'image_list_screen.dart'; // Import the ImageListScreen

class ChatScreen extends StatefulWidget {
  final String friendName;

  const ChatScreen({Key? key, required this.friendName}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
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

  void _openImageListScreen() {
    // Navigate to the ImageListScreen when the camera icon is clicked
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ImageListScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.friendName),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (BuildContext context, int index) {
                final message = _messages[index];
                return MessageItem(
                  text: message['text'],
                  isMe: message['isMe'],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _openImageListScreen, // Call the function when the camera icon is clicked
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.camera_alt), // Camera icon
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    focusNode: _focusNode, // Set the focus node
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: () {
                    _sendMessage();
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

  void _sendMessage() {
    final messageText = _messageController.text;
    if (messageText.isNotEmpty) {
      setState(() {
        final now = DateTime.now();
        _messages.add({
          'text': messageText,
          'isMe': true,
          'dateTime': now,
        });
        _messageController.clear();
      });
    }
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
          if (isMe)
            const Text(
              'Me',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue, // Customize text color for "Me"
              ),
            ),
          Container(
            decoration: BoxDecoration(
              color: isMe ? Colors.blue : Colors.grey[300], // Blue for "Me," Grey for others
              borderRadius: BorderRadius.circular(8.0), // Rounded corners
            ),
            padding: const EdgeInsets.all(8.0),
            child: Text(
              text,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black, // Customize text color
              ),
            ),
          ),
        ],
      ),
    );
  }
}
