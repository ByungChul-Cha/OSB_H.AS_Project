import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/set_server_ip.dart';

class SearchResultScreen extends StatefulWidget {
  final int itemSeq;

  SearchResultScreen({required this.itemSeq});

  @override
  _SearchResultScreenState createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  String? imageUrl;
  String? itemName;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getImageAndItemNameFromServer();
  }

  Future<void> _getImageAndItemNameFromServer() async {
    try {
      // 이미지 가져오기
      final storageRef =
          FirebaseStorage.instance.ref('Image/Src/Raw/${widget.itemSeq}.jpg');
      final url = await storageRef.getDownloadURL();
      setState(() {
        imageUrl = url;
      });

      // 약 이름 가져오기
      final itemName = await fetchItemNameFromServer(widget.itemSeq.toString());
      setState(() {
        this.itemName = itemName;
        isLoading = false;
      });
    } catch (e) {
      print('Error getting image and item name: $e');
      setState(() {
        isLoading = false;
      });
    }
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
        title: const Text('약 정보'),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (imageUrl != null)
                  Image.network(imageUrl!, fit: BoxFit.cover),
                const SizedBox(height: 16.0),
                if (itemName != null)
                  Text(
                    itemName!,
                    style: const TextStyle(
                        fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
              ],
            ),
    );
  }
}
