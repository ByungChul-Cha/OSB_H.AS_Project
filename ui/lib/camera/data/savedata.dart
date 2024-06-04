import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

Future<void> saveDataToFirebaseStorage(String data) async {
  // Firebase Storage 인스턴스 생성
  FirebaseStorage storage = FirebaseStorage.instance;

  // 저장할 파일의 참조 생성 ('data.json' 파일)
  Reference ref = storage.ref().child('originial_pilldata/data.json');

  // String 타입의 데이터를 byte 데이터로 변환
  List<int> dataBytes = utf8.encode(data);

  // Firebase Storage에 데이터 업로드
  try {
    await ref.putData(Uint8List.fromList(dataBytes));
    print('Data successfully saved to Firebase Storage in folder pilldata');
  } catch (e) {
    print('Failed to save data to Firebase Storage: $e');
  }
}
