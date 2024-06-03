import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class CameraApp extends StatefulWidget {
  @override
  _CameraAppState createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  XFile? _imageFront;
  XFile? _imageBack;
  final ImagePicker _picker = ImagePicker();
  String _extractedText = '';

  Future<void> _pickImage(bool isFront) async {
    final source = await _showImageSourceDialog();
    if (source == null) return;

    final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
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
        title: Text('이미지 선택'),
        content: Text('이미지를 가져올 위치를 선택하세요.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
            child: Text('갤러리'),
          ),
          TextButton(
            child: Text('카메라'),
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

      setState(() {
        _extractedText = 'Front Image Text:\n${recognisedTextFront.text}\n\n' +
            'Back Image Text:\n${recognisedTextBack.text}';
      });

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
                : Center(child: Text('앞쪽 이미지를 선택하세요.')))
            : (_imageBack != null
                ? Image.file(File(_imageBack!.path), fit: BoxFit.cover)
                : Center(child: Text('뒤쪽 이미지를 선택하세요.'))),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('카메라 검색'),
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
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (_imageFront == null || _imageBack == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('두 이미지를 모두 선택해 주세요.'),
                    ),
                  );
                } else {
                  await _extractTextFromImages();
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('추출된 이미지'),
                      content: SingleChildScrollView(
                        child: Text(_extractedText),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('확인'),
                        ),
                      ],
                    ),
                  );
                }
              },
              child: Text('이미지 추출하기'),
            ),
          ],
        ),
      ),
    );
  }
}
