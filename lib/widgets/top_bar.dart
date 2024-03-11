import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:snapchat_ui_clone/widgets/custom_icon.dart';
import 'package:snapchat_ui_clone/screens/search_screen.dart';
import 'package:snapchat_ui_clone/screens/profile_screen.dart';
import '../screens/calendar_screen.dart';
import '../screens/notifications_screen.dart';
import '../style.dart';

class TopBar extends StatefulWidget {
  const TopBar({
    Key? key,
    required this.isCameraPage,
    this.text,
    this.onFlipCamera,
    this.onToggleFlash,
  }) : super(key: key);

  final bool isCameraPage;
  final String? text;
  final VoidCallback? onFlipCamera;
  final VoidCallback? onToggleFlash;

  @override
  _TopBarState createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  Color flashIconColor = Style.cameraPageIconColor;

  void _openProfileScreen(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
  }

  void _openSearchScreen(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchScreen()));
  }




  @override
  Widget build(BuildContext context) {
    Color color = widget.isCameraPage ? Style.cameraPageIconColor : Style.otherPageIconColor;
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          top: 40,
          left: 10,
          child: GestureDetector(
            onTap: () => _openProfileScreen(context),
            child: CustomIcon(child: Icon(Icons.person, color: color, size: 28), isCameraPage: widget.isCameraPage),
          ),
        ),
        Positioned(
          top: 40,
          left: 65,
          child: GestureDetector(
            onTap: () => _openSearchScreen(context),
            child: CustomIcon(child: Icon(Icons.add, color: color, size: 28), isCameraPage: widget.isCameraPage),
          ),
        ),
        Positioned(
          top: 40,
          right: 67,
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CalendarScreen()),
              );
            },
            child: CustomIcon(child: Icon(CupertinoIcons.calendar_today, color: color, size: 28), isCameraPage: widget.isCameraPage),

          ),
        ),
        Positioned(
          top: 40,
          right: 12,
          child: widget.isCameraPage
              ? Container(
            width: 47,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: Style.cameraPageBackground,
            ),
            child: Column(
              children: [
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    // Navigate to the NotificationsScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                    );
                  },
                  child: Icon(Icons.notifications, color: color, size: 28),
                ),
                const SizedBox(height: 15),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: widget.onFlipCamera, // Trigger the camera flip function here
                  child: Icon(Icons.repeat, color: color, size: 28),
                ),
                const SizedBox(height: 15),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      flashIconColor = flashIconColor == Style.cameraPageIconColor ? Colors.red : Style.cameraPageIconColor;
                    });
                    widget.onToggleFlash?.call();
                  },
                  child: Icon(Icons.flash_on, color: flashIconColor, size: 28),
                ),
                const SizedBox(height: 15),
              ],
            ),
          )
              : InkWell(
            onTap: () {
              // Navigate to the NotificationsScreen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationsScreen()),
              );
            },
            child: CustomIcon(
              child: Icon(Icons.notifications, color: color, size: 28),
              isCameraPage: false,
            ),
          ),





        ),
        if (widget.text != null)
          Positioned(
            top: 50,
            child: Style.screenTitle(widget.text!),
          )
      ],
    );
  }
}