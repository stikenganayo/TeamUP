import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart';
import '../widgets/top_bar.dart';
import '../style.dart';
import '../widgets/custom_icon.dart';
import 'package:flutter/cupertino.dart';

import 'image_list_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({
    Key? key,
    required this.cameraController,
    required this.initCamera,
  }) : super(key: key);

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
      widget.cameraController!.setFlashMode(FlashMode.torch);

      XFile? image = await widget.cameraController!.takePicture();

      widget.cameraController!.setFlashMode(_flashMode);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DisplayImageScreen(imagePath: image.path),
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print("Error capturing picture: $e");
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
            final size = Size(
                fullSize.width, fullSize.height - (Platform.isIOS ? 90 : 60));
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
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ImageListScreen(),
                    ),
                  );
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

class DisplayImageScreen extends StatefulWidget {
  final String imagePath;

  const DisplayImageScreen({Key? key, required this.imagePath}) : super(key: key);

  @override
  _DisplayImageScreenState createState() => _DisplayImageScreenState();
}

class _DisplayImageScreenState extends State<DisplayImageScreen> {
  TextEditingController _textEditingController = TextEditingController();
  List<Widget> _textWidgets = [];
  bool _textEditingMode = false;
  GlobalKey globalKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RepaintBoundary(
        key: globalKey,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildImageWidget(),
            ..._textWidgets,
            if (_textEditingMode) _buildTextEditingWidget(),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.file(File(widget.imagePath), fit: BoxFit.cover),
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
      ],
    );
  }

  Widget _buildTextEditingWidget() {
    return Positioned(
      top: MediaQuery.of(context).size.height / 4, // Adjust top position as needed
      left: 0,
      right: 0,
      height: MediaQuery.of(context).size.height / 18, // Adjust height as needed
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: TextField(
            controller: _textEditingController,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24, // Adjust the font size as needed
            ),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: 'Enter text',
              hintStyle: TextStyle(color: Colors.white),
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        color: Colors.black.withOpacity(0.7),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              onPressed: () {
                _saveImage();
              },
              icon: Icon(Icons.save, color: Colors.white),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  _textEditingMode = true;
                });
              },
              icon: Icon(Icons.text_fields, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveImage() async {
    try {
      final RenderRepaintBoundary boundary = globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Upload image to Firebase Storage
      final storageRef = firebase_storage.FirebaseStorage.instance.ref();
      final imageFileName = DateTime.now().millisecondsSinceEpoch.toString() + '.png';
      final imageStorageRef = storageRef.child("images/$imageFileName");

      await imageStorageRef.putData(pngBytes);

      // Get the download URL of the uploaded image
      final imageUrl = await imageStorageRef.getDownloadURL();

      // Save the image URL to Firestore
      await FirebaseFirestore.instance.collection('images').add({'url': imageUrl});

      // Close the DisplayImageScreen
      Navigator.pop(context);

    } catch (e) {
      if (kDebugMode) {
        print("Error saving picture: $e");
      }
    }
  }
}