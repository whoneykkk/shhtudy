import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'theme/app_theme.dart';
import 'screens/auth/login_screen.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    print('Firebase 초기화 성공');
  } catch (e) {
    print('Firebase 초기화 실패: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shh-Tudy',
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
    );
  }
} 