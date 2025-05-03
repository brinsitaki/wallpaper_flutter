import 'dart:async';

import 'package:flutter/material.dart';
import 'package:marnihub/screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  static final String routeName = "/splash_screen";
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Color(0xff424242),
      body: SafeArea(
          child: Column(
        children: [
          Spacer(),
          Center(
            child: Image.asset(
              "images/logo.png",
              width: MediaQuery.of(context).size.width / 4,
            ),
          ),
          Text(
            "MarniHub",
            style: TextStyle(
              //color: Colors.red,
              color: Color(0xFFAD4716),
              fontSize: 32.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          Spacer(),
          Text(
            "Created by",
            style: TextStyle(color: Color(0xFF590E8F)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 16.0,
            ),
            child: Text(
              "Brinsi Mohamed Taki Allah",
              style: TextStyle(
                color: Color(0xFF4C0DA3),
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      )),
    );
  }
}
