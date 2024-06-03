import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

/*class CameraApp extends StatefulWidget {
  @override
  State<CameraApp> createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  XFile? _image;
  final ImagePicker picker = ImagePicker();
  String scannedText = "";

  Future getImage(ImageSource imageSource) async {
    final XFile? pickedFile = await picker.pickImage(source: imageSource);
    if (pickedFile != null) {
      setState(() {
        _image = XFile(pickedFile.path);
      });
      getRecognizedText(_image!);
    }
  }

  void getRecognizedText(XFile image) async {
    final InputImage inputImage = InputImage.fromFilePath(image.path);

    final textRecognizer =
        GoogleMlKit.vision.textRecognizer(script: TextRecognitionScript.latin);

    RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);

    await textRecognizer.close();

    scannedText = "";
    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        scannedText = scannedText + line.text + "\n";
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("Camera Test")),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 30, width: double.infinity),
            _buildPhotoArea(),
            _buildRecognizedText(),
            SizedBox(height: 20),
            _buildButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoArea() {
    return _image != null
        ? Container(
            width: 300,
            height: 300,
            child: Image.file(File(_image!.path)),
          )
        : Container(
            width: 300,
            height: 300,
            color: Colors.grey,
          );
  }

  Widget _buildRecognizedText() {
    return Text(scannedText);
  }

  Widget _buildButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {
            getImage(ImageSource.camera);
          },
          child: Text("카메라"),
        ),
        SizedBox(width: 30),
        ElevatedButton(
          onPressed: () {
            getImage(ImageSource.gallery);
          },
          child: Text("갤러리"),
        ),
      ],
    );
  }
}*/

class CameraApp extends StatefulWidget {
  @override
  _CameraAppState createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  XFile? _imageFront;
  XFile? _imageBack;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      if (_imageFront == null) {
        setState(() {
          _imageFront = pickedImage;
        });
      } else if (_imageBack == null) {
        setState(() {
          _imageBack == pickedImage;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('이미 두 이미지가 선택되었습니다.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('이미지 선택'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _imageFront != null
                ? Image.file(File(_imageFront!.path))
                : Text('앞쪽 이미지를 선택하세요.'),
            _imageBack != null
                ? Image.file(File(_imageBack!.path))
                : Text('뒤쪽 이미지를 선택하세요.'),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('이미지 선택'),
            ),
          ],
        ),
      ),
    );
  }
}
