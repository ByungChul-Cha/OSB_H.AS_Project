import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'camera.dart';
import 'community.dart';
import 'search.dart';
import 'settings.dart';
// 플러터의 위젯이랑 각종 기능들을 사용하기 위해 입력

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'H.AS App',
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
        title: const Text('H.AS Medi App'),
        //앱 상단에 뜨는 이름
        centerTitle: true,
        //이름을 중앙에 배치
        elevation: 0.0,
        //앱 바의 그림자 효과를 없앰
        titleTextStyle: const TextStyle(color: Colors.white),
        //타이틀의 색깔 설정
        backgroundColor: Colors.blue,
        //앱 바의 배경 색 설정
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const UserAccountsDrawerHeader(
              currentAccountPicture: CircleAvatar(
                backgroundImage: AssetImage('assets/image/images.jpg'),
              ),
              accountName: Text("테스트용"),
              accountEmail: Text('test@test.com'),
              decoration: BoxDecoration(
                color: Colors.lightBlue,
              ),
            ),
            //유저 정보 그려주는 코드

            ListTile(
              leading: const Icon(Icons.search),
              iconColor: Colors.black,
              focusColor: Colors.black,
              title: const Text('식별 검색'),
              onTap: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Search()));
              },
              trailing: const Icon(Icons.navigate_next),
            ),
            //메뉴에 식별 검색 창을 만듦

            ListTile(
              leading: const Icon(Icons.photo_camera),
              iconColor: Colors.black,
              focusColor: Colors.black,
              title: const Text('카메라로 검색'),
              onTap: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Camera()));
              },
              trailing: const Icon(Icons.navigate_next),
            ),
            //메뉴에 카메라로 검색 창을 만듦

            ListTile(
              leading: const Icon(Icons.chat),
              iconColor: Colors.black,
              focusColor: Colors.black,
              title: const Text('커뮤니티'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Community()));
              },
              trailing: const Icon(Icons.navigate_next),
            ),
            //메뉴에  커뮤니티 창을 만듦

            ListTile(
              leading: const Icon(Icons.settings),
              iconColor: Colors.black,
              focusColor: Colors.black,
              title: const Text('환경설정'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Settings()));
              },
              trailing: const Icon(Icons.navigate_next),
            ),
            //메뉴에 환경설정 창을 만듦
          ],
        ),
      ),
      //메뉴 버튼을 만듦
    );
  }
}
