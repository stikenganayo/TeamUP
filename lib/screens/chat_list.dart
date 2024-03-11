import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
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
            Timestamp aTime = a['dateTime'];
            Timestamp bTime = b['dateTime'];
            return bTime.compareTo(aTime);
          });

          return combinedList;
        });
  }

  Future<void> _sendCurrentChallenges(String receiverUid) async {
    DocumentSnapshot userSnapshot = await _firestore.collection('users').doc(_currentUser.uid).get();
    if (userSnapshot.exists) {
      Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
      if (userData.containsKey('teamId')) {
        String teamId = userData['teamId'];
        List<String> challengeTitles = await _getChallengeTitles(teamId);
        if (challengeTitles.isNotEmpty) {
          String challengesMessage = "Current Challenges:\n" + challengeTitles.join("\n");
          await _firestore.collection('messages').add({
            'text': challengesMessage,
            'dateTime': FieldValue.serverTimestamp(),
            'senderUid': _currentUser.uid,
            'receiverUid': receiverUid,
            'senderEmail': _currentUser.email,
          });
        } else {
          print('No challenges found for the team.');
        }
      } else {
        print('Team ID not found in user document.');
      }
    } else {
      print('User document not found.');
    }
  }

  Future<List<String>> _getChallengeTitles(String teamId) async {
    try {
      DocumentSnapshot teamSnapshot = await FirebaseFirestore.instance
          .collection('teams')
          .doc(teamId)
          .get();

      if (teamSnapshot.exists) {
        Map<String, dynamic> teamData = teamSnapshot.data() as Map<String, dynamic>;

        if (teamData.containsKey('team_challenges')) {
          List<dynamic> teamChallenges = teamData['team_challenges'];

          List<String> challengeTitles = [];
          for (var challenge in teamChallenges) {
            if (challenge.containsKey('template_name') &&
                challenge['template_name'].isNotEmpty &&
                challenge['template_name'][0].containsKey('challengeTitle')) {
              String challengeTitle = challenge['template_name'][0]['challengeTitle'];
              challengeTitles.add(challengeTitle);
            }
          }

          return challengeTitles;
        } else {
          print('Team challenges field not found in team document');
        }
      } else {
        print('Team document not found for $teamId');
      }
    } catch (e) {
      print('Error loading team or challenge document: $e');
    }

    return []; // Default value if anything goes wrong
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: getReceiverUid(widget.friendName),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || snapshot.data == null) {
          return const Text('Error fetching friend UID');
        }

        final friendUid = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.friendName),
            actions: [
              TextButton(
                onPressed: () async {
                  // Send current challenges when this button is pressed
                  await _sendCurrentChallenges(friendUid);
                },
                child: Text(
                  'Send Current Challenges',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                    EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  ),
                  shape: MaterialStateProperty.all<OutlinedBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: BorderSide(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: Container(
            color: Colors.grey[200],
            child: Column(
              children: [
                Expanded(
                  child: StreamBuilder<List<QueryDocumentSnapshot>>(
                    stream: getMessages(_currentUser.uid, friendUid),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text("Error: ${snapshot.error}");
                      }

                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      final allMessages = snapshot.data!;

                      return ListView.builder(
                        reverse: true,
                        itemCount: allMessages.length,
                        itemBuilder: (context, index) {
                          final message = allMessages[index];
                          final messageText = message['text'];
                          final isMe = message['senderUid'] == _currentUser.uid;

                          return MessageItem(
                            text: messageText,
                            isMe: isMe,
                            friendName: widget.friendName,
                            isReceivedMessage: !isMe,
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
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: TextField(
                              controller: _messageController,
                              focusNode: _focusNode,
                              decoration: const InputDecoration(
                                hintText: 'Type a message...',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Material(
                        borderRadius: BorderRadius.circular(30.0),
                        color: Colors.blue,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(30.0),
                          onTap: () {
                            _sendMessage(friendUid);
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Icon(
                              Icons.send,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
}

class MessageItem extends StatelessWidget {
  final String text;
  final bool isMe;
  final String friendName;
  final bool isReceivedMessage;

  const MessageItem({
    Key? key,
    required this.text,
    required this.isMe,
    required this.friendName,
    required this.isReceivedMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: isReceivedMessage ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Text(
            isReceivedMessage ? friendName : 'Me',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isReceivedMessage ? Colors.blue : Colors.black,
            ),
          ),
          Material(
            color: isReceivedMessage ? Colors.white : Colors.blue,
            borderRadius: BorderRadius.circular(8.0),
            elevation: 3.0,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                text,
                style: TextStyle(
                  color: isReceivedMessage ? Colors.black : Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}