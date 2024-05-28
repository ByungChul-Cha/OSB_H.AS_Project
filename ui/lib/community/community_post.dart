import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:has_app/community/community.dart';

class CommunityPostBoard extends StatefulWidget {
  @override
  State<CommunityPostBoard> createState() => _CommunityPostBoardState();
}

class _CommunityPostBoardState extends State<CommunityPostBoard> {
  final CollectionReference _posts =
      FirebaseFirestore.instance.collection('posts');
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  String postTitle = "";
  String content = "";

  final String _chars =
      "AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890";
  Random _rnd = Random();
  // 키 생성을 위한 랜덤함수
  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  // 키 생성을 위해서 _chars 변수에서 랜덤으로 뽑아서 문자열 변환
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("포스팅 작성")),
      body: Column(
        children: <Widget>[
          Flexible(
              child: TextField(
            controller: titleController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: "포스팅 제목",
            ),
          )),
          Expanded(
            child: TextField(
              controller: contentController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "내용",
              ),
              maxLines: 10,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              String postKey = getRandomString(16);
              if (titleController.text.isNotEmpty &&
                  contentController.text.isNotEmpty) {
                postTitle = titleController.text;
                content = contentController.text;
                _posts.doc(postKey).set({
                  "key": postKey,
                  "title": postTitle,
                  "content": content,
                });
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Community()));
              }
              /*if (titleController.text.isEmpty ||
                  contentController.text.isEmpty) {
                showErrorToast();
              }*/
            },
            child: const Text("업로드 하기"),
          ),
        ],
      ),
    );
  }
}

/*void showErrorToast() {
  Fluttertoast.showToast(
    msg: '올바르지 않은 형식입니다.',
    gravity: ToastGravity.BOTTOM,
    backgroundColor: Colors.black,
    fontSize: 11,
    textColor: Colors.white,
    toastLength: Toast.LENGTH_SHORT,
  );
}*/
