import 'dart:io';

import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snapchat_ui_clone/screens/Stage%201/authentication_screen.dart';
import 'package:snapchat_ui_clone/screens/camera_screen.dart';
import 'package:snapchat_ui_clone/screens/chat_screen.dart';
import 'package:snapchat_ui_clone/screens/engagements_screen.dart';
import 'package:snapchat_ui_clone/screens/event_screen.dart';
import 'package:snapchat_ui_clone/screens/Stage%201/signup_screen.dart';
import 'package:snapchat_ui_clone/screens/stories_screen.dart';
import 'package:snapchat_ui_clone/screens/team_screen.dart';
import 'package:snapchat_ui_clone/style.dart';

late List<CameraDescription> _cameras;

List<CameraDescription> getCameras() {
  return _cameras;
}

bool showSignUpScreen = true; // Set this flag to true to show the SignUpScreen initially

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

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
        // Set the default font family to Montserrat
        fontFamily: GoogleFonts
            .montserrat()
            .fontFamily,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        textTheme: TextTheme(
          headline1: GoogleFonts.montserrat(textStyle: Theme
              .of(context)
              .textTheme
              .headline1),
          headline2: GoogleFonts.montserrat(textStyle: Theme
              .of(context)
              .textTheme
              .headline2),
          headline3: GoogleFonts.montserrat(textStyle: Theme
              .of(context)
              .textTheme
              .headline3),
          headline4: GoogleFonts.montserrat(textStyle: Theme
              .of(context)
              .textTheme
              .headline4),
          headline5: GoogleFonts.montserrat(textStyle: Theme
              .of(context)
              .textTheme
              .headline5),
          headline6: GoogleFonts.montserrat(textStyle: Theme
              .of(context)
              .textTheme
              .headline6),
          bodyText1: GoogleFonts.montserrat(textStyle: Theme
              .of(context)
              .textTheme
              .bodyText1),
          bodyText2: GoogleFonts.montserrat(textStyle: Theme
              .of(context)
              .textTheme
              .bodyText2),
          subtitle1: GoogleFonts.montserrat(textStyle: Theme
              .of(context)
              .textTheme
              .subtitle1),
          subtitle2: GoogleFonts.montserrat(textStyle: Theme
              .of(context)
              .textTheme
              .subtitle2),
          caption: GoogleFonts.montserrat(textStyle: Theme
              .of(context)
              .textTheme
              .caption),
          button: GoogleFonts.montserrat(textStyle: Theme
              .of(context)
              .textTheme
              .button),
          overline: GoogleFonts.montserrat(textStyle: Theme
              .of(context)
              .textTheme
              .overline),
        ),
      ),
      home: AuthenticationScreen(),
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
        children: <Widget>[
          // showSignUpScreen ? SignUpScreen() : Container(), // Display SignUpScreen conditionally
          // TemporaryScreen(color: _colors[0]),
          const ChatScreen(friendName: '',),
          // TemporaryScreen(color: _colors[1]),
          TeamScreen(),
          CameraScreen(cameraController: _cameraController, initCamera: initCamera),
          // TemporaryScreen(color: _colors[3]),
          const EngagementsScreen(),
          const StoriesScreen(),
          // TemporaryScreen(color: _colors[4]),
        ],
      ),
      bottomNavigationBar: Expanded(
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
          items: const <BottomNavigationBarItem>[
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
              icon: Icon(Icons.diversity_2_rounded, size: 28),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled, size: 28),
              label: '',
            ),
          ],
        ),
      ),
    );
  }
}