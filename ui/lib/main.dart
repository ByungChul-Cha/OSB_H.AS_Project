import 'package:cloud_firestore/cloud_firestore.dart';

import 'camera.dart';
import 'community/community.dart';
import 'search.dart';
// 플러터의 위젯이랑 각종 기능들을 사용하기 위해 입력
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import "package:flutter/material.dart";
import 'package:has_app/userInfo/login.dart';

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

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String userName = '사용자';
  String userEmail = '이메일';

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  void fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        setState(() {
          userName = userData['name'] ?? '이름 없음';
          userEmail = userData['email'] ?? '이메일 없음';
        });
      }
    }
  }

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
            UserAccountsDrawerHeader(
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.account_circle,
                  size: 70.0,
                  color: Colors.grey,
                ),
              ),
              accountName: Text(userName),
              accountEmail: Text(userEmail),
              decoration: const BoxDecoration(
                color: Colors.lightBlue,
              ),
              otherAccountsPictures: <Widget>[
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('로그아웃'),
                          content: Text('로그아웃 하시겠습니까?'),
                          actions: <Widget>[
                            TextButton(
                              child: Text('취소'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: Text('확인'),
                              onPressed: () {
                                FirebaseAuth.instance.signOut();
                                Navigator.of(context).pop();
                                Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                        builder: (context) => LoginScreen()));
                              },
                            )
                          ],
                        );
                      },
                    );
                  },
                  child: const CircleAvatar(
                    backgroundColor: Colors.lightBlue,
                    child: Icon(Icons.exit_to_app, color: Colors.white),
                  ),
                ),
              ],
            ),
            //유저 정보 그려주는 코드
            ListTile(
              leading: const Icon(Icons.search),
              iconColor: Colors.black,
              focusColor: Colors.black,
              title: const Text('이름으로 검색'),
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
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => CameraApp()));
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
          ],
        ),
      ),
      //메뉴 버튼을 만듦
    );
  }
}
