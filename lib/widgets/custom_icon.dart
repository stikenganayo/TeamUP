import 'package:flutter/cupertino.dart';

import '../style.dart';

class CustomIcon extends StatelessWidget {
  const CustomIcon({Key? key, required this.child, required this.isCameraPage}) : super(key: key);
  final Widget child;
  final bool isCameraPage;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: isCameraPage
          ? Style.cameraPageBackground
          : Style.otherPageBackground,
      ),
      child: Padding(padding: const EdgeInsets.all(4.0), child: child)
    );
  }
}