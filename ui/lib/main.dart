import 'package:cloud_firestore/cloud_firestore.dart';
import 'camera/camera.dart';
import 'community/community.dart';
import 'search/search.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import "package:flutter/material.dart";
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:has_app/utils/userInfo/login.dart';
import 'package:cloud_functions/cloud_functions.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pill Search',
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: MyHomePage(toggleTheme: _toggleTheme),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final VoidCallback toggleTheme;

  MyHomePage({required this.toggleTheme});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String userName = '사용자';
  String userEmail = '이메일';
  String profileImageUrl = '';
  File? _image;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      deleteSplitPillDataFolder();
    });

    fetchUserData();
  }

  Future<void> fetchUserData() async {
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
          profileImageUrl = userData['profileImageUrl'] ?? '';
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('선택된 이미지 없음');
      }
    });
  }

  Future<void> _uploadImage() async {
    if (_image == null) return;

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String fileName = 'profile_${user.uid}.png';
        Reference firebaseStorageRef =
            FirebaseStorage.instance.ref().child('profile_images/$fileName');
        UploadTask uploadTask = firebaseStorageRef.putFile(_image!);
        TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
        String downloadURL = await taskSnapshot.ref.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'profileImageUrl': downloadURL});

        setState(() {
          profileImageUrl = downloadURL;
        });

        print("프로필 사진 URL: $downloadURL");
      }
    } catch (e) {
      print('이미지 업로드 오류: $e');
    }
  } //프로필 사진 업로드 코드

    Future<void> _deleteImage() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String fileName = 'profile_${user.uid}.png';
        Reference firebaseStorageRef =
            FirebaseStorage.instance.ref().child('profile_images/$fileName');
        await firebaseStorageRef.delete();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'profileImageUrl': ''});

        setState(() {
          profileImageUrl = '';
        });

        print("프로필 사진 삭제");
      }
    } catch (e) {
      print('프로필 사진 삭제 오류: $e');
    }
  } //프로필 사진 삭제 코드

   void _showProfileDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('프로필 사진 삭제'),
          content: const Text('프로필 사진을 기본으로 설정하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              child: const Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('확인'),
              onPressed: () async {
                await _deleteImage();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  } //프로필 사진 삭제 여부를 묻는 팝업

  void _showThemeChangeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('테마 변경'),
          content: const Text('테마를 변경하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              child: const Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('확인'),
              onPressed: () {
                widget.toggleTheme();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  } //테마 변경 여부를 묻는 팝업

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pill Search'),
        //앱 상단에 뜨는 이름
        centerTitle: true,
        //이름을 중앙에 배치
        elevation: 0.0,
        //앱 바의 그림자 효과를 없앰
        titleTextStyle: const TextStyle(color: Colors.white),
        //타이틀의 색깔 설정
        backgroundColor: Colors.blue,
        //앱 바의 배경 색 설정
        actions: [
          IconButton(
            icon: Icon(Icons.brightness_6),
            onPressed: _showThemeChangeDialog,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/image/pill.png',
              width: 100,
              height: 100,
            ),
            const SizedBox(height: 20),
            const Text(
              'Pill Search',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              '개발자 : 차병철, 이민재',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            const Text(
              '개발 기간 : 2024년 1학기 충북대학교 오픈소스 기초프로젝트',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              currentAccountPicture: GestureDetector(
                onTap: () async {
                  await _pickImage();
                  await _uploadImage();
                },
                onLongPress: () {
                  if (profileImageUrl.isNotEmpty) {
                     _showProfileDialog();
                  }
                },
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage: profileImageUrl.isNotEmpty
                      ? NetworkImage(profileImageUrl)
                      : null,
                  child: profileImageUrl.isEmpty
                      ? Icon(
                          Icons.account_circle,
                          size: 70.0,
                          color: Colors.grey,
                        )
                      : null,
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
                          title: const Text('로그아웃'),
                          content: const Text('로그아웃 하시겠습니까?'),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('취소'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: const Text('확인'),
                              onPressed: () {
                                FirebaseAuth.instance.signOut();
                                Navigator.of(context).pop();
                                Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                        builder: (context) => LoginScreen(toggleTheme: widget.toggleTheme)));
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
              focusColor: Colors.grey,
              title: const Text('이름으로 검색'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SearchPage()));
              },
              trailing: const Icon(Icons.navigate_next),
            ),
            //메뉴에 식별 검색 창을 만듦

            ListTile(
              leading: const Icon(Icons.photo_camera),
              iconColor: Colors.black,
              focusColor: Colors.grey,
              title: const Text('카메라로 검색'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ImageTextSource()));
              },
              trailing: const Icon(Icons.navigate_next),
            ),
            //메뉴에 카메라로 검색 창을 만듦

            ListTile(
              leading: const Icon(Icons.chat),
              iconColor: Colors.black,
              focusColor: Colors.grey,
              title: const Text('커뮤니티'),
              onTap: () {
                Navigator.push(context,
                 MaterialPageRoute(builder: (context) => Community()));
              },
              trailing: const Icon(Icons.navigate_next),
            ),
            //메뉴에 커뮤니티 창을 만듦
          ],
        ),
      ),
      //메뉴 버튼을 만듦
    );
  }
}

Future<void> deleteSplitPillDataFolder() async {
  try {
    final functions = FirebaseFunctions.instance;
    final HttpsCallable callable =
        functions.httpsCallable('deleteSplitPillDataFolder');
    await callable.call();
    print('split_pilldata folder deleted successfully');
  } catch (e) {
    print('Error deleting split_pilldata folder: $e');
  }
}
