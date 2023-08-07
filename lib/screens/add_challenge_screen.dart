import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddChallenge extends StatelessWidget {
  const AddChallenge({Key? key}) : super(key: key);

  @override


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Challenge!'),
      ),
      body: const Center(
        child: Text(
          'OK Coach, create the challenge',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );

  }
}

