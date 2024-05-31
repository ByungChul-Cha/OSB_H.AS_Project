import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CommunityPostDetail extends StatelessWidget {
  final DocumentSnapshot post;

  CommunityPostDetail({required this.post});

  @override
  Widget build(BuildContext context) {
    String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    bool isAuthor = post['authorId'] == currentUserId;

    return Scaffold(
      appBar: AppBar(
        title: Text(post['title']),
        actions: <Widget>[
          if (isAuthor)
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                // 수정 기능
              },
            ),
          if (isAuthor)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                // 삭제 기능
                FirebaseFirestore.instance
                    .collection('posts')
                    .doc(post.id)
                    .delete()
                    .then((_) {
                  Navigator.pop(context);
                });
              },
            ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              post['title'],
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 8.0),
            Text(
              post['content'],
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
