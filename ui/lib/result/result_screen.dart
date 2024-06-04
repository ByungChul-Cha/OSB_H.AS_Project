import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class ResultScreen extends StatefulWidget {
  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  List<String> folderNames = [];
  List<String> imageUrls = [];
  int _currentPage = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    fetchFolderNames();
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
                              onPressed: () {
                                print("확인 버튼 클릭됨.");
                              },
                              child: const Text(
                                "확인",
                                selectionColor: Colors.black,
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                print("없음 버튼 클릭됨.");
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
