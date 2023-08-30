import 'package:flutter/material.dart';

class CreateChallenge extends StatelessWidget {
  const CreateChallenge({Key? key}) : super(key: key);

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


// class CreateChallenge extends StatelessWidget {
//   const CreateChallenge({Key? key}) : super(key: key);
//
//   @override
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Create Challenge!'),
//       ),
//       body: const Center(
//         child: Text(
//           'OK Coach, create the Challenge',
//           style: TextStyle(fontSize: 20),
//         ),
//       ),
//     );
//
//   }
// }
