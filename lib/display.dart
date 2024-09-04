import 'package:flutter/material.dart';
import 'package:rail_madad/login_screen.dart';

class Display extends StatelessWidget {
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
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/home.png',
              height: 400, // Adjust the image size if needed
              width: 400,
            ), // Space between image and buttons
            Text(
              'Welcome to Rail Madad!',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20), // Space between text and buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  child: Text('Login'),
                ),
                SizedBox(width: 20), // Space between the two buttons
                ElevatedButton(
                  onPressed: () {
                    // Handle button 2 action
                  },
                  child: Text('Sign Up'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
