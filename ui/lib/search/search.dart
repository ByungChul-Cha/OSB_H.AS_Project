import 'dart:convert';
import 'package:has_app/result/search_result_screen.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import '../community/community.dart';
import '../utils/set_server_ip.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String inputText = '';
  String selectedShape = '';
  String selectedColor = '';
  Map<String, dynamic> serverResponse = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('약 정보 입력'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              onChanged: (value) {
                setState(() {
                  inputText = value;
                });
              },
              decoration: const InputDecoration(
                hintText: '약에 적힌 문자 입력',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            const Text(
              '모양 선택',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                for (final shape in [
                  '원형',
                  '장방형',
                  '타원형',
                  '반원형',
                  '삼각형',
                  '사각형',
                  '마름모형',
                  '오각형',
                  '육각형',
                  '팔각형',
                  '기타',
                ])
                  ChoiceChip(
                    label: Text(shape),
                    selected: selectedShape == shape,
                    onSelected: (isSelected) {
                      setState(() {
                        selectedShape = isSelected ? shape : '';
                      });
                    },
                  ),
              ],
            ),
            const SizedBox(height: 16.0),
            const Text(
              '색깔 선택',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            Flexible(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemCount: 16,
                itemBuilder: (context, index) {
                  final color = [
                    '하양',
                    '노랑',
                    '주황',
                    '분홍',
                    '빨강',
                    '갈색',
                    '연두',
                    '초록',
                    '청록',
                    '파랑',
                    '남색',
                    '자주',
                    '보라',
                    '회색',
                    '검정',
                    '투명'
                  ][index];
                  final buttonColor = [
                    Colors.white,
                    Colors.yellow,
                    Colors.orange,
                    Colors.pink,
                    Colors.red,
                    Colors.brown,
                    Colors.lightGreen,
                    Colors.green,
                    Colors.teal,
                    Colors.blue,
                    Colors.blueAccent,
                    Colors.purple,
                    Colors.purple,
                    Colors.grey,
                    Colors.black,
                    const Color.fromRGBO(255, 255, 255, 0.5),
                  ][index];
                  final textColor = buttonColor.computeLuminance() > 0.5
                      ? Colors.black
                      : Colors.white;
                  return ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedColor = color;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedColor == color
                          ? Theme.of(context).primaryColor
                          : buttonColor,
                      foregroundColor:
                          selectedColor == color ? Colors.white : textColor,
                    ),
                    child: Text(color),
                  );
                },
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // 입력된 정보로 검색 기능 구현
                if (inputText.isNotEmpty &&
                    selectedShape.isNotEmpty &&
                    selectedColor.isNotEmpty) {
                  _sendSearchDataToServer();
                } else {
                  // 필요한 입력 값이 모두 채워지지 않은 경우 사용자에게 알림 표시
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('모든 입력 값을 채워주세요.'),
                    ),
                  );
                }
              },
              child: const Text('검색'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendSearchDataToServer() async {
    final url = Uri.parse('$desktopServerIP/name_search');
    final data = {
      'inputText': inputText,
      'selectedShape': selectedShape,
      'selectedColor': selectedColor,
    };
    print(inputText);
    print(selectedShape);
    print(selectedColor);
    try {
      final response = await http.post(
        url,
        body: jsonEncode(data),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // 전송 성공
        print('Data sent to server successfully');
        print(response.body);
        setState(() {
          serverResponse = jsonDecode(response.body);
        });
        if (serverResponse['item_seq'] != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SearchResultScreen(
                itemSeq: serverResponse['item_seq'],
              ),
            ),
          );
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('알림'),
                content: const Text('약을 찾을 수 없습니다. 커뮤니티 페이지로 이동하시겠습니까?'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Community(), // 커뮤니티 페이지로 이동
                        ),
                      );
                    },
                    child: const Text('예'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('아니오'),
                  ),
                ],
              );
            },
          );
        }
      } else {
        print('Failed to send data to server: ${response.statusCode}');
      }
    } catch (e) {
      // 예외 처리
      print('Error sending data to server: $e');
    }
  }
}
