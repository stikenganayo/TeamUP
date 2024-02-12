import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../screens/image_list_screen.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';
import '../widgets/friends.dart'; // Import the Friends widget

//
//
//
// Future<Map<String, int>> _displayUserPoints(String userName) async {
//   try {
//
//
//     // Get the challenges collection reference
//     CollectionReference challengesCollection = FirebaseFirestore.instance.collection('challenges');
//
//     // Fetch documents from the challenges collection
//     QuerySnapshot challengesSnapshot = await challengesCollection.where('challengeDataList', arrayContains: {'challengeTitle': currentChallenge}).get();
//
//     // Get the current date in the desired format
//     DateTime currentDate = DateTime.now();
//     String formattedDate = DateFormat('MMMM dd, yyyy').format(currentDate);
//
//     int countOfArraysForCurrentDate = 0;
//     int countOfArraysForConsistencyDates = 0;
//     int countOfArraysForDifferentDate = 0;
//     int userTyping = 0;
//     int challengeType = 0;
//
//     // Iterate through the documents and display confirmation message
//     challengesSnapshot.docs.forEach((challengeDoc) {
//       Map<String, dynamic> challengeData = challengeDoc.data() as Map<String, dynamic>;
//
//       // Assuming userLoggedIn_stats is an array
//       List<dynamic> userLoggedInStats = challengeData['${userName}_stats'] ?? [];
//
//       // Count the number of arrays with the current date and 'confirmed_completion'
//       countOfArraysForCurrentDate += userLoggedInStats.where((statsElement) =>
//       statsElement['date'] == formattedDate &&
//           statsElement.containsKey('confirmed_completion') &&
//           (statsElement['confirmed_completion'] as List).isNotEmpty,
//       ).length;
//
//
//       // Count all arrays
//       countOfArraysForDifferentDate += userLoggedInStats.length;
//
//       // Create a Set to store unique dates
//       Set<String> uniqueDatesInChallenge = Set<String>();
//
//       // Iterate through userLoggedInStats to add unique dates
//       userLoggedInStats.forEach((statsElement) {
//         String date = statsElement['date'];
//
//         // Check if the date is not in uniqueDatesInChallenge
//         if (!uniqueDatesInChallenge.contains(date)) {
//           uniqueDatesInChallenge.add(date);
//         } else {
//           // Subtract 1 for each duplicate date
//           countOfArraysForDifferentDate--;
//         }
//       });
//
//       // Count the number of arrays for consistency dates
//       DateTime loopDate = currentDate; // Create a separate variable for the loop
//       bool foundMatchingDate = userLoggedInStats.any((statsElement) => statsElement['date'] == DateFormat('MMMM dd, yyyy').format(loopDate));
//
//       if (!foundMatchingDate) {
//         // Subtract one day if no match for the current date
//         loopDate = loopDate.subtract(Duration(days: 1));
//       }
//
//       while (userLoggedInStats.any((statsElement) => statsElement['date'] == DateFormat('MMMM dd, yyyy').format(loopDate))) {
//         countOfArraysForConsistencyDates++;
//         loopDate = loopDate.subtract(Duration(days: 1));
//       }
//
//       // Debugging statements
//       print('Challenge data: $challengeData');
//       print('User Typing field: ${challengeData['userTyping']}');
//       print('Challenge Type: ${challengeData['challengeType']}');
//
// // Assuming userTyping is a boolean field
//       userTyping = challengeData['userTyping'] == 'true' ? 1 : 0;
//       print('User Typing for $userName: $userTyping');
//
//       challengeType = challengeData['challengeType'] == 'Challenge yourself - get your teammates to verify' ? 1 : (challengeData['challengeType'] == 'Challenge your teammates - you verify' ? 2 : 0);
//
//       print(challengeType);
//
//
//     });
//
//     print('Is user typing enabled for $userName: $userTyping');
//     print('Teammates who verified $userName: $countOfArraysForCurrentDate');
//     print('Total points for $userName: $countOfArraysForDifferentDate');
//     print('Current Streak for $userName: $countOfArraysForConsistencyDates');
//
//     Map<String, int> result = {
//       'countOfArraysForCurrentDate': countOfArraysForCurrentDate,
//       'countOfArraysForDifferentDate': countOfArraysForDifferentDate,
//       'countOfArraysForConsistencyDates': countOfArraysForConsistencyDates,
//       'userTyping': userTyping,
//       'challengeType': challengeType,
//     };
//
//     return result;
//   } catch (e) {
//     // Handle exceptions here, if needed
//     print('Error in _displayUserPoints: $e');
//     return {'countOfArraysForCurrentDate': 0, 'countOfArraysForDifferentDate': 0, 'countOfArraysForConsistencyDates': 0, 'adjustedUserCount': 0, 'userTyping': 0, 'challengeType': 0}; // Return default values or handle the error accordingly
//   }
// }












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

  // Future<void> _selectProfilePicture() async {
  //   List<String> firebaseImages = []; // Replace this with actual Firebase image URLs
  //
  //   final selectedImage = await Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => ImageListScreen(images: firebaseImages),
  //     ),
  //   );
  //
  //   if (selectedImage != null) {
  //     setState(() {
  //       profilePictureUrl = selectedImage;
  //     });
  //   }
  // }

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
              //_selectProfilePicture();
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