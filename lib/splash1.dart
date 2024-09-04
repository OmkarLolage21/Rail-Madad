import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:rail_madad/splash2.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedSplashScreen(
        splash: Image.asset(
          'assets/load.png',
          height: 600,
          width: 600,
        ),
        backgroundColor: Colors.white,
        nextScreen: Splash2(),
        splashTransition: SplashTransition.slideTransition,
        duration: 1000,
      ),
    );
  }
}
