import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddFriend extends StatelessWidget {
  const AddFriend({Key? key}) : super(key: key);

  @override


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Friends!'),
      ),
      body: const Center(
        child: Text(
          'OK Add Team/Friends!!',
          style: TextStyle(fontSize: 40),
        ),
      ),
    );

  }
}