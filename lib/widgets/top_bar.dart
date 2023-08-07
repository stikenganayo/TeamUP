import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:snapchat_ui_clone/widgets/custom_icon.dart';
import 'profile_screen.dart'; // Import the ProfileScreen class

import '../style.dart';

class TopBar extends StatelessWidget {
  const TopBar({Key? key, required this.isCameraPage, this.text}) : super(key: key);
  final bool isCameraPage;
  final String? text;

  void _openProfileScreen(BuildContext context) {
    // Replace 'ProfileScreen' with the actual name of your profile screen widget.
    Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen()));
  }

  @override
  Widget build(BuildContext context) {
    Color color = isCameraPage ? Style.cameraPageIconColor : Style.otherPageIconColor;
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          top: 40,
          left: 10,
          child: GestureDetector(
            onTap: () => _openProfileScreen(context), // Add this onTap handler
            child: CustomIcon(child: Icon(Icons.person, color: color, size: 28), isCameraPage: isCameraPage),
          ),
        ),
        Positioned(
          top: 40,
          left: 65,
          child: CustomIcon(child: Icon(Icons.search, color: color, size: 28), isCameraPage: isCameraPage),
        ),
        Positioned(
          top: 40,
          right: 67,
          child: CustomIcon(
            child: Icon(Icons.add, color: color, size: 28),
            isCameraPage: isCameraPage,
          ),
        ),
        Positioned(
          top: 40,
          right: 12,
          child: isCameraPage
              ? Container(
            width: 47,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: Style.cameraPageBackground,
            ),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Icon(Icons.repeat, color: color, size: 28),
                const SizedBox(height: 15),
                Icon(Icons.flash_off, color: color, size: 28),
                const SizedBox(height: 15),
              ],
            ),
          )
              : CustomIcon(child: Icon(Icons.more_horiz, color: color, size: 28), isCameraPage: false),
        ),
        if (text != null)
          Positioned(
            top: 50,
            child: Style.screenTitle(text!),
          )
      ],
    );
  }
}