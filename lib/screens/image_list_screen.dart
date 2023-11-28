import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';

class ImageListScreen extends StatelessWidget {
  final List<String> images;

  const ImageListScreen({Key? key, required this.images}) : super(key: key);

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
      // Handle the error if any
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
      // Handle the error if any
      print("Error deleting image from Firebase: $e");
    }
  }

  Future<void> setAsProfilePicture(String imageUrl) async {
    // Implement logic to set the image as a profile picture
    // You can update your user's profile picture in your authentication system or wherever it is stored.
    print("Setting image as profile picture: $imageUrl");
    // Add your logic here to set the image as a profile picture
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memories'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        // Fetch timestamps and image URLs
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
                            // Show context menu for actions
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
                                    ],
                                  ),
                                );
                              },
                            );

                            // Perform the selected action
                            if (selectedAction == 'delete') {
                              // Delete image
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

                              // Delete image if user confirmed
                              if (deleteImage == true) {
                                await deleteImageFromFirebase(imageUrl);
                                // Refresh the UI by triggering a rebuild
                                // or update the state to remove the image from the list
                              }
                            } else if (selectedAction == 'setProfilePicture') {
                              // Set image as profile picture
                              await setAsProfilePicture(imageUrl);
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
                        // Invalid or failed URL, display placeholder or handle accordingly
                        return Container(); // You can replace this with a placeholder or handle it as needed
                      }
                    } else {
                      // Loading state
                      return CircularProgressIndicator();
                    }
                  },
                );
              },
            );
          } else {
            // Loading state
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
