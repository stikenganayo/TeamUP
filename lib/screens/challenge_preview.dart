import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ReviewPostScreen extends StatelessWidget {
  Future<void> postChallenge(BuildContext context) async {
    // Implementation of postChallenge
  }

  Future<void> deletePostedChallenge(DocumentReference challengeDocRef) async {
    // Implementation of deletePostedChallenge
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Review & Post'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => postChallenge(context),
              child: Text('Post Challenge'),
            ),
            ElevatedButton(
              onPressed: () {
                // Assume you have a reference to the challenge document
                DocumentReference challengeDocRef = FirebaseFirestore.instance.collection('challenges').doc('challengeId');
                deletePostedChallenge(challengeDocRef);
              },
              child: Text('Delete Challenge'),
            ),
          ],
        ),
      ),
    );
  }
}