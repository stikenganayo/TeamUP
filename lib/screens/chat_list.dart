import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:async/async.dart';
import 'package:rxdart/rxdart.dart';

class ChatScreen extends StatefulWidget {
  final String friendName;

  const ChatScreen({Key? key, required this.friendName, required String friendEmail}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late FocusNode _focusNode;
  late User _currentUser;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _currentUser = FirebaseAuth.instance.currentUser!;
    _loadCurrentUser();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _loadCurrentUser() async {
    try {
      QuerySnapshot userQuerySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: _currentUser.email)
          .limit(1)
          .get();

      if (userQuerySnapshot.docs.isNotEmpty) {
        DocumentSnapshot userSnapshot = userQuerySnapshot.docs.first;
        Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;

        print('User Data: $userData');
      } else {
        print('User document not found for the current user');
      }
    } catch (e) {
      print('Error loading user document: $e');
    }
  }

  void _sendMessage(String receiverUid) async {
    final messageText = _messageController.text;
    if (messageText.isNotEmpty) {
      await _firestore.collection('messages').add({
        'text': messageText,
        'dateTime': FieldValue.serverTimestamp(),
        'senderUid': _currentUser.uid,
        'receiverUid': receiverUid,
        'senderEmail': _currentUser.email,
      });
      _messageController.clear();
    }
  }

  Stream<List<QueryDocumentSnapshot>> getMessages(String currentUserUid, String friendUid) {
    var sentMessagesStream = _firestore
        .collection('messages')
        .where('senderUid', isEqualTo: currentUserUid)
        .where('receiverUid', isEqualTo: friendUid)
        .orderBy('dateTime', descending: true)
        .snapshots();

    var receivedMessagesStream = _firestore
        .collection('messages')
        .where('senderUid', isEqualTo: friendUid)
        .where('receiverUid', isEqualTo: currentUserUid)
        .orderBy('dateTime', descending: true)
        .snapshots();

    return Rx.combineLatest2(sentMessagesStream, receivedMessagesStream,
            (QuerySnapshot sentSnapshot, QuerySnapshot receivedSnapshot) {
          List<QueryDocumentSnapshot> combinedList = [];

          combinedList.addAll(sentSnapshot.docs);
          combinedList.addAll(receivedSnapshot.docs);

          combinedList.sort((a, b) {
            Timestamp aTime = a['dateTime'] ?? Timestamp.now();
            Timestamp bTime = b['dateTime'] ?? Timestamp.now();
            return bTime.compareTo(aTime);
          });

          return combinedList;
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: getReceiverUid(widget.friendName),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || snapshot.data == null) {
          return Text('Error fetching friend UID');
        }

        final friendUid = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.friendName),
          ),
          body: Column(
            children: [
              Expanded(
                child: StreamBuilder<List<QueryDocumentSnapshot>>(
                  stream: getMessages(_currentUser.uid, friendUid),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      print("Error: ${snapshot.error}");
                      return Text("Error: ${snapshot.error}");
                    }

                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    final allMessages = snapshot.data!;

                    List<MessageItem> messageWidgets = [];
                    for (var message in allMessages) {
                      final messageText = message['text'];
                      final isMe = message['senderUid'] == _currentUser.uid;

                      final messageWidget = MessageItem(text: messageText, isMe: isMe, friendName: widget.friendName);
                      messageWidgets.add(messageWidget);
                    }

                    return ListView(
                      reverse: true,
                      children: messageWidgets,
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
                        focusNode: _focusNode,
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    ElevatedButton(
                      onPressed: () async {
                        String? receiverUid = await getReceiverUid(widget.friendName);
                        if (receiverUid != null) {
                          _sendMessage(receiverUid);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: Receiver UID not found')),
                          );
                        }
                      },
                      child: const Text('Send'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class MessageItem extends StatelessWidget {
  final String text;
  final bool isMe;
  final String friendName;

  const MessageItem({
    Key? key,
    required this.text,
    required this.isMe,
    required this.friendName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            isMe ? 'Me' : friendName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isMe ? Colors.blue : Colors.black,
            ),
          ),
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

Future<String?> getReceiverUid(String receiverName) async {
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('users')
      .where('name', isEqualTo: receiverName)
      .get();

  if (querySnapshot.docs.isNotEmpty) {
    return querySnapshot.docs.first.id;
  }

  return null;
}