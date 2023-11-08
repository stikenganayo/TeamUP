import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> searchResults = [];

  void _searchUsers(String query) {
    FirebaseFirestore.instance
        .collection('users')
        .where('email', isGreaterThanOrEqualTo: query)
        .where('email', isLessThan: query + 'z')
        .get()
        .then((QuerySnapshot<Map<String, dynamic>> usersQuery) {
      setState(() {
        searchResults = usersQuery.docs.map((doc) => doc['email'] as String).toList();
      });
    }).catchError((error) {
      print('Firebase Search Error: $error');
    });
  }

  void _addUser(String user) {
    // Store the user in Firestore
    FirebaseFirestore.instance.collection('user_friends').add({
      'user_email': FirebaseAuth.instance.currentUser?.email,
      'friend_email': user,
    }).then((value) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$user added!')),
      );
    }).catchError((error) {
      print('Firebase Add User Error: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Friends'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _searchUsers,
              decoration: const InputDecoration(
                labelText: 'Search for users by email',
                suffixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(searchResults[index]),
                  trailing: ElevatedButton(
                    onPressed: () => _addUser(searchResults[index]),
                    child: const Text('Add'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
