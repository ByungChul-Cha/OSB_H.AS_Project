import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:has_app/community/community_post_edit.dart';
import 'package:intl/intl.dart';

class CommunityPostDetail extends StatefulWidget {
  final DocumentSnapshot post;
  CommunityPostDetail({required this.post});

  @override
  _CommunityPostDetailState createState() => _CommunityPostDetailState();
}

class _CommunityPostDetailState extends State<CommunityPostDetail> {
  int currentPage = 0; // 현재 페이지 인덱스

  @override
  Widget build(BuildContext context) {
    List<dynamic> imageUrls = widget.post['imageUrls'] ?? [];
    DateTime postDate = (widget.post['createdAt'] as Timestamp).toDate();
    DateTime koTime = postDate.add(const Duration(hours: 9));
    String formattedDate = DateFormat('MM/dd HH:mm').format(koTime);
    String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    bool isAuthor = widget.post['authorId'] == currentUserId;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.post['title']),
        actions: <Widget>[
          if (isAuthor)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          CommunityPostEdit(post: widget.post)),
                );
              },
            ),
          if (isAuthor)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('posts')
                    .doc(widget.post.id)
                    .delete()
                    .then((_) {
                  Navigator.pop(context);
                });
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                widget.post['title'],
                style: Theme.of(context).textTheme.titleLarge,
              ),
              RichText(
                text: TextSpan(
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: const Color.fromARGB(255, 61, 61, 61)),
                  children: <TextSpan>[
                    TextSpan(text: widget.post['name'] + "  "),
                    TextSpan(
                      text: formattedDate,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color.fromARGB(255, 61, 61, 61)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                widget.post['content'],
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16.0),
              if (imageUrls.isNotEmpty)
                Stack(
                  children: <Widget>[
                    Container(
                      height: 400,
                      child: PageView.builder(
                        itemCount: imageUrls.length,
                        onPageChanged: (int index) {
                          setState(() {
                            currentPage = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          return Image.network(
                            imageUrls[index],
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),
                    Positioned(
                      right: 10,
                      bottom: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        color: Colors.black54,
                        child: Text(
                          "${currentPage + 1}/${imageUrls.length}",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
