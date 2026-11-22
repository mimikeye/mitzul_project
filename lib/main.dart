import 'package:flutter/material.dart';
import 'constants/app_colors.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const MitzulApp());
}

class MitzulApp extends StatelessWidget {
  const MitzulApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '밑줄',
      theme: ThemeData(
        fontFamily: 'Pretendard',
        scaffoldBackgroundColor: AppColors.ivory,
        primaryColor: AppColors.green,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.green,
          surface: AppColors.ivory,
        ),
      ),
      home: const SplashScreen()
    );
  }
}
