import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CommunityPostEdit extends StatefulWidget {
  final DocumentSnapshot post;

  CommunityPostEdit({required this.post});

  @override
  _CommunityPostEditState createState() => _CommunityPostEditState();
}

class _CommunityPostEditState extends State<CommunityPostEdit> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.post['title']);
    _contentController = TextEditingController(text: widget.post['content']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('포스트 수정'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                FirebaseFirestore.instance
                    .collection('posts')
                    .doc(widget.post.id)
                    .update({
                  'title': _titleController.text,
                  'content': _contentController.text,
                }).then((_) {
                  Navigator.pop(context);
                });
              }
            },
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: '제목'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '제목을 입력해주세요.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(labelText: '내용'),
                maxLines: 10,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '내용을 입력해주세요.';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
