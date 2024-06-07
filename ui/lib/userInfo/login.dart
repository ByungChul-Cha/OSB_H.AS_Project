import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:has_app/main.dart';
import 'package:has_app/userInfo/signup.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback toggleTheme;

  LoginScreen({required this.toggleTheme});

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
        MaterialPageRoute(builder: (context) => MyHomePage(toggleTheme: widget.toggleTheme)),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'user-not-found') {
        errorMessage = '해당 이메일로 등록된 계정이 없습니다.';
      } else if (e.code == 'wrong-password') {
        errorMessage = '잘못된 비밀번호입니다.';
      } else {
        errorMessage = '로그인 오류가 발생했습니다. 다시 시도해주세요.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
        ),
      );
    } catch (e) {
      //print('Error : $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('로그인 중 알 수 없는 오류가 발생했습니다.'),
        ),
      );
    }
  }

  void _navigateToSignUP() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignUpScreen(toggleTheme: widget.toggleTheme)),
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
            const Padding(padding: EdgeInsets.only(top: 16.0)),
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
