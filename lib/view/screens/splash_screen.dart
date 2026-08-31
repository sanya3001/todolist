import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth ઉમેર્યું
import 'login_screen.dart';
import 'todo_screen.dart'; // TodoScreen ઉમેર્યું

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;

      // Firebase mathi chcek kare k user login che k nai
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        // jo login hoi to sidha todoscreen per jasho
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const TodoScreen(),
          ),
        );
      } else {
        // જો લોગિન ના હોય તો LoginScreen પર જશે
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/images/img.png',
          width: 150,
          height: 150,
        ),
      ),
    );
  }
}