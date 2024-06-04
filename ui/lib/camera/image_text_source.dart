import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
//import 'camera.dart';
import 'permission.dart';

class ImageTextSource extends StatefulWidget {
  @override
  _ImageTextSourceState createState() => _ImageTextSourceState();
}

class _ImageTextSourceState extends State<ImageTextSource> {
  XFile? _imageFront;
  XFile? _imageBack;
  final ImagePicker _picker = ImagePicker();
  //String _extractedText = '';

  Future<void> _pickImage(bool isFront) async {
    final source = await _showImageSourceDialog();
    if (source == null) return;

    final pickedImage = await _picker.pickImage(source: source);
    if (pickedImage != null) {
      setState(() {
        if (isFront) {
          _imageFront = pickedImage;
        } else {
          _imageBack = pickedImage;
        }
      });
    }
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('이미지 선택'),
        content: const Text('이미지를 가져올 위치를 선택하세요.'),
        actions: <Widget>[
          TextButton(
            child: const Text('갤러리'),
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
          ),
          TextButton(
            child: const Text('카메라'),
            onPressed: () => Navigator.pop(context, ImageSource.camera),
          )
        ],
      ),
    );
  }

  Future<void> _extractTextFromImages() async {
    if (_imageFront != null && _imageBack != null) {
      final inputImageFront = InputImage.fromFilePath(_imageFront!.path);
      final inputImageBack = InputImage.fromFilePath(_imageBack!.path);
      final TextRecognizer textDetector = TextRecognizer();

      final RecognizedText recognisedTextFront =
          await textDetector.processImage(inputImageFront);
      final RecognizedText recognisedTextBack =
          await textDetector.processImage(inputImageBack);

      /*setState(() {
      _extractedText = 'Front Image Text:\n${recognisedTextFront.text}\n\n' +
          'Back Image Text:\n${recognisedTextBack.text}';
    });*/

      sendDataToServer([
        recognisedTextFront.text,
        recognisedTextBack.text,
      ]);

      await textDetector.close();
    }
  }

  Widget _buildImageBox(bool isFront) {
    return GestureDetector(
      onTap: () => _pickImage(isFront),
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue),
          borderRadius: BorderRadius.circular(8),
        ),
        child: isFront
            ? (_imageFront != null
                ? Image.file(File(_imageFront!.path), fit: BoxFit.cover)
                : const Center(child: Text('앞쪽 이미지를 선택하세요.')))
            : (_imageBack != null
                ? Image.file(File(_imageBack!.path), fit: BoxFit.cover)
                : const Center(child: Text('뒤쪽 이미지를 선택하세요.'))),
      ),
    );
  }

  void sendDataToServer(List<String> searchTerms) async {
    const url = 'http://10.0.2.2:5000/search';
    final response = await http.post(
      Uri.parse(url), // 서버 URL 및 엔드포인트를 입력, 안드로이드 에뮬레이터 통신 "10.0.2.2"
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'terms': searchTerms,
      }),
    );

    if (response.statusCode == 200) {
      print('Data sent successfully');
      print('Response: ${response.body}');
    } else {
      print('Failed to send data');
      print(response.statusCode);
    }
  }

  @override
  void initState() {
    requestCameraPermission();
    requestPhotosPermission();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('카메라 검색'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImageBox(true),
                _buildImageBox(false),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (_imageFront == null || _imageBack == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('두 이미지를 모두 선택해 주세요.'),
                    ),
                  );
                } else {
                  await _extractTextFromImages();
                }
              },
              child: const Text('이미지 추출하기'),
            ),
          ],
        ),
      ),
    );
  }
}
