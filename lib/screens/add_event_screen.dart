import 'package:flutter/material.dart';


class CreateEvent extends StatelessWidget {
  const CreateEvent({Key? key}) : super(key: key);

  @override


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Event!'),
      ),
      body: const Center(
        child: Text(
          'OK Coach, create the Event',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );

  }
}
