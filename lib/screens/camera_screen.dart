import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:snapchat_ui_clone/widgets/top_bar.dart';
import '../style.dart';
import '../widgets/custom_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'image_list_screen.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen(
      {Key? key, required this.cameraController, required this.initCamera})
      : super(key: key);

  final CameraController? cameraController;
  final Future<void> Function({required bool frontCamera}) initCamera;

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  bool _isFrontCamera = true;
  final FlashMode _flashMode = FlashMode.off;

  void _toggleFlash() {
    widget.cameraController!.setFlashMode(_flashMode);
  }

  void _flipCamera() async {
    _isFrontCamera = !_isFrontCamera;
    await widget.initCamera(frontCamera: _isFrontCamera);
    setState(() {});
  }

  Future<void> takePictureAndShow() async {
    try {
      // Set flash to torch only for capturing the picture
      widget.cameraController!.setFlashMode(FlashMode.torch);

      XFile? image = await widget.cameraController!.takePicture();

      // Reset flash mode to its previous state after capturing the picture
      widget.cameraController!.setFlashMode(_flashMode);

      await _savePictureToDevice(context, image.path); // Call the save method
    } catch (e) {
      if (kDebugMode) {
        print("Error capturing picture: $e");
      }
    }
  }

  void _openImageListScreen(List<String> images) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageListScreen(images: images),
      ),
    );
  }

  Future<void> _savePictureToDevice(BuildContext context, String imagePath) async {
    try {
      final Directory? picturesDir = await getExternalStorageDirectory();
      if (picturesDir == null) {
        if (kDebugMode) {
          print("Error: External storage directory is not available.");
        }
        return;
      }

      final String savePath =
          "${picturesDir.path}/TeamUP/${DateTime.now().millisecondsSinceEpoch}.jpg";

      final savedDir = Directory(savePath);
      if (!savedDir.existsSync()) {
        savedDir.createSync(recursive: true);
      }

      final File imageFile = File(imagePath);

      // Upload image to Firebase Storage
      final Reference storageReference =
      FirebaseStorage.instance.ref().child('images/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final UploadTask uploadTask = storageReference.putFile(imageFile);
      await uploadTask.whenComplete(() async {
        final String imageUrl = await storageReference.getDownloadURL();

        // Store download URL in Firestore
        FirebaseFirestore.instance.collection('images').doc().set({'url': imageUrl});
      });

      // Fetch the list of images from Firebase
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
      await FirebaseFirestore.instance.collection('images').get();

      List<String> images = [];
      for (QueryDocumentSnapshot<Map<String, dynamic>> doc in querySnapshot.docs) {
        images.add(doc['url']);
      }

      // Navigate to ImageListScreen with the updated list of images
      _openImageListScreen(images);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Picture saved to: $savePath"),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print("Error saving picture: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        (widget.cameraController == null)
            ? Container(
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(12),
          ),
        )
            : GestureDetector(
          onDoubleTap: () {
            _isFrontCamera = !_isFrontCamera;
            widget.initCamera(frontCamera: _isFrontCamera);
          },
          child: Builder(builder: (BuildContext builder) {
            var camera = widget.cameraController!.value;
            final fullSize = MediaQuery.of(context).size;
            final size =
            Size(fullSize.width, fullSize.height - (Platform.isIOS ? 90 : 60));
            double scale;
            try {
              scale = size.aspectRatio * camera.aspectRatio;
            } catch (_) {
              scale = 1;
            }
            if (scale < 1) scale = 1 / scale;
            return ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Transform.scale(
                scale: scale,
                child: Center(
                  child: CameraPreview(widget.cameraController!),
                ),
              ),
            );
          }),
        ),
        TopBar(isCameraPage: true, onFlipCamera: _flipCamera, onToggleFlash: _toggleFlash),
        Positioned(
          bottom: 15,
          child: Row(
            children: [
              GestureDetector(
                onTap: () async {
                  // Fetch the list of images from Firebase
                  QuerySnapshot<Map<String, dynamic>> querySnapshot =
                  await FirebaseFirestore.instance.collection('images').get();

                  List<String> images = [];
                  for (QueryDocumentSnapshot<Map<String, dynamic>> doc in querySnapshot.docs) {
                    images.add(doc['url']);
                  }

                  // Navigate to ImageListScreen with the current list of images
                  _openImageListScreen(images);
                },
                child: const CustomIcon(
                  child: Icon(
                    CupertinoIcons.photo_on_rectangle,
                    color: Style.white,
                    size: 28,
                  ),
                  isCameraPage: true,
                ),
              ),
              const SizedBox(width: 18),
              GestureDetector(
                onTap: () => takePictureAndShow(),
                child: Image.asset('assets/images/camera_button.png', scale: 4.3),
              ),
              const SizedBox(width: 18),
              const CustomIcon(
                child: Icon(CupertinoIcons.gear, color: Style.white, size: 28),
                isCameraPage: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}