import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:has_app/community/community_post.dart';

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
  final CollectionReference _posts =
      FirebaseFirestore.instance.collection('posts');
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
                  return ListTile(
                    title: Text(post['title']),
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
        // 하단 추가 버튼
        /*Padding(
          padding: const EdgeInsets.all(8.0),
          // 이전 글의 8.0만큼 떨어진 위치에 저장
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'Write a post...',
                  ),
                  // 하단 힌트 부분
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {
                  if (_controller.text.isNotEmpty) {
                    _posts.add({'content': _controller.text});
                    _controller.clear();
                  }
                  // DB에 작성 및 하단 입력 부분 초기화
                },
              ),
            ],
          ),
        ),
        // 하단 입력 부분*/
      ],
    );
  }
}
