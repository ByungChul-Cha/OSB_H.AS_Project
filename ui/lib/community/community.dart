import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:has_app/community/community_post.dart';
import 'package:has_app/community/community_post_detail.dart';

class Community extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('커뮤니티'),
      ),
      body: CommunityBoard(),
    );
  }
}

class CommunityBoard extends StatefulWidget {
  @override
  _CommunityBoardState createState() => _CommunityBoardState();
}

class _CommunityBoardState extends State<CommunityBoard> {
  final TextEditingController _controller = TextEditingController();
  final Query<Map<String, dynamic>> _posts = FirebaseFirestore.instance
      .collection('posts')
      .orderBy('createdAt', descending: true);
  // 이전에 작성한 글 불러옴

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: StreamBuilder(
            stream: _posts.snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
                // 로딩 중인 상태 보여줌
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
                // error 발생시
              }
              final posts = snapshot.data?.docs ?? [];
              // null이 아닐 경우 docs 접근 null일 경우 빈 리스트 할당
              return ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  CommunityPostDetail(post: post)));
                    },
                    child: Card(
                      margin: EdgeInsets.all(8),
                      child: ListTile(
                        title: Text(post['title']),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CommunityPostBoard()));
            },
            child: Align(
              alignment: Alignment.bottomRight,
              child: Container(
                margin: EdgeInsets.all(30),
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(1000),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(1.0),
                      spreadRadius: 2,
                      blurRadius: 2,
                      offset: Offset(-0.5, 0.5),
                    ),
                    // 그림자 효과
                  ],
                ),
                child: Icon(Icons.add),
              ),
            )),
      ],
    );
  }
}
