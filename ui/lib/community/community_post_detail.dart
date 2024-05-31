import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:has_app/community/community_post_edit.dart';

class CommunityPostDetail extends StatelessWidget {
  final DocumentSnapshot post;

  CommunityPostDetail({required this.post});

  @override
  Widget build(BuildContext context) {
    String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    bool isAuthor = post['authorId'] == currentUserId;
    List<dynamic> imageUrls = post['imageUrls'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(post['title']),
        actions: <Widget>[
          if (isAuthor)
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CommunityPostEdit(post: post)),
                );
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                post['title'],
                style: Theme.of(context).textTheme.titleLarge,
              ),
              RichText(
                text: TextSpan(
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: const Color.fromARGB(255, 61, 61, 61)),
                  children: <TextSpan>[
                    TextSpan(text: post['name'] + "  "),
                    TextSpan(
                      text: post['content'],
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color.fromARGB(255, 61, 61, 61)),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8.0),
              Text(
                post['content'],
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: 16.0),
              for (var imageUrl in imageUrls)
                if (imageUrl != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
