import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:has_app/community/community.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class CommunityPostBoard extends StatefulWidget {
  @override
  State<CommunityPostBoard> createState() => _CommunityPostBoardState();
}

class _CommunityPostBoardState extends State<CommunityPostBoard> {
  final CollectionReference _posts =
      FirebaseFirestore.instance.collection('posts');
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  TextEditingController imageController = TextEditingController();
  String postTitle = "";
  String content = "";
  final ImagePicker _picker = ImagePicker();
  List<XFile>? _images = [];

  bool _isLoading = false; //로딩 상태 변수

  final String _chars =
      "AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890";
  final Random _rnd = Random();
  // 키 생성을 위한 랜덤함수
  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  // 키 생성을 위해서 _chars 변수에서 랜덤으로 뽑아서 문자열 변환

  Future<void> _pickImages() async {
    List<XFile>? selectedImages = await _picker.pickMultiImage();

    if (selectedImages != null &&
        (_images!.length + selectedImages.length) <= 5) {
      setState(() {
        _images!.addAll(selectedImages);
      });
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('올바르지 않은 형식입니다.'),
            content: const Text('최대 5개의 이미지를 선택할 수 있습니다.'),
            actions: <Widget>[
              TextButton(
                child: const Text('확인'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }
  // 이미지 선택 함수

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("포스팅 작성")),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.only(top: 15),
                ),
                Flexible(
                  child: TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "포스팅 제목",
                    ),
                  ),
                ),
                // 포스트 제목 입력
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                ),
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
                //포스트 내용 작성
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                ),
                Expanded(
                  child: Column(
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: _pickImages,
                        child: const Text('이미지 선택'),
                      ),
                      Expanded(
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 5, crossAxisSpacing: 1.0),
                          itemCount: _images!.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Image.file(
                              File(_images![index].path),
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ),
                // 이미지 선택 기능(최대 5개)
                ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      _isLoading = true;
                    });
                    String postKey = getRandomString(16);
                    final User? user = FirebaseAuth.instance.currentUser;
                    final uid = user?.uid ?? '';
                    final timestamp = DateTime.now();
                    if (titleController.text.isNotEmpty &&
                        contentController.text.isNotEmpty) {
                      postTitle = titleController.text;
                      content = contentController.text;

                      List<String> imageUrls = [];

                      for (var imageFile in _images!) {
                        String fileName =
                            '$postKey/${DateTime.now().millisecondsSinceEpoch}.jpg';
                        firebase_storage.Reference ref = firebase_storage
                            .FirebaseStorage.instance
                            .ref()
                            .child('postImages/$fileName');

                        await ref.putFile(File(imageFile.path));
                        String downloadUrl = await ref.getDownloadURL();
                        imageUrls.add(downloadUrl);
                      }
                      // 이미지 파일 경로 지정
                      await _posts.doc(postKey).set({
                        "key": postKey,
                        "authorId": uid,
                        "title": postTitle,
                        "content": content,
                        "createdAt": timestamp,
                        "imageUrls": imageUrls,
                      });
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Community()));
                    }
                    if (titleController.text.isEmpty ||
                        contentController.text.isEmpty) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('올바르지 않은 형식입니다.'),
                            content: const Text('모든 내용을 적어주세요.'),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('확인'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }
                    // Dialog 메세지 출력

                    setState(() {
                      _isLoading = false;
                    });
                  },
                  child: const Text("업로드 하기"),
                ),
              ],
            ),
    );
  }
}
