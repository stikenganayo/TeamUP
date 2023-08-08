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


class CreateTeam extends StatelessWidget {
  const CreateTeam({Key? key}) : super(key: key);

  @override


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Team!'),
      ),
      body: const Center(
        child: Text(
          'OK Coach, create the Team',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );

  }
}
