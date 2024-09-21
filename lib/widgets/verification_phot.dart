import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';

class VerifyCameraScreen extends StatefulWidget {
  final String currentUser;
  final String itemTitle;
  final String checklistItemTitle;
  final String challengeId;

  VerifyCameraScreen({
    required this.currentUser,
    required this.itemTitle,
    required this.checklistItemTitle,
    required this.challengeId,
  });

  @override
  _VerifyCameraScreenState createState() => _VerifyCameraScreenState();
}

class _VerifyCameraScreenState extends State<VerifyCameraScreen> {
  late List<CameraDescription> cameras;
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  int _selectedCameraIndex = 0;
  bool _flashEnabled = false;
  String? _imagePath; // To store the path of the taken image

  @override
  void initState() {
    super.initState();
    // Obtain a list of available cameras
    availableCameras().then((availableCameras) {
      cameras = availableCameras;
      if (cameras.isNotEmpty) {
        _initializeCamera(_selectedCameraIndex);
      }
    }).catchError((e) {
      print('Error getting cameras: $e');
    });
  }

  void _initializeCamera(int index) {
    _controller = CameraController(cameras[index], ResolutionPreset.high,
        enableAudio: false);
    _initializeControllerFuture = _controller.initialize();
    _initializeControllerFuture.then((_) {
      if (mounted) {
        setState(() {});
      }
    }).catchError((e) {
      print('Error initializing camera: $e');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleFlash() {
    setState(() {
      _flashEnabled = !_flashEnabled;
      _controller.setFlashMode(
        _flashEnabled ? FlashMode.torch : FlashMode.off,
      );
    });
  }

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();
      setState(() {
        _imagePath = image.path;
      });
      _showImagePreview(context, _imagePath!);
    } catch (e) {
      print('Error taking picture: $e');
    }
  }

  void _showImagePreview(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.file(File(imagePath)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _takePicture(); // Retake the picture
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      elevation: 5,
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(6),
                    ),
                    child: Icon(Icons.refresh, color: Colors.black, size: 23),
                  ),
                  SizedBox(width: 80),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // Handle the photo send action here
                      _sendPhoto(imagePath);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      elevation: 5,
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(6),
                    ),
                    child: Icon(Icons.send, color: Colors.black, size: 23),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _sendPhoto(String imagePath) async {
    try {
      // Upload image to Firebase Storage
      final storageRef = firebase_storage.FirebaseStorage.instance.ref();
      final imageFileName = DateTime.now().millisecondsSinceEpoch.toString() + '.png';
      final imageStorageRef = storageRef.child("images/$imageFileName");

      final imageFile = File(imagePath);
      final uploadTask = imageStorageRef.putFile(imageFile);
      final snapshot = await uploadTask.whenComplete(() => {});
      final imageUrl = await snapshot.ref.getDownloadURL();

      // Reference to Firestore document
      final docRef = FirebaseFirestore.instance.collection('team_challenges').doc(widget.challengeId);

      // Check if the 'challengeListCompleted' map exists
      final docSnapshot = await docRef.get();
      final existingData = docSnapshot.data() as Map<String, dynamic>?;

      // Initialize the map if it doesn't exist
      if (existingData == null || !existingData.containsKey('challengeListCompleted')) {
        await docRef.set({
          'challengeListCompleted': {},
        }, SetOptions(merge: true));
      }

      // Get the existing challengeListCompleted data
      final challengeListCompleted = existingData?['challengeListCompleted'] as Map<String, dynamic>? ?? {};

      // Create a unique item title and check for existing entries
      String baseItemTitle = widget.itemTitle.replaceAll('_', ' '); // Replace underscores with spaces
      bool entryExists = false;

      // Check if there is already an entry for the current user with the base item title
      challengeListCompleted.forEach((key, value) {
        if (value['player'] == widget.currentUser && key.startsWith(baseItemTitle)) {
          // If a matching entry is found, overwrite it
          challengeListCompleted[key] = {
            'player': widget.currentUser,
            'imageUrl': imageUrl,
            'leader': '',  // Empty leader field
            'status': '',  // Empty status field
            'feedback': '', // New feedback field
          };
          entryExists = true;
        }
      });

      // If no existing entry was found, create a unique item title
      if (!entryExists) {
        String uniqueItemTitle = baseItemTitle;
        int count = 1;

        while (challengeListCompleted.containsKey(uniqueItemTitle)) {
          uniqueItemTitle = '${baseItemTitle} $count'; // Use space instead of underscore
          count++;
        }

        // Add new entry
        challengeListCompleted[uniqueItemTitle] = {
          'player': widget.currentUser,
          'imageUrl': imageUrl,
          'leader': '',  // Empty leader field
          'status': '',  // Empty status field
          'feedback': '', // New feedback field
        };
      }

      // Update the map with the modified data
      await docRef.update({
        'challengeListCompleted': challengeListCompleted,
      });

      // Show 'Saved Successfully' message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Saved Successfully'),
          duration: Duration(seconds: 2), // Adjust duration as needed
        ),
      );

      // Close the VerifyCameraScreen
      Navigator.pop(context);

    } catch (e) {
      print("Error sending photo: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.itemTitle}'),
        // Removed the flip camera icon from the AppBar
      ),
      body: Stack(
        children: [
          // Camera preview extends to the bottom of the screen
          Positioned.fill(
            child: CameraPreview(_controller),
          ),
          Positioned(
            bottom: 20.0,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton(
                onPressed: _takePicture,
                child: Image.asset('assets/images/camera_button.png', scale: 4.3),
                backgroundColor: Colors.transparent, // Set background to transparent if desired
                elevation: 0, // Remove shadow if desired
              ),
            ),
          ),
          Positioned(
            top: 20.0,
            right: 20.0,
            child: Container(
              width: 47,
              height: 100, // Increased the height of the column
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: Colors.black.withOpacity(0.5), // Translucent background
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      // Switch between front and back camera
                      _selectedCameraIndex = (_selectedCameraIndex + 1) % cameras.length;
                      _initializeCamera(_selectedCameraIndex);

                      // Print currentUser and itemTitle when the flip camera icon is clicked
                      print('Current User: ${widget.currentUser}');
                      print('Item Title: ${widget.itemTitle}');
                      print('Challenge ID: ${widget.challengeId}');
                    },
                    child: Icon(Icons.flip_camera_ios, color: Colors.white, size: 28),
                  ),
                  const SizedBox(height: 20), // Increased spacing
                  GestureDetector(
                    onTap: _toggleFlash,
                    child: Icon(
                      _flashEnabled ? Icons.flash_on : Icons.flash_off,
                      color: Colors.white,
                      size: 28,
                    ),
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