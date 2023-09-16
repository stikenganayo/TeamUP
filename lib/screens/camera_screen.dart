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

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key, required this.cameraController, required this.initCamera})
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
    setState(() {
      _isFrontCamera = !_isFrontCamera;
    });

    await widget.initCamera(frontCamera: _isFrontCamera);
  }

  Future<void> takePictureAndShow() async {
    try {
      // Set flash to torch only for capturing the picture
      widget.cameraController!.setFlashMode(FlashMode.torch);

      XFile? image = await widget.cameraController!.takePicture();

      // Reset flash mode to its previous state after capturing the picture
      widget.cameraController!.setFlashMode(_flashMode);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PictureScreen(imagePath: image.path),
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print("Error capturing picture: $e");
      }
    }
  }

  void _openImageListScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ImageListScreen(),
      ),
    );
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
                onTap: _openImageListScreen, // Open the new screen
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
                child: Icon(CupertinoIcons.calendar, color: Style.white, size: 28),
                isCameraPage: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class PictureScreen extends StatelessWidget {
  final String imagePath;

  const PictureScreen({Key? key, required this.imagePath}) : super(key: key);

  Future<void> _savePictureToDevice(BuildContext context) async {
    try {
      final Directory? picturesDir = await getExternalStorageDirectory();
      if (picturesDir == null) {
        // Handle the case when getExternalStorageDirectory returns null
        if (kDebugMode) {
          print("Error: External storage directory is not available.");
        }
        return;
      }

      final String savePath = "${picturesDir.path}/TeamUP/${DateTime.now().millisecondsSinceEpoch}.jpg";

      // Create the directory if it doesn't exist
      final savedDir = Directory(savePath);
      if (!savedDir.existsSync()) {
        savedDir.createSync(recursive: true);
      }

      // Copy the image to the specified save path
      final File imageFile = File(imagePath);
      await imageFile.copy(savePath);

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
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back when the back button is pressed
          },
        ),
        title: const Text(''),
      ),
      body: Container(
        color: Colors.white, // Set the background color to white
        child: Image.file(File(imagePath)),
      ),
      extendBody: true,
      bottomNavigationBar: SizedBox(
        height: Platform.isIOS ? 90 : 60,
        child: BottomNavigationBar(
          currentIndex: 0,
          selectedItemColor: Colors.red,
          onTap: (index) {
            if (index == 0) {
              // Call the save function when the "Save" icon is clicked
              _savePictureToDevice(context);
            }
          },
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.arrow_down_circle_fill, size: 28),
              label: 'Save',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.plus_app_fill, size: 28),
              label: 'Story',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.arrowshape_turn_up_right_circle_fill, size: 28),
              label: 'Send',
            ),
          ],
        ),
      ),
    );
  }
}