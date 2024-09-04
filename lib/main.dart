import 'package:flutter/material.dart';
import 'package:rail_madad/chatbot.dart';
import 'package:rail_madad/homepage.dart';
import 'package:rail_madad/splash1.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Rail Madad',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => Splash(),
        '/home': (context) => HomePage(),
      },
    );
  }
}
