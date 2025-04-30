import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _apiService = ApiService();
  final _auth = FirebaseAuth.instance;

  Future<void> _signUp() async {
    try {
      final name = _nameController.text;
      final phone = _phoneController.text;
      final password = _passwordController.text;
      final passwordConfirm = _passwordConfirmController.text;

      // 입력값 검증
      if (name.isEmpty || phone.isEmpty || password.isEmpty || passwordConfirm.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('모든 필드를 입력해주세요')),
        );
        return;
      }

      if (password != passwordConfirm) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('비밀번호가 일치하지 않습니다')),
        );
        return;
      }

      // 임시 Firebase 토큰 생성 (실제 계정은 아직 생성하지 않음)
      final tempAuth = await _auth.createUserWithEmailAndPassword(
        email: phone.replaceAll('-', '') + "@shhtudy.com",
        password: password,
      );

      final idToken = await tempAuth.user?.getIdToken();
      if (idToken == null) throw Exception('Firebase token is null');

      try {
        // 백엔드 회원가입 API 호출
        await _apiService.signUp(
          name: name,
          phone: phone,
          password: password,
          idToken: idToken,
        );

        // 회원가입 성공 시 로그인 화면으로 이동
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('회원가입이 완료되었습니다')),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      } catch (e) {
        // 백엔드 회원가입 실패 시 Firebase 계정 삭제
        await tempAuth.user?.delete();
        throw e;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('회원가입 실패: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              // 로고
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.menu_book,
                      size: 48,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'shh-tudy',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const Text(
                      '조용한 집중을 위한 공간',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              // 이름 입력
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.accentColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: '이름을 입력해주세요',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                    prefixIcon: Icon(
                      Icons.person,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // 전화번호 입력
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.accentColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    hintText: '전화번호를 입력해주세요',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                    prefixIcon: Icon(
                      Icons.phone,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // 비밀번호 입력
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.accentColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: '비밀번호를 입력해주세요',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                    prefixIcon: Icon(
                      Icons.lock,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // 비밀번호 확인
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.accentColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _passwordConfirmController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: '비밀번호를 다시 입력해주세요',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // 회원가입 버튼
              ElevatedButton(
                onPressed: _signUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  '회원가입',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // 로그인 링크
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Center(
                    child: Text.rich(
                      TextSpan(
                        text: '이미 계정이 있으신가요? ',
                        style: TextStyle(
                          color: AppTheme.textColor,
                        ),
                        children: [
                          TextSpan(
                            text: '로그인',
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 