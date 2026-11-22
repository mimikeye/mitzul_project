import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_colors.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(
      const Duration(milliseconds: 2500),
    );

    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();

    final autoLogin = prefs.getBool('autoLogin') ?? false;
    final currentUser = FirebaseAuth.instance.currentUser;

    if (autoLogin && currentUser != null) {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const TemporaryHomeScreen(),
        ),
      );
    } else {
      if (currentUser != null && !autoLogin) {
        await FirebaseAuth.instance.signOut();
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );
    }
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

// 메인 화면 구현 전 임시 화면
class TemporaryHomeScreen extends StatelessWidget {
  const TemporaryHomeScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('autoLogin', false);

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '밑줄',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                '로그인에 성공했습니다.',
                style: TextStyle(
                  color: AppColors.subText,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: () => _logout(context),
                child: const Text('로그아웃'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
