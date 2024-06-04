import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ResultScreen extends StatefulWidget {
  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  List<String> folderNames = [];
  List<String> imageUrls = [];
  int _currentPage = 0;
  PageController _pageController = PageController();

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
        title: Text('검색된 알약들'),
      ),
      body: imageUrls.isEmpty
          ? Center(child: CircularProgressIndicator())
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
                    return Center(
                      child: Container(
                        margin: EdgeInsets.all(16.0), // 박스 주변의 여백을 설정합니다.
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.grey), // 박스 테두리 색상과 두께를 설정합니다.
                          borderRadius:
                              BorderRadius.circular(8.0), // 박스의 모서리를 둥글게 설정합니다.
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                              8.0), // 이미지의 모서리를 둥글게 설정합니다.
                          child: Image.network(
                            imageUrls[index],
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Positioned(
                  bottom: 16.0,
                  right: 16.0,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    color: Colors.black54,
                    child: Text(
                      '${_currentPage + 1}/${imageUrls.length}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
