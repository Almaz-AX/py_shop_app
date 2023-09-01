import 'dart:io';

import 'package:flutter/material.dart';

class PostScreen extends StatelessWidget {
  final String imagePath;
  final String comment;
  final double? longitude;
  final double? latitude;

  const PostScreen(
      {super.key,
      required this.imagePath,
      required this.comment,
      this.longitude,
      this.latitude});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Пост')),
      body: ListView(padding: const EdgeInsets.all(8),
        children: [
        Image.file(File(imagePath)),
        const SizedBox(
          height: 20,
        ),
        if (comment.isNotEmpty)Text('comment: $comment'),
        const SizedBox(
          height: 15,
        ),
        if (longitude != null && latitude != null) Text('latitude: $latitude; longitude: $longitude'),
      ]),
    );
  }
}
