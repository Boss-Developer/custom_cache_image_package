import 'package:custom_cached_image/custom_cached_image.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('Custom Cached Image Example')),
        body: Center(
          child: CustomCachedImage(
            imageUrl: 'https://ichef.bbci.co.uk/ace/standard/976/cpsprodpb/14235/production/_100058428_mediaitem100058424.jpg',
            width: 200,
            height: 200, borderRadius: 15,
          ),
        ),
      ),
    );
  }
}
