import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:rail_madad/display.dart';
import 'package:rail_madad/homepage.dart';

class Splash2 extends StatefulWidget {
  const Splash2({super.key});

  @override
  State<Splash2> createState() => _SplashState2();
}

class _SplashState2 extends State<Splash2> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedSplashScreen(
          splash: Image.asset(
            'assets/faltu.png',
            height: 600,
            width: 600,
          ),
          backgroundColor: Colors.white,
          nextScreen: Display(),
          splashTransition: SplashTransition.slideTransition,
          duration: 1000),
    );
  }
}
