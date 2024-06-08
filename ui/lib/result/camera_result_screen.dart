import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:has_app/community/community.dart';
import 'package:http/http.dart' as http;
import 'package:has_app/utils/set_server_ip.dart';
import 'package:path/path.dart' as path;
import 'about_pill_info.dart';

class CameraResultScreen extends StatefulWidget {
  @override
  _CameraResultScreenState createState() => _CameraResultScreenState();
}

class _CameraResultScreenState extends State<CameraResultScreen> {
  List<String> folderNames = [];
  List<String> imageUrls = [];
  int _currentPage = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    delayedFetchFolderNames();
  }

  Future<void> delayedFetchFolderNames() async {
    await Future.delayed(const Duration(seconds: 30));
    await fetchFolderNames();
  }

  Future<void> fetchFolderNames() async {
    final storageRef = FirebaseStorage.instance.ref().child('split_pilldata');
    final ListResult result = await storageRef.listAll();

    setState(() {
      folderNames = result.prefixes.map((ref) => ref.name).toList();
    });

    fetchImageUrls();
  }

  Future<void> fetchImageUrls() async {
    final storageRef = FirebaseStorage.instance.ref().child('split_pilldata');
    final ListResult result = await storageRef.listAll();
    List<String> urls = [];

    for (Reference folderRef in result.prefixes) {
      final String folderName = folderRef.name;
      final imageRef =
          FirebaseStorage.instance.ref().child('Image/Src/Raw/$folderName.jpg');

      try {
        final String imageUrl = await imageRef.getDownloadURL();
        urls.add(imageUrl);
      } catch (e) {
        print("Error fetching image for $folderName: $e");
      }
    }

    setState(() {
      imageUrls = urls;
    });
  }

  Future<String> fetchItemNameFromServer(String itemSeq) async {
    final response = await http
        .get(Uri.parse('$desktopServerIP/get_item_name?itemSeq=$itemSeq'));
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to fetch item name');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('검색된 알약'),
      ),
      body: imageUrls.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: imageUrls.length,
                  onPageChanged: (int page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        Expanded(
                          child: Stack(
                            alignment: Alignment.topCenter,
                            children: [
                              Center(
                                child: Image.network(
                                  imageUrls[index],
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Container(
                                width: double.infinity,
                                color: Colors.black.withOpacity(0.5),
                                padding: const EdgeInsets.all(8.0),
                                child: const Text(
                                  "해당 약이 맞을 경우 확인,\n 모든 이미지에 약이 없는 경우 없음을 눌러주세요.",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.0,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                String decodeUrl =
                                    Uri.decodeFull(imageUrls[_currentPage]);
                                String fileName =
                                    path.basenameWithoutExtension(decodeUrl);
                                print(fileName);
                                String itemName =
                                    await fetchItemNameFromServer(fileName);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AboutPillInfo(
                                        imageUrl: imageUrls[_currentPage],
                                        itemName: itemName),
                                  ),
                                );
                              },
                              child: const Text(
                                "확인",
                                selectionColor: Colors.black,
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('알약 찾기 실패'),
                                      content: const Text(
                                          '알약을 찾을 수 없습니다. 커뮤니티로 이동하시겠습니까?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            // '예' 버튼 클릭 시 커뮤니티 페이지로 이동
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      Community()),
                                            );
                                          },
                                          child: const Text('예'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            // '아니요' 버튼 클릭 시 dialog 닫기
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('아니요'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: const Text("없음"),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                Positioned(
                  bottom: 70.0, // 버튼의 위치를 조정합니다.
                  right: 16.0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4.0),
                    color: Colors.black54,
                    child: Text(
                      '${_currentPage + 1}/${imageUrls.length}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
