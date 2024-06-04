import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_functions/cloud_functions.dart';

class ResultScreen extends StatefulWidget {
  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  List<String> folderNames = [];
  List<String> imageUrls = [];

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
          : ListView.builder(
              itemCount: imageUrls.length,
              itemBuilder: (context, index) {
                return Image.network(imageUrls[index]);
              },
            ),
    );
  }
}
