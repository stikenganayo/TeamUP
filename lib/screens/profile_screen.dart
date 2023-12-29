import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/image_list_screen.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';
import '../widgets/friends.dart'; // Import the Friends widget

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<FriendData> friends = [];

  String username = '';
  String userEmail = '';
  int totalPoints = 1000;
  int totalStreaks = 5;
  String profilePictureUrl = 'https://csncollision.com/wp-content/uploads/2019/10/placeholder-circle.png';

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
          userEmail = user.email ?? '';
          username = _extractUsername(userEmail);
          _nameController.text = username;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  String _extractUsername(String email) {
    int endIndex = email.indexOf('@');
    if (endIndex != -1) {
      return email.substring(0, endIndex);
    } else {
      return email;
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

  Future<void> _selectProfilePicture() async {
    List<String> firebaseImages = []; // Replace this with actual Firebase image URLs

    final selectedImage = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageListScreen(images: firebaseImages),
      ),
    );

    if (selectedImage != null) {
      setState(() {
        profilePictureUrl = selectedImage;
      });
    }
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
          IconButton(
            icon: const Icon(Icons.photo),
            onPressed: () {
              _selectProfilePicture();
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
              CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(profilePictureUrl),
                backgroundColor: Colors.red,
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
                  ' Teams:',
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
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  ' Friends:',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
              ),
              // Display friends using the FriendsGrid widget
              FriendsGrid(),
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