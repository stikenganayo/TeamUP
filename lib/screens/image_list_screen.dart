import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ImageListScreen extends StatelessWidget {
  final List<String> images;

  ImageListScreen({Key? key, required this.images}) : super(key: key);

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> getReceiverUid(String receiverEmail) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: receiverEmail)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.id; // Assuming 'id' holds the UID in the 'users' collection
    }

    return null; // If user with the provided email is not found
  }

  Future<bool> isImageAvailable(String imageUrl) async {
    try {
      final response = await http.head(Uri.parse(imageUrl));
      return response.statusCode == HttpStatus.ok;
    } catch (e) {
      return false;
    }
  }

  Future<DateTime?> getLastModifiedFromFirebase(String imageUrl) async {
    try {
      final Reference reference = FirebaseStorage.instance.refFromURL(imageUrl);
      final FullMetadata metadata = await reference.getMetadata();
      return metadata.updated;
    } catch (e) {
      print("Error fetching last modified timestamp: $e");
      return null;
    }
  }

  String formatTimestamp(DateTime? timestamp) {
    if (timestamp == null) return '';
    return '${timestamp.year}-${timestamp.month}-${timestamp.day} ${timestamp.hour}:${timestamp.minute}:${timestamp.second}';
  }

  Future<void> deleteImageFromFirebase(String imageUrl) async {
    try {
      final Reference reference = FirebaseStorage.instance.refFromURL(imageUrl);
      await reference.delete();
    } catch (e) {
      print("Error deleting image from Firebase: $e");
    }
  }

  Future<void> setAsProfilePicture(String imageUrl) async {
    print("Setting image as profile picture: $imageUrl");
    // Add your logic here to set the image as a profile picture
  }

  Future<void> postToJoshStory(String imageUrl) async {
    try {
      // Replace 'josh@gmail.com' with Josh's actual email
      String joshEmail = 'josh@gmail.com';

      // Fetch Josh's UID based on his email
      String? joshUid = await getReceiverUid(joshEmail);

      if (joshUid != null) {
        // Update Josh's document in the 'story' collection with the new image URL
        await _firestore.collection('story').doc(joshUid).update({
          'imageUrls': FieldValue.arrayUnion([imageUrl]),
        });
      } else {
        print('Josh not found. Unable to post image to his story.');
      }
    } catch (e) {
      print("Error posting image to Josh's story: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memories'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: Future.wait(images.map((imageUrl) async {
          final timestamp = await getLastModifiedFromFirebase(imageUrl);
          return {'imageUrl': imageUrl, 'timestamp': timestamp};
        })),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            final sortedImages = snapshot.data!
              ..sort((a, b) {
                final DateTime timestampA = a['timestamp'] ?? DateTime.now();
                final DateTime timestampB = b['timestamp'] ?? DateTime.now();
                return timestampB.compareTo(timestampA);
              });

            return ListView.builder(
              itemCount: sortedImages.length,
              itemBuilder: (context, index) {
                final imageUrl = sortedImages[index]['imageUrl'];
                final timestamp = sortedImages[index]['timestamp'];

                return FutureBuilder<bool>(
                  future: isImageAvailable(imageUrl),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.data == true) {
                        return GestureDetector(
                          onLongPress: () async {
                            final String? selectedAction = await showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text('Select Action'),
                                  content: Column(
                                    children: [
                                      ListTile(
                                        title: Text('Delete Image'),
                                        onTap: () => Navigator.of(context).pop('delete'),
                                      ),
                                      ListTile(
                                        title: Text('Set as Profile Picture'),
                                        onTap: () => Navigator.of(context).pop('setProfilePicture'),
                                      ),
                                      ListTile(
                                        title: Text('Post to Josh\'s Story'),
                                        onTap: () => Navigator.of(context).pop('postToStory'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );

                            if (selectedAction == 'delete') {
                              final bool deleteImage = await showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text('Delete Image?'),
                                    content: Text('Do you want to delete this image?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(false),
                                        child: Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(true),
                                        child: Text('Delete'),
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (deleteImage == true) {
                                await deleteImageFromFirebase(imageUrl);
                              }
                            } else if (selectedAction == 'setProfilePicture') {
                              await setAsProfilePicture(imageUrl);
                            } else if (selectedAction == 'postToStory') {
                              await postToJoshStory(imageUrl);
                            }
                          },
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  formatTimestamp(timestamp),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              ListTile(
                                title: Image.network(imageUrl),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return Container();
                      }
                    } else {
                      return CircularProgressIndicator();
                    }
                  },
                );
              },
            );
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
