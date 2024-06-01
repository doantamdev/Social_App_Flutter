import 'package:flutter/material.dart';
import 'package:social_app/stream/myStream.dart';

import 'Utils/global.dart';
import 'Views/RootScreen.dart';

void main() {
  Global.myStream = MyStream();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Social App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const RootScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
