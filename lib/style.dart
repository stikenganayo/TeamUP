import 'package:flutter/material.dart';

class Style {
  // Primary Colors
  static const Color white = Colors.white;
  static const Color yellow = Color(0xffFFFC00);
  static const Color black = Colors.black;

  // Navbar Colors
  static const Color greenNavbar = Color(0xff39CB8F);
  static const Color blueNavbar = Color(0xff00B6FF);
  static const Color yellowNavbar = yellow;
  static const Color purpleNavbar = Color(0xffCC4BFA);
  static const Color redNavbar = Color(0xffE31A32);

  // Message Colors
  static const Color imageColor = Color(0xffF33A57);
  static const Color videoColor = Color(0xffA05DCD);
  static const Color chatColor = blueNavbar;

  // Text Colors
  static const Color blackText = Colors.black;
  static const Color whiteText = Colors.white;
  static const Color grayText = Color(0xff8f8f8f);

  // Icon colors
  static Color cameraPageBackground = Colors.black.withOpacity(0.4);
  static const Color cameraPageIconColor = Colors.white;
  static const Color otherPageBackground = Color(0xffE9EDF0);
  static const Color otherPageIconColor = Color(0xff646E7A);

  // For fake stories
  static const List<Color> tempColors = [
    Colors.redAccent,
    Colors.deepPurple,
    Colors.black,
    Colors.green,
    Colors.pinkAccent,
    Colors.blueAccent,
    Colors.deepOrange,
  ];

  // Text
  static Text screenTitle(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 28,
      color: blackText,
      fontWeight: FontWeight.bold,
    ),
  );
  
  static Padding sectionTitle(String text) => Padding(
    padding: const EdgeInsets.only(left: 10),
    child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          color: blackText,
          fontWeight: FontWeight.bold,
      ),
    ),
  );

  static Text friendName(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 18,
      color: blackText,
    ),
  );

  static Text statusName(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 12,
      color: blackText,
    ),
  );


  static Text subscriptionTitle(String text) => Text(
    text,
    overflow: TextOverflow.ellipsis,
    maxLines: 3,
    textAlign: TextAlign.center,
    style: const TextStyle(
      fontSize: 12,
      color: whiteText,
      fontWeight: FontWeight.w500,
    ),
  );

  static Text subscriptionDesc(String text) => Text(
    text,
    overflow: TextOverflow.ellipsis,
    maxLines: 4,
    textAlign: TextAlign.center,
    style: const TextStyle(
      fontSize: 13,
      color: whiteText,
      fontWeight: FontWeight.bold,
    ),
  );

  static Text discoverTitle(String text) => Text(
    text,
    overflow: TextOverflow.ellipsis,
    maxLines: 3,
    textAlign: TextAlign.center,
    style: const TextStyle(
      fontSize: 20,
      color: whiteText,
      fontWeight: FontWeight.w500,
    ),
  );

  static Text discoverDesc(String text) => Text(
    text,
    overflow: TextOverflow.ellipsis,
    maxLines: 4,
    textAlign: TextAlign.center,
    style: const TextStyle(
      fontSize: 18,
      color: whiteText,
      fontWeight: FontWeight.bold,
    ),
  );
}
