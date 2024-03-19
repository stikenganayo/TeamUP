import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ImageListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memories'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('images').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final images = snapshot.data?.docs ?? [];

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            itemCount: images.length,
            itemBuilder: (context, index) {
              final imageUrl = images[index]['url'];

              return GestureDetector(
                child: Hero(
                  tag: imageUrl, // Unique tag for each image
                  child: Card(
                    margin: EdgeInsets.all(8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, widget, event) {
                          if (event == null) {
                            return widget;
                          } else {
                            return Center(child: CircularProgressIndicator());
                          }
                        },
                      ),
                    ),
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FullScreenImage(imagePath: imageUrl),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class FullScreenImage extends StatefulWidget {
  final String imagePath;

  const FullScreenImage({Key? key, required this.imagePath}) : super(key: key);

  @override
  _FullScreenImageState createState() => _FullScreenImageState();
}

class _FullScreenImageState extends State<FullScreenImage> {
  List<Map<String, dynamic>> events = [];
  late User currentUser; // Define currentUser variable

  @override
  void initState() {
    super.initState();
    _loadCurrentUser(); // Call function to load current user
    _loadCommunityEvents(); // Load community events
  }

  // Function to load current user
  Future<void> _loadCurrentUser() async {
    currentUser = FirebaseAuth.instance.currentUser!;
  }

  // Function to load current user name
  Future<String?> _loadCurrentUserName() async {
    if (currentUser != null) {
      print('Current User Email: ${currentUser.email}');
      print('Current User Doc: $currentUser');
      try {
        // Fetch the user document based on the current user's email
        QuerySnapshot userQuerySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: currentUser.email)
            .limit(1)
            .get();

        if (userQuerySnapshot.docs.isNotEmpty) {
          DocumentSnapshot userSnapshot = userQuerySnapshot.docs.first;
          Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;

          // Print all data inside the current user's document
          print('User Data: $userData');

          // Check for the 'name' field in the user data
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
    return null; // Return null if any error occurs or if user is not found
  }

  Future<void> _loadCommunityEvents() async {
    try {
      QuerySnapshot communityEventsSnapshot = await FirebaseFirestore.instance
          .collection('events')
          .where('communityEvent', isEqualTo: true)
          .get();

      List<Map<String, dynamic>> eventsList = [];

      for (DocumentSnapshot doc in communityEventsSnapshot.docs) {
        if (doc.exists) {
          String formattedDate =
          DateFormat('MMMM dd, yyyy').format(doc['startDate'].toDate());

          Map<String, dynamic> eventDetails = {
            'eventId': doc.id,
            'eventTitle': doc['eventTitle'] ?? '',
            'startDate': formattedDate,
            'startTime': doc['startTime'] ?? '',
            'eventLocation': doc['eventLocation'] ?? '',
            'CurrentUserName': doc['CurrentUserName'],
            'attending': doc['attending'] ?? 0,
            'isGoing': false,
            'background': doc['background'] ?? '',
          };
          eventsList.add(eventDetails);
        }
      }

      setState(() {
        events = eventsList;
      });
    } catch (e) {
      print('Error loading community events: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(widget.imagePath, fit: BoxFit.cover),
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.close, color: Colors.white),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              color: Colors.black.withOpacity(0.7),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildPostMenuWidget(),
                  _buildPostAddMenuWidget(),
                  IconButton(
                    onPressed: () {
                      _showSendMenu(context);
                    },
                    icon: Icon(Icons.send, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostMenuWidget() {
    return IconButton(
      onPressed: () {
        _showPostMenu(context);
      },
      icon: Icon(Icons.event, color: Colors.white),
    );
  }

  Widget _buildPostAddMenuWidget() {
    return IconButton(
      onPressed: () {
        _showPostAddMenu(context);
      },
      icon: Icon(Icons.post_add, color: Colors.white),
    );
  }

  void _showPostMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Divider(),
              Column(
                children: events.map((Map<String, dynamic> event) {
                  return ListTile(
                    leading: Icon(Icons.event),
                    title: Text('Add to ${event['eventTitle']}'),
                    onTap: () {
                      _handleEventSelection(context, event['eventTitle']);
                      Navigator.pop(context); // Close the menu
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPostAddMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.event),
                title: Text("Post to Friends Story"),
                onTap: () {
                  _sendToStory(context); // Handle post to user's story
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.event),
                title: Text("Post to Teams Story"),
                onTap: () {
                  // Handle post to teams story
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _sendToStory(BuildContext context) async {
    try {
      User currentUser = FirebaseAuth.instance.currentUser!;
      String currentUserEmail = currentUser.email!;

      // Get the current image URL
      String imageUrl = widget.imagePath;

      // Update the current user's document to add the image URL to the story
      await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: currentUserEmail)
          .limit(1)
          .get()
          .then((querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          String userId = querySnapshot.docs.first.id;
          FirebaseFirestore.instance.collection('users').doc(userId).update({
            'story': FieldValue.arrayUnion([imageUrl]), // Wrap the imageUrl in an array
          }).then((value) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Image posted to your story'),
            ));
          }).catchError((error) {
            print("Error updating document: $error");
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Failed to post to story. Please try again.'),
            ));
          });
        }
      });
    } catch (e) {
      print('Error posting to story: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to post to story. Please try again.'),
      ));
    }
  }


  void _showSendMenu(BuildContext context) async {
    List<String> userNames = [];

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

          // Load user's friends
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

                // Add the name of the friend to the list
                if (friendData.containsKey('name')) {
                  String friendName = friendData['name'] as String;
                  userNames.add(friendName);
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

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: Wrap(
            children: userNames.map((String friendName) {
              return ListTile(
                leading: Icon(Icons.send),
                title: Text('Send to $friendName'),
                onTap: () {
                  _sendMessageToFriend(context, friendName); // Modified this line
                  Navigator.pop(context); // Close the menu
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _sendMessageToFriend(BuildContext context, String friendName) async {
    String message = widget.imagePath; // Message to send to the friend

    try {
      // Get the current user's email
      String? currentUserEmail = FirebaseAuth.instance.currentUser?.email;

      if (currentUserEmail != null) {
        // Remove the "@gmail.com" part
        String currentUserEmailWithoutDomain = currentUserEmail.split('@').first;

        // Fetch the friend's document based on the friend's name
        QuerySnapshot friendQuerySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('name', isEqualTo: friendName)
            .limit(1)
            .get();

        if (friendQuerySnapshot.docs.isNotEmpty) {
          DocumentSnapshot friendSnapshot = friendQuerySnapshot.docs.first;
          String friendUserId = friendSnapshot.id;

          // Fetch the current user's document based on the current user's email
          QuerySnapshot currentUserQuerySnapshot = await FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: currentUserEmail)
              .limit(1)
              .get();

          if (currentUserQuerySnapshot.docs.isNotEmpty) {
            DocumentSnapshot currentUserSnapshot = currentUserQuerySnapshot.docs.first;
            String currentUserId = currentUserSnapshot.id;

            // Create a map representing the message data
            Map<String, dynamic> messageData = {
              'sender': currentUserEmailWithoutDomain, // Store sender's email without domain
              'message': message,
              'receiver': friendName, // Store timestamp for sorting
            };

            // Update the friend's document to add the message with the current user's name
            await FirebaseFirestore.instance
                .collection('users')
                .doc(friendUserId)
                .update({
              'message_with_${currentUserEmailWithoutDomain}': FieldValue.arrayUnion([messageData]),
            });

            // Update the current user's document to add the message with the friend's name
            await FirebaseFirestore.instance
                .collection('users')
                .doc(currentUserId)
                .update({
              'message_with_${friendName}': FieldValue.arrayUnion([messageData]),
            });

            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Message sent to $friendName'),
            ));
          } else {
            print('Current user document not found');
          }
        } else {
          print('Friend document not found for $friendName');
        }
      } else {
        print('Current user email is null');
      }
    } catch (e) {
      print('Error sending message: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to send message. Please try again.'),
      ));
    }
  }


  void _handleEventSelection(BuildContext context, String value) async {
    try {
      // Find the selected event
      Map<String, dynamic>? selectedEvent;
      for (Map<String, dynamic> event in events) {
        if (event['eventTitle'] == value) {
          selectedEvent = event;
          break;
        }
      }

      // Update the background field of the selected event in Firestore
      if (selectedEvent != null) {
        await FirebaseFirestore.instance
            .collection('events')
            .doc(selectedEvent['eventId'])
            .update({'background': widget.imagePath}); // Assuming imagePath is accessible here
        print('Background updated for event: ${selectedEvent['eventTitle']}');
      } else {
        print('Event not found');
      }
    } catch (e) {
      print('Error updating background: $e');
    }
  }

  void _sendViaEmail() {
    // Implement sending via email
    Navigator.pop(context);
  }

  void _sendViaMessage() {
    // Implement sending via message
    Navigator.pop(context);
  }
}