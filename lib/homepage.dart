import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rail_madad/chatbot.dart';
import 'package:rail_madad/login_screen.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Color _currentColor = Colors.orangeAccent;

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startColorSwitching();
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  void _startColorSwitching() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _currentColor = _currentColor == Colors.orangeAccent
            ? Color.fromARGB(255, 137, 2, 49)
            : Colors.orangeAccent;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(
              'assets/navbar_logo.png',
              height: 40,
            ),
          ],
        ),
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  duration:
                      Duration(seconds: 1), // Duration of color transition
                  decoration: BoxDecoration(
                    color: _currentColor, // Use the current color
                    borderRadius:
                        BorderRadius.circular(8), // Optional: rounded corners
                  ),
                  child: const Row(
                    mainAxisSize:
                        MainAxisSize.min, // Wrap content inside the container
                    children: [
                      Icon(
                        Icons.phone_in_talk_rounded, // Ringing phone icon
                        color: Colors.white,
                        size: 24, // Adjust size if needed
                      ),
                      SizedBox(width: 8), // Spacing between icon and text
                      Text(
                        '139',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  'for Security/Medical Assistance',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Image.asset(
              './assets/home.png',
              height: 400,
              width: 400,
            ),
            const Text(
              'Welcome to the Rail Madad!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Image.asset('assets/navbar_logo.png'),
              decoration: BoxDecoration(
                color: Colors.white,
              ),
            ),
            ListTile(
              title: Text('Logout'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
            ),
            ListTile(
              title: Text('Register Complaint'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ChatbotScreen()),
                );
              },
            ),
            ListTile(
              title: Text('Other Services'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
