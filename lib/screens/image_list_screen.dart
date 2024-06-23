import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import '../screens/share_image_screen.dart';

class ImageListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Your Memories'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Pictures'),
              Tab(text: 'Challenges'),
              Tab(text: 'Events'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildImagesList(context), // Memories tab
            _buildChallengesSection(), // Challenges tab
            _buildEventsSection(), // Events tab
          ],
        ),
      ),
    );
  }

  Widget _buildImagesList(BuildContext context) {
    return StreamBuilder(
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
                tag: imageUrl,
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
              onLongPress: () {
                _showDeleteDialog(context, images[index].id);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildChallengesSection() {
    return ListView(
      children: [
        _buildSectionHeader('Past Challenges'),
        _buildChallengeCard('Planting garden', 'Completed on 2024-01-15'),
        _buildChallengeCard('Painting', 'Completed on 2024-05-20'),
        _buildSectionHeader('Present Challenges'),
        _buildChallengeCard('Push-ups', 'In progress'),
      ],
    );
  }

  Widget _buildEventsSection() {
    return ListView(
      children: [
        _buildSectionHeader('Past Events'),
        _buildEventCard('Bushwakkers', 'Held on 2024-02-30'),
        _buildEventCard('Gym session', 'Held on 2024-03-15'),
        _buildSectionHeader('Present Events'),
        _buildEventCard('Supper at uncle ronnis', 'Upcoming on 2024-07-10'),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: EdgeInsets.all(8.0),
      color: Colors.grey[200],
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildChallengeCard(String title, String subtitle) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        onTap: () {
          // Handle tapping on the challenge card
        },
      ),
    );
  }

  Widget _buildEventCard(String title, String subtitle) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        onTap: () {
          // Handle tapping on the event card
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Image"),
        content: Text("Are you sure you want to delete this image?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              _deleteImage(docId);
              Navigator.pop(context);
            },
            child: Text("Delete"),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteImage(String docId) async {
    try {
      DocumentSnapshot imageSnapshot = await FirebaseFirestore.instance.collection('images').doc(docId).get();
      if (!imageSnapshot.exists) {
        print("Image document does not exist");
        return;
      }

      Map<String, dynamic>? imageData = imageSnapshot.data() as Map<String, dynamic>?;
      if (imageData == null || !imageData.containsKey('url')) {
        print("Invalid image data");
        return;
      }

      String imageUrl = imageData['url'];
      if (imageUrl == null || !(imageUrl.startsWith('gs://') || imageUrl.startsWith('http'))) {
        print("Invalid image URL");
        return;
      }

      if (imageUrl.startsWith('gs://')) {
        await firebase_storage.FirebaseStorage.instance.refFromURL(imageUrl).delete();
      }

      await FirebaseFirestore.instance.collection('images').doc(docId).delete();
    } catch (e) {
      print("Error deleting image: $e");
    }
  }
}

class FullScreenImage extends StatelessWidget {
  final String imagePath;

  const FullScreenImage({Key? key, required this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(imagePath, fit: BoxFit.cover),
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
              color: Colors.black.withOpacity(0.5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ShareImageScreen(imagePath: imagePath),
                        ),
                      );
                    },
                    icon: Icon(Icons.share, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}