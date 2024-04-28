import 'package:flutter/material.dart';
// 플러터의 위젯이랑 각종 기능들을 사용하기 위해 입력

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'H.AS app',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('H.AS Medi App'),
        //앱 상단에 뜨는 이름
        leading: Icon(Icons.menu, color: Colors.white),
        //메뉴 버튼의 아이콘, 색깔 설정
        titleTextStyle: TextStyle(color: Colors.white),
        //타이틀의 색깔 설정
        backgroundColor: Colors.blue,
        //앱 바의 배경 색 설정
      ),
    );
  }
}
