import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'create_team_page.dart';

class SearchScreen extends StatelessWidget {
  final int initialTabIndex;

  const SearchScreen({Key? key, this.initialTabIndex = 0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: initialTabIndex,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Search Screen'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Add Friends'),
              Tab(text: 'Create Team'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            SearchContent(),
            CreateTeam(),
          ],
        ),
      ),
    );
  }
}



class SearchContent extends StatefulWidget {
  const SearchContent({Key? key}) : super(key: key);

  @override
  _SearchContentState createState() => _SearchContentState();
}

class _SearchContentState extends State<SearchContent> {
  final TextEditingController _searchController = TextEditingController();
  List<String> searchResults = [];
  Set<String> pendingRequests = Set();

  Future<String?> getSenderUid(String senderName) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('name', isEqualTo: senderName)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs[0].id; // Assuming name is unique
    }
    return null;
  }

  void _searchUsers(String query) {
    // Fetch user data from Firestore based on the query
    FirebaseFirestore.instance
        .collection('users')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThan: query + 'z')
        .get()
        .then((QuerySnapshot querySnapshot) {
      setState(() {
        searchResults = querySnapshot.docs
            .map((doc) => doc['name'] as String)
            .toList();
      });
    });
  }

  Future<void> _addUser(String user) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      String currentUserId = currentUser.uid;
      String currentUserName = currentUser.displayName ?? "Unknown User";
      String? currentEmail = currentUser.email;

      // Fetch the receiver's UID based on their name
      String? receiverUid = await getReceiverUid(user);

      if (receiverUid != null) {
        // Store the friend request in Firestore
        DocumentReference friendRequestRef = await FirebaseFirestore.instance.collection('friend_requests').add({
          'senderUid': currentUserId,
          'receiverUid': receiverUid,
          'message': 'Pending friend request from $currentUserName',
          'senderEmail': currentEmail,
        });

        // Update the receiver's document with the new friend request reference
        await FirebaseFirestore.instance.collection('users').doc(receiverUid).update({
          'friends_requested': FieldValue.arrayUnion([friendRequestRef.id]),
          // No need to update the email field here
        });

        setState(() {
          pendingRequests.add(user);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Request to $user sent!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not found. Unable to send a request.')),
        );
      }
    }
  }

  Future<String?> getReceiverUid(String receiverName) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('name', isEqualTo: receiverName)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.id; // Assuming 'id' holds the UID in the 'users' collection
    }

    return null; // If user with the provided name is not found
  }

  Widget _buildFriendRequestsSection() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return SizedBox(); // Return an empty widget if no user is logged in.
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').where('email', isEqualTo: currentUser.email).snapshots(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (!userSnapshot.hasData || userSnapshot.data == null || userSnapshot.data!.docs.isEmpty) {
          return Text('No user found with this email');
        }

        final userData = userSnapshot.data!.docs.first.data() as Map<String, dynamic>;

        if (!userData.containsKey('friends_requested')) {
          return Text('No friends_requested field found');
        }

        final friendsRequested = userData['friends_requested'] as List<dynamic>;

        if (friendsRequested.isNotEmpty) {
          return Column(
            children: friendsRequested.map<Widget>((friendRequestId) {
              return StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance.collection('friend_requests').doc(friendRequestId).snapshots(),
                builder: (context, requestSnapshot) {
                  if (requestSnapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }

                  if (!requestSnapshot.hasData || requestSnapshot.data == null || !requestSnapshot.data!.exists) {
                    return Text('Friend request data not found');
                  }

                  final request = requestSnapshot.data!.data() as Map<String, dynamic>?;

                  if (request == null || !request.containsKey('senderEmail')) {
                    return Text('No senderEmail found in friend request data');
                  }

                  final senderEmail = request['senderEmail'] as String?;
                  if (senderEmail != null) {
                    return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('users').where('email', isEqualTo: senderEmail).snapshots(),
                      builder: (context, userSnapshot) {
                        if (userSnapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }

                        if (!userSnapshot.hasData || userSnapshot.data == null || userSnapshot.data!.docs.isEmpty) {
                          return Text('No user found with this email');
                        }

                        final userData = userSnapshot.data!.docs.first.data() as Map<String, dynamic>;

                        if (userData.containsKey('name')) {
                          final senderName = userData['name'] as String;
                          return Container(
                            padding: EdgeInsets.all(5),
                            margin: EdgeInsets.all(0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Row(
                              children: [
                                SizedBox(width: 15),
                                Expanded(
                                  child: Text(
                                    ('$senderName'),
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                                Spacer(),
                                ElevatedButton(
                                  onPressed: () {
                                    // You need to define the indexToRemove based on the user action
                                    int indexToRemove = 0; // Replace with the actual index value
                                    acceptFriendRequestAndAddToFriends(senderEmail, indexToRemove);
                                  },
                                  child: Text('Accept'),
                                ),
                                SizedBox(width: 20),
                                ElevatedButton(
                                  onPressed: () {
                                    // Decline friend request logic
                                    // Add your logic for declining the request
                                  },
                                  child: Text('Decline'),
                                ),
                              ],
                            ),
                          );
                        } else {
                          return Text('Name not found for this user');
                        }
                      },
                    );
                  } else {
                    return Text('Sender Email not available');
                  }
                },
              );
            }).toList(),
          );
        } else {
          return Text('No friends_requested data found for this user');
        }
      },
    );
  }

  void acceptFriendRequestAndAddToFriends(String senderEmail, int indexToRemove) {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      String currentUserEmail = currentUser.email ?? '';
      CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');

      // Fetch the current user's document
      usersCollection.where('email', isEqualTo: currentUserEmail).get().then((querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          String currentUserId = querySnapshot.docs.first.id;

          // Update the current user's 'friends' array
          usersCollection.doc(currentUserId).update({
            'friends': FieldValue.arrayUnion([senderEmail]),
          }).then((_) {
            print('Added $senderEmail to the current user\'s friends list');

            // Remove the friend request from friends_requested array by index
            deleteFriendRequest(senderEmail, indexToRemove);

            // Fetch the sender's document and update their 'friends' array
            usersCollection.where('email', isEqualTo: senderEmail).get().then((senderQuerySnapshot) {
              if (senderQuerySnapshot.docs.isNotEmpty) {
                String senderUserId = senderQuerySnapshot.docs.first.id;
                usersCollection.doc(senderUserId).update({
                  'friends': FieldValue.arrayUnion([currentUserEmail]),
                }).then((_) {
                  print('Added $currentUserEmail to the sender\'s friends list');
                }).catchError((error) {
                  print('Error updating sender\'s friends array: $error');
                });
              } else {
                print('Sender user not found in the database');
              }
            }).catchError((error) {
              print('Error fetching sender user\'s document: $error');
            });
          }).catchError((error) {
            print('Error updating friends array: $error');
          });
        } else {
          print('Current user not found in the database');
        }
      }).catchError((error) {
        print('Error fetching current user\'s document: $error');
      });
    }
  }

  void deleteFriendRequest(String senderEmail, int indexToRemove) {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      String currentUserEmail = currentUser.email ?? '';
      CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');

      usersCollection.where('email', isEqualTo: currentUserEmail).get().then((querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          String currentUserId = querySnapshot.docs.first.id;

          usersCollection.doc(currentUserId).get().then((doc) {
            Map<String, dynamic>? userData = doc.data() as Map<String, dynamic>?;

            if (userData != null && userData.containsKey('friends_requested')) {
              List<dynamic> friendsRequested = List.from(userData['friends_requested']);

              if (indexToRemove >= 0 && indexToRemove < friendsRequested.length) {
                String friendRequestIdToRemove = friendsRequested[indexToRemove];

                friendsRequested.removeAt(indexToRemove);

                usersCollection.doc(currentUserId).update({'friends_requested': friendsRequested}).then((_) {
                  print('Removed friend request at index $indexToRemove');

                  // Remove the corresponding data from 'friend_requests' using the ID
                  FirebaseFirestore.instance.collection('friend_requests').doc(friendRequestIdToRemove).delete().then((_) {
                    print('Removed friend request data with ID: $friendRequestIdToRemove');
                  }).catchError((error) {
                    print('Error deleting friend request data: $error');
                  });
                }).catchError((error) {
                  print('Error updating friends_requested: $error');
                });
              }
            }
          });
        } else {
          print('Current user not found in the database');
        }
      }).catchError((error) {
        print('Error fetching current user\'s document: $error');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            onChanged: (query) => _searchUsers(query),
            decoration: const InputDecoration(
              labelText: 'Search for usernames',
              suffixIcon: Icon(Icons.search),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: searchResults.length,
            itemBuilder: (context, index) {
              final user = searchResults[index];
              final isPending = pendingRequests.contains(user);

              return ListTile(
                title: Text(user),
                trailing: ElevatedButton(
                  onPressed: () => _addUser(user),
                  child: Text(isPending ? 'Pending' : 'Add'),
                  style: ElevatedButton.styleFrom(
                    primary: isPending ? Colors.grey : null,
                  ),
                ),
              );
            },
          ),
        ),
        _buildFriendRequestsSection(),
      ],
    );
  }
}
