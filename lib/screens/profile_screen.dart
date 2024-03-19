import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<FriendData> friends = [];

  String username = ''; // Set the default name
  String userEmail = ''; // Store user email
  int totalPoints = 1000;
  int totalStreaks = 5;
  String profilePictureUrl =
      'https://i.ibb.co/dpHVm2G/CLICK-HERE-TO-VIEW-STORY-3-17-2024-6.png';

  final TextEditingController _nameController = TextEditingController();

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadFriendsData();
  }

  Future<void> _loadUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        setState(() {
          username = (user.email ?? '').replaceAll('@gmail.com', '');
          userEmail = user.email ?? '';
          _nameController.text = username;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _loadFriendsData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        QuerySnapshot<Map<String, dynamic>> friendsQuery = await FirebaseFirestore.instance
            .collection('user_friends')
            .where('user_email', isEqualTo: user.email)
            .get();

        setState(() {
          friends = friendsQuery.docs.map((doc) => FriendData.fromMap(doc.data() as Map<String, dynamic>)).toList();
        });
      }
    } catch (e) {
      print('Error loading friends data: $e');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.lightBlue,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
                if (_isEditing) {
                  _nameController.text = username;
                }
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => StoryScreen()),
                  );
                },
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(1), // Adjust the color and opacity as needed
                        spreadRadius: 3,
                        blurRadius: 0,
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(profilePictureUrl),
                    backgroundColor: Colors.transparent, // You can set this to transparent if needed
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _isEditing
                  ? TextFormField(
                controller: _nameController,
                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  hintText: 'Enter your name',
                  labelText: 'Name',
                ),
              )
                  : Text(
                username,
                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                userEmail,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 10),
              Text(
                'Total Points: $totalPoints',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 10),
              Text(
                'Total Streaks: $totalStreaks',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 30),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  ' Friends:',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: friends.length,
                  itemBuilder: (context, index) {
                    return _buildFriendTile(friends[index]);
                  },
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFriendTile(FriendData friend) {
    return GestureDetector(
      onLongPress: () {
        _showRemoveFriendMenu(context, friend.friendEmail);
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.blue,
              child: Icon(
                Icons.person,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              friend.friendEmail,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  void _showRemoveFriendMenu(BuildContext context, String friendEmail) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              title: Text(
                'Remove Friend',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                _removeFriend(friendEmail);
              },
            ),
          ],
        );
      },
    );
  }

  void _removeFriend(String friendEmail) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('user_friends')
            .where('user_email', isEqualTo: user.email)
            .where('friend_email', isEqualTo: friendEmail)
            .get()
            .then((QuerySnapshot<Map<String, dynamic>> snapshot) {
          snapshot.docs.forEach((doc) {
            doc.reference.delete();
          });
        });

        _loadFriendsData();
      }
    } catch (e) {
      print('Error removing friend: $e');
    }
  }
}

class FriendData {
  final String friendEmail;

  FriendData({
    required this.friendEmail,
  });

  factory FriendData.fromMap(Map<String, dynamic> map) {
    return FriendData(
      friendEmail: map['friend_email'] ?? '',
    );
  }
}

class StoryScreen extends StatefulWidget {
  @override
  _StoryScreenState createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  List<String>? storyImageUrls;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadStory();
  }

  Future<void> _loadStory() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: user.email)
            .get()
            .then((querySnapshot) => querySnapshot.docs.first);

        if (userDoc.exists) {
          setState(() {
            storyImageUrls = List<String>.from(userDoc.get('story'));
          });
        }
      }
    } catch (e) {
      print('Error loading user story: $e');
    }
  }

  void _printUid() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      print('User Email: ${user.email}');
    } else {
      print('User not signed in');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          setState(() {
            if (currentIndex < (storyImageUrls!.length - 1)) {
              currentIndex++;
            }
          });
        },
        child: Stack(
          children: [
            if (storyImageUrls != null && storyImageUrls!.isNotEmpty)
              PageView.builder(
                itemCount: storyImageUrls!.length,
                controller: PageController(initialPage: currentIndex),
                onPageChanged: (index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return Container(
                    width: double.infinity,
                    height: double.infinity,
                    child: Image.network(
                      storyImageUrls![index],
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(child: CircularProgressIndicator());
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Center(child: Text('Error loading image'));
                      },
                    ),
                  );
                },
              ),
            Positioned(
              top: 20.0,
              left: 20.0,
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ProfileScreen(),
  ));
}