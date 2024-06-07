import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import '../utils/set_server_ip.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String inputText = '';
  String selectedShape = '';
  String selectedType = '';
  String selectedColor = '';

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
            Expanded(
              child: GridView.count(
                crossAxisCount: 6,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                children: [
                  for (final color in [
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
                  ])
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedColor = color;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedColor == color
                            ? Theme.of(context).primaryColor
                            : Colors.grey[300],
                        foregroundColor: selectedColor == color
                            ? Colors.white
                            : Colors.black,
                      ),
                      child: Text(color),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // 입력된 정보로 검색 기능 구현
                _sendSearchDataToServer();
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
      'selectedType': selectedType,
      'selectedColor': selectedColor,
    };

    try {
      final response = await http.post(
        url,
        body: jsonEncode(data),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // 전송 성공
        print('Data sent to server successfully');
      } else {
        // 전송 실패
        print('Failed to send data to server: ${response.statusCode}');
      }
    } catch (e) {
      // 예외 처리
      print('Error sending data to server: $e');
    }
  }
}