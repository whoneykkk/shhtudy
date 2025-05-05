import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'theme/app_theme.dart';
import 'screens/auth/login_screen.dart';

void main() async {
  // Firebase 초기화를 위해 Flutter 엔진과 위젯 바인딩 보장
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase 초기화
  await Firebase.initializeApp();
  // TODO: Firebase Phone Authentication은 추후 구현 예정
  // 현재는 개발/테스트를 위해 이메일/비밀번호 인증 방식 사용
  
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