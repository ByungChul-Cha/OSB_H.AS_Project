import 'dart:convert';
import 'dart:io';
import 'package:has_app/camera/data/savedata.dart';
import 'package:has_app/result/camera_result_screen.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/set_server_ip.dart';
import 'permission.dart';
import 'dart:async';

class ImageTextSource extends StatefulWidget {
  @override
  _ImageTextSourceState createState() => _ImageTextSourceState();
}

class _ImageTextSourceState extends State<ImageTextSource> {
  XFile? _imageFront;
  XFile? _imageBack;
  final ImagePicker _picker = ImagePicker();

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

      RecognizedText recognisedTextFront =
          await textDetector.processImage(inputImageFront);
      RecognizedText recognisedTextBack =
          await textDetector.processImage(inputImageBack);

      if (recognisedTextFront.text.isEmpty && recognisedTextBack.text.isEmpty) {
        // 다이얼로그 보여주고 커뮤니티 창으로 이동
      } else {
        if (recognisedTextFront.text.isEmpty) {
          print('인식된 텍스트가 없습니다.');
          recognisedTextFront = recognisedTextBack;
        } else {
          print('인식된 텍스트: ${recognisedTextFront.text}');
        }

        if (recognisedTextBack.text.isEmpty) {
          print('인식된 텍스트가 없습니다.2');
          recognisedTextBack = recognisedTextFront;
        } else {
          print('인식된 텍스트: ${recognisedTextBack.text}');
        }
        sendDataToServer([
          recognisedTextFront.text,
          recognisedTextBack.text,
        ]);
      }
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
                : const Center(child: Text('정면 이미지')))
            : (_imageBack != null
                ? Image.file(File(_imageBack!.path), fit: BoxFit.cover)
                : const Center(child: Text('뒷면 이미지'))),
      ),
    );
  }

  void sendDataToServer(List<String> searchTerms) async {
    const url = '$desktopServerIP/search';
    try {
      print("it's try");
      final response = await http
          .post(
            Uri.parse(url), // 서버 URL 및 엔드포인트를 입력, 안드로이드 에뮬레이터 통신 "10.0.2.2"
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, dynamic>{
              'terms': searchTerms,
            }),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        print('Data sent successfully');
        saveDataToFirebaseStorage(response.body);
        // Firebase Storage original_pilldata에 data.json 형태로 저장
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CameraResultScreen()),
        );
      } else {
        print('Failed to send data: ${response.statusCode}');
      }
    } on TimeoutException catch (_) {
      print('The request timed out.');
      // 타임아웃에 대한 처리
    } catch (e) {
      print('An error occurred: $e');
      // 다른 예외 처리
    }
  }

  @override
  void initState() {
    requestCameraPermission();
    requestPhotosPermission();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showInitialDialog(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('카메라 검색'),
      ),
      body: _buildMainContent(context),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return Center(
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
                _showLoadingDialog();
                await _extractTextFromImages();
                Navigator.pop(context);
                //로딩 창 닫기
              }
            },
            child: const Text('이미지 추출하기'),
          ),
        ],
      ),
    );
  }

  Future<void> _showInitialDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('주의사항'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('1. 알약이 잘 보이게 찍어주세요.'),
                Text('2. 빛반사가 일어나지 않도록 찍어주세요.'),
                Text('3. 카메라 권한을 허용해주세요.')
              ],
            ),
          ),
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

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        onPopInvoked: (isPopped) => {},
        child: const Dialog(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('추출 중입니다.'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _showInitialDialog(BuildContext context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('주의사항'),
        content: const SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('1. 알약이 잘 보이게 찍어주세요.'),
              Text('2. 빛 반사가 일어나지 않도록 찍어주세요.'),
              Text('3. 카메라 권한을 허용해주세요.')
            ],
          ),
        ),
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
