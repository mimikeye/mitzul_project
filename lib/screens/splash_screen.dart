import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
      super.initState();

      Timer(const Duration(milliseconds: 2500), () {
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const Scaffold(
              backgroundColor: AppColors.ivory,
              body: Center(
                child: Text('로그인 화면 준비 중'),
              ),
            ),
          ),
        );
      });
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.5, 1.0],
                colors: [
                  AppColors.ivory,
                  AppColors.green,
                ],
              ),
            ),
          ),

          Positioned(
            left: 177,
            top: 308,
            child: Image.asset(
              'assets/images/title_star.png',
              width: 214,
              height: 522,
              fit: BoxFit.contain,
            ),
          ),

          Positioned(
            left: 125,
            top: 264,
            child: Image.asset(
              'assets/images/logowtext.png',
              width: 162,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}
