import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:snapchat_ui_clone/screens/camera_screen.dart';
import 'package:snapchat_ui_clone/screens/chat_screen.dart';
import 'package:snapchat_ui_clone/screens/event_screen.dart';
import 'package:snapchat_ui_clone/screens/stories_screen.dart';
import 'package:snapchat_ui_clone/screens/team_screen.dart';
import 'package:snapchat_ui_clone/style.dart';

late List<CameraDescription> _cameras;

List<CameraDescription> getCameras() {
  return _cameras;
}
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      home: const MainPage(),
      //home: AuthenticationScreen(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  int _currentScreen = 2;
  final PageController _pageController = PageController(initialPage: 2);

  late CameraController? _cameraController;

  Future<void> initCamera({required bool frontCamera}) async {
    _cameraController = CameraController(_cameras[(frontCamera) ? 1 : 0], ResolutionPreset.max);
    _cameraController!.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
          // Handle access errors here.
            break;
          default:
          // Handle other errors here.
            break;
        }
      }
    });
  }


  @override
  void initState() {
    super.initState();
    if (_cameras.isNotEmpty) {
      initCamera(frontCamera: true);
    }
  }

  @override
  void dispose() {
    if (_cameraController != null) {
      _cameraController!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Style.white,
      body: PageView(
        physics: const BouncingScrollPhysics(),
        controller: _pageController,
        onPageChanged: (int index) {
          setState(() {
            _currentScreen = index;
          });
        },
        children: <Widget> [
          // TemporaryScreen(color: _colors[0]),
          const ChatScreen(),
          // TemporaryScreen(color: _colors[1]),
          const TeamScreen(),
          CameraScreen(cameraController: _cameraController, initCamera: initCamera),
          // TemporaryScreen(color: _colors[3]),
          const EventsScreen(),
          const StoriesScreen(),
          // TemporaryScreen(color: _colors[4]),

        ],
      ),
      bottomNavigationBar: SizedBox(
        height: Platform.isIOS ? 90 : 60,
        child: BottomNavigationBar(
          selectedItemColor: Colors.red,
          unselectedItemColor: Colors.black,
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          currentIndex: _currentScreen,
          onTap: (int index) {
            _pageController.jumpToPage(index);
          },
          items: const <BottomNavigationBarItem> [
            BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.person_2_fill, size: 28),
                label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.person_3_fill, size: 28),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.camera_fill, size: 28),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.rocket_fill, size: 28),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.book_fill, size: 28),
              label: '',
            ),
          ],
          //currentIndex: 0,

        )

      ),
    );
  }
}
