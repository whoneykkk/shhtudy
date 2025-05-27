import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'services/user_service.dart';

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
      home: const SplashScreen(), // 자동 로그인 체크를 위한 스플래시 화면
    );
  }
}

// 자동 로그인 체크를 위한 스플래시 화면
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAutoLogin();
  }

  Future<void> _checkAutoLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final autoLogin = prefs.getBool('auto_login') ?? false;
      final hasToken = await UserService.isLoggedIn();

      // 2초간 스플래시 화면 표시
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      if (autoLogin && hasToken) {
        // 자동 로그인 설정이 되어있고 토큰이 있으면 홈 화면으로
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        // 자동 로그인 설정이 없거나 토큰이 없으면 로그인 화면으로
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (e) {
      print('자동 로그인 체크 오류: $e');
      // 오류 발생 시 로그인 화면으로 이동
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu_book,
              size: 80,
              color: const Color(0xFF7FB77E),
            ),
            const SizedBox(height: 16),
            const Text(
              'shh-tudy',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: Color(0xFF7FB77E),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '조용한 집중을 위한 공간',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              color: Color(0xFF7FB77E),
            ),
          ],
        ),
      ),
    );
  }
} 