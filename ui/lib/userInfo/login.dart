import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:has_app/main.dart';
import 'package:has_app/userInfo/signup.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _login() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _pwController.text,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage()),
      );
    } catch (e) {
      print('Error : $e');
    }
  }

  void _navigateToSignUP() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignUpScreen()),
    );
    // 회원가입 화면으로 이동하기 위한 함수
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('로그인')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: '이메일'),
            ),
            TextField(
              controller: _pwController,
              decoration: const InputDecoration(labelText: '비밀번호'),
              obscureText: true,
              // 비밀번호는 *로 표시하기 위함
            ),
            Padding(padding: EdgeInsets.only(top: 16.0)),
            ElevatedButton(
              onPressed: _login,
              child: const Text('로그인'),
            ),
            ElevatedButton(
              onPressed: _navigateToSignUP,
              child: const Text('회원가입'),
            ),
          ],
        ),
      ),
    );
  }
}
