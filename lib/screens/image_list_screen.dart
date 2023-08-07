import 'package:flutter/material.dart';

class ImageListScreen extends StatelessWidget {
  const ImageListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Placeholder list of images for demonstration purposes
    final List<String> placeholderImages = [
      'https://via.placeholder.com/400',
      'https://via.placeholder.com/500',
      'https://via.placeholder.com/600',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Memories'),
      ),
      body: ListView.builder(
        itemCount: placeholderImages.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Image.network(placeholderImages[index]),
          );
        },
      ),
    );
  }
}