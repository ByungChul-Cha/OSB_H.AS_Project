import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart';

class AboutPillInfo extends StatefulWidget {
  final String imageUrl;
  final String itemName;

  AboutPillInfo({required this.imageUrl, required this.itemName});

  @override
  _AboutPillInfoState createState() => _AboutPillInfoState();
}

class _AboutPillInfoState extends State<AboutPillInfo> {
  @override
  Widget build(BuildContext context) {
    String decodeUrl = Uri.decodeFull(widget.imageUrl);
    String fileName = path.basenameWithoutExtension(decodeUrl);

    return Scaffold(
      appBar: AppBar(
        title: const Text('약 정보'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(widget.imageUrl, fit: BoxFit.cover),
            const SizedBox(height: 16.0),
            Text(
              widget.itemName,
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
