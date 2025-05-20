import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'signup_screen.dart';
import '../home/home_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/user_profile.dart';
import '../../services/user_service.dart';
import '../../config/api_config.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isAutoLogin = false;
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Firebase로 로그인하고 토큰을 발급받는 함수
  Future<String?> _signInWithFirebase() async {
    try {
      // TODO: 실제 전화번호 인증(Firebase Phone Authentication)은 추후 구현 예정
      // 현재는 개발/테스트를 위해 전화번호를 이메일 형식으로 변환하여 인증
      final String email = "${phoneController.text}@shhtudy.com";
      print('Firebase 로그인 시도 - 이메일: $email');
      
      // Firebase로 로그인
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: passwordController.text,
      );
      
      print('Firebase 로그인 성공 - 사용자: ${userCredential.user?.uid}');
      
      // ID 토큰 획득
      final String? idToken = await userCredential.user?.getIdToken();
      print('Firebase 토큰 발급 성공 - 토큰 길이: ${idToken?.length ?? 0}');
      return idToken;
    } catch (e) {
      print('Firebase 로그인 오류: $e');
      // 오류 코드를 분석하여 사용자에게 더 명확한 피드백 제공
      String errorMessage = '로그인에 실패했습니다.';
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'user-not-found':
            errorMessage = '등록되지 않은 사용자입니다. 먼저 회원가입을 해주세요.';
            break;
          case 'wrong-password':
            errorMessage = '비밀번호가 일치하지 않습니다.';
            break;
          case 'invalid-credential':
            errorMessage = '로그인 정보가 잘못되었거나 만료되었습니다.';
            break;
          default:
            errorMessage = '로그인 오류: ${e.code}';
        }
      }     
// 오류 메시지를 컨텍스트 대신 변수에 저장 (컨텍스트는 이 비동기 함수에서 사용 불가)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      return null;
    }
  }

  Future<void> login() async {
    // 입력값 검증
    if (phoneController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('전화번호와 비밀번호를 모두 입력해주세요.')),
      );
      return;
    }
    
    setState(() {
      isLoading = true;
    });

    try {
      // Firebase로 로그인하고 토큰 발급받기
      print('Firebase 로그인 시작');
      final String? firebaseToken = await _signInWithFirebase();
      
      // Firebase 인증 실패 시
      if (firebaseToken == null) {
        setState(() {
          isLoading = false;
        });
        return; // 에러 메시지는 _signInWithFirebase에서 처리
      }
      
      // 토큰 디버깅
      print('Firebase 토큰 발급 완료');
      print('토큰 길이: ${firebaseToken.length}');
      print('토큰 미리보기: ${firebaseToken.substring(0, math.min(20, firebaseToken.length))}...');
      
      // 마지막으로 사용한 전화번호 저장
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_phone_number', phoneController.text);
      
      // 백엔드 서버로 요청 보내기
      final url = Uri.parse('${ApiConfig.baseUrl}/auth/login');
      print('로그인 요청 URL: $url');
      
      try {
        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $firebaseToken'
          },
          body: jsonEncode({
            'phoneNumber': phoneController.text,
            'password': passwordController.text,
          }),
        ).timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            print('로그인 요청 타임아웃 (30초)');
            throw TimeoutException('서버 응답이 너무 오래 걸립니다. 나중에 다시 시도해주세요.');
          },
        );

        print('로그인 요청 완료');
        print('응답 상태 코드: ${response.statusCode}');
        print('응답 본문: "${response.body}"');

        if (!mounted) return; // 위젯이 아직 마운트 상태인지 확인
        
        setState(() {
          isLoading = false;
        });

        if (response.body.isNotEmpty) {
          final data = jsonDecode(response.body);
          
          if (response.statusCode == 200 && data['success'] == true && data['data'] != null) {
            // 로그인 성공
            final userData = data['data'];
            
            // 토큰 저장
            await UserService.saveToken(userData['token']);
            await prefs.setString('firebase_token', firebaseToken);
            await prefs.setString('user_id', userData['userId']);
            
            if (isAutoLogin) {
              await prefs.setBool('auto_login', true);
            }

            print('로그인 성공: ${data['message']}');
            
            // 홈 화면으로 이동
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          } else {
            // 데이터가 예상한 형식이 아니거나 성공이 아닌 경우
            final message = data['message'] ?? "알 수 없는 오류가 발생했습니다.";
            print('로그인 실패: $message');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('로그인 실패: $message')),
            );
            
            // Firebase 로그아웃 처리
            try {
              await _auth.signOut();
            } catch (e) {
              print('Firebase 로그아웃 오류: $e');
            }
          }
        } else if (response.statusCode == 401) {
          // 401 Unauthorized 오류 특별 처리
          print('로그인 실패: 인증 오류 (401)');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('로그인 실패: 아이디 또는 비밀번호가 일치하지 않습니다.')),
          );
          
          // Firebase 로그아웃 처리
          try {
            await _auth.signOut();
          } catch (e) {
            print('Firebase 로그아웃 오류: $e');
          }
        } else {
          // 기타 응답 오류
          print('로그인 실패: 서버 응답 오류 (${response.statusCode})');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('로그인 실패: 서버 오류 (${response.statusCode})')),
          );
          
          // Firebase 로그아웃 처리
          try {
            await _auth.signOut();
          } catch (e) {
            print('Firebase 로그아웃 오류: $e');
          }
        }
      } catch (e) {
        if (!mounted) return;
        
        setState(() {
          isLoading = false;
        });
        
        // 사용자에게 보여줄 오류 메시지 결정
        String errorMessage = '네트워크 오류가 발생했습니다. 다시 시도해주세요.';
        if (e is TimeoutException) {
          errorMessage = '서버 응답 시간이 초과되었습니다. 나중에 다시 시도해주세요.';
        } else if (e.toString().contains('Connection refused') || 
                  e.toString().contains('Connection closed')) {
          errorMessage = '서버 연결에 실패했습니다. 서버가 실행 중인지 확인해주세요.';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
        
        // Firebase 로그아웃 처리
        try {
          await _auth.signOut();
        } catch (logoutError) {
          print('Firebase 로그아웃 오류: $logoutError');
        }
      }
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        isLoading = false;
      });
      
      print('예상치 못한 오류: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인 중 오류가 발생했습니다: $e')),
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
              // 전화번호 입력
              TextField(
                controller: phoneController,
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
              const SizedBox(height: 16),
              // 비밀번호 입력
              TextField(
                controller: passwordController,
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
              const SizedBox(height: 8),
              // 자동 로그인
              Row(
                children: [
                  Checkbox(
                    value: isAutoLogin,
                    onChanged: (value) {
                      setState(() {
                        isAutoLogin = value ?? false;
                      });
                    },
                    activeColor: AppTheme.primaryColor,
                  ),
                  Text(
                    '자동 로그인',
                    style: TextStyle(
                      color: AppTheme.textColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // 로그인 버튼
              ElevatedButton(
                onPressed: isLoading ? null : login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isLoading 
                  ? const SizedBox(
                      width: 20, 
                      height: 20, 
                      child: CircularProgressIndicator(
                        color: Colors.white, 
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      '로그인',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              ),
              const SizedBox(height: 16),
              // 회원가입 링크
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const SignUpScreen()),
                  );
                },
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Center(
                    child: Text.rich(
                      TextSpan(
                        text: '아직 회원이 아니신가요? ',
                        style: TextStyle(
                          color: AppTheme.textColor,
                        ),
                        children: [
                          TextSpan(
                            text: '회원가입하기',
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