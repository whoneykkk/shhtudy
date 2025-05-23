import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'login_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;
import 'dart:async';
// Firebase 패키지 임포트
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController userIdController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  // Firebase Auth 인스턴스
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = false;

  // Firebase로 사용자 등록 후 토큰을 받아오는 함수
  Future<String?> _registerWithFirebase() async {
    try {
      // TODO: 실제 전화번호 인증(Firebase Phone Authentication)은 추후 구현 예정
      // 현재는 개발/테스트를 위해 전화번호를 이메일 형식으로 변환하여 인증
      final String email = "${phoneController.text}@shhtudy.com"; // 임시 이메일 생성 방식
      
      print('Firebase 회원가입 시도 - 이메일: $email');
      
      // Firebase Auth로 계정 생성
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: passwordController.text,
      );
      
      print('Firebase 계정 생성 성공 - 사용자 UID: ${userCredential.user?.uid}');
      
      // 사용자 프로필 업데이트
      await userCredential.user?.updateDisplayName(nameController.text);
      
      // ID 토큰 가져오기
      final String? idToken = await userCredential.user?.getIdToken();
      print('Firebase 토큰 발급 성공 - 토큰 길이: ${idToken?.length ?? 0}');
      return idToken;
      
    } catch (e) {
      print('Firebase 인증 오류: $e');
      
      // 상세한 오류 메시지 처리
      String errorMessage = '회원가입에 실패했습니다.';
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'email-already-in-use':
            errorMessage = '이미 등록된 사용자입니다.';
            break;
          case 'invalid-email':
            errorMessage = '유효하지 않은 이메일 형식입니다.';
            break;
          case 'weak-password':
            errorMessage = '비밀번호가 너무 약합니다.';
            break;
          case 'operation-not-allowed':
            errorMessage = '이메일/비밀번호 로그인이 비활성화되어 있습니다.';
            break;
          default:
            errorMessage = 'Firebase 오류: ${e.code}';
        }
      }
      
      // 오류 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
      return null;
    }
  }

  Future<void> signUp() async {
    // 로딩 상태 시작
    setState(() {
      isLoading = true;
    });
    
    // Firebase 사용자 참조 변수 추가
    User? firebaseUser;
    
    try {
      // 모바일 테스트용 IP 주소 사용
      // 실제 디바이스: 'http://192.168.219.118:8080/users'
      // 안드로이드 에뮬레이터: 'http://10.0.2.2:8080/users'
      final url = Uri.parse('http://10.0.2.2:8080/users');
      print('회원가입 요청 URL: $url');
      
      // 비밀번호와 확인 비밀번호 일치 여부 확인
      if (passwordController.text != confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('비밀번호와 확인 비밀번호가 일치하지 않습니다.')),
        );
        setState(() {
          isLoading = false;
        });
        return;
      }
      
      // 입력값 유효성 검사
      if (nameController.text.isEmpty || userIdController.text.isEmpty ||
          phoneController.text.isEmpty || passwordController.text.isEmpty || 
          confirmPasswordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('모든 필드를 입력해주세요.')),
        );
        setState(() {
          isLoading = false;
        });
        return;
      }
      
      // Firebase에 사용자 등록하고 토큰 받기
      print('Firebase 사용자 등록 시작');
      final String? firebaseToken = await _registerWithFirebase();
      firebaseUser = _auth.currentUser; // 생성된 사용자 참조 저장
      
      // 토큰이 없으면 오류 처리
      if (firebaseToken == null) {
        setState(() {
          isLoading = false;
        });
        return;
      }
      
      // 토큰 디버깅 정보
      print('Firebase 토큰 발급 완료');
      print('토큰 길이: ${firebaseToken.length}');
      print('토큰 미리보기: ${firebaseToken.substring(0, math.min(20, firebaseToken.length))}...');
      
      // 백엔드 서버로 요청 보내기
      print('백엔드 서버로 회원가입 요청 시작');
      
      try {
        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $firebaseToken',
          },
          body: jsonEncode({
            'name': nameController.text,
            'nickname': userIdController.text,
            'phoneNumber': phoneController.text,
            'password': passwordController.text,
            'confirmPassword': confirmPasswordController.text,
          }),
        ).timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            print('회원가입 요청 타임아웃 (30초)');
            throw TimeoutException('서버 응답이 너무 오래 걸립니다. 나중에 다시 시도해주세요.');
          },
        );
        
        // 응답 디버깅
        print('회원가입 요청 완료');
        print('응답 상태 코드: ${response.statusCode}');
        print('응답 본문: "${response.body}"');
        print('응답 헤더: ${response.headers}');

        // 로딩 상태 종료
        setState(() {
          isLoading = false;
        });

        try {
          // 응답 본문이 비어 있지 않은 경우만 파싱
          if (response.body.isNotEmpty) {
            final responseData = jsonDecode(response.body);
            
            if (response.statusCode == 200 && responseData['success'] == true) {
              // 회원가입 성공
              print('회원가입 성공!');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('회원가입이 완료되었습니다. 로그인해주세요.')),
              );
              
              // 로그인 화면으로 이동
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            } else {
              // 응답 코드가 200이 아니거나 success가 false인 경우
              final message = responseData['message'] ?? "알 수 없는 오류가 발생했습니다.";
              print('회원가입 실패: $message');
              
              // 백엔드 저장 실패 시 Firebase 사용자 삭제
              if (firebaseUser != null) {
                try {
                  await firebaseUser.delete();
                  print('Firebase 사용자 삭제 완료');
                } catch (e) {
                  print('Firebase 사용자 삭제 실패: $e');
                }
              }
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('회원가입 실패: $message')),
              );
            }
          } else {
            // 응답 본문이 비어 있는 경우
            print('회원가입 실패: 빈 응답 (${response.statusCode})');
            
            // 백엔드 저장 실패 시 Firebase 사용자 삭제
            if (firebaseUser != null) {
              try {
                await firebaseUser.delete();
                print('Firebase 사용자 삭제 완료');
              } catch (e) {
                print('Firebase 사용자 삭제 실패: $e');
              }
            }
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('회원가입 실패: 서버 응답이 비어 있습니다 (${response.statusCode})')),
            );
          }
        } catch (e) {
          // JSON 파싱 오류 등의 예외 처리
          print('응답 처리 오류: $e, 상태 코드: ${response.statusCode}, 응답 본문: "${response.body}"');
          
          // 백엔드 저장 실패 시 Firebase 사용자 삭제
          if (firebaseUser != null) {
            try {
              await firebaseUser.delete();
              print('Firebase 사용자 삭제 완료');
            } catch (deleteError) {
              print('Firebase 사용자 삭제 실패: $deleteError');
            }
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('회원가입 실패: 서버 응답 처리 중 오류 (${response.statusCode})')),
          );
        }
      } catch (e) {
        print('회원가입 요청 중 오류 발생: $e');
        
        // 백엔드 저장 실패 시 Firebase 사용자 삭제
        if (firebaseUser != null) {
          try {
            await firebaseUser.delete();
            print('Firebase 사용자 삭제 완료');
          } catch (deleteError) {
            print('Firebase 사용자 삭제 실패: $deleteError');
          }
        }
        
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
      }
    } catch (e) {
      // 네트워크 오류 등 HTTP 요청 자체의 예외 처리
      print('회원가입 요청 중 오류 발생: $e');
      
      // 백엔드 저장 실패 시 Firebase 사용자 삭제
      if (firebaseUser != null) {
        try {
          await firebaseUser.delete();
          print('Firebase 사용자 삭제 완료');
        } catch (deleteError) {
          print('Firebase 사용자 삭제 실패: $deleteError');
        }
      }
      
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('네트워크 오류: $e')),
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
                  controller: nameController,
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
              // 사용자 닉네임 입력
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.accentColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: userIdController,
                  decoration: InputDecoration(
                    hintText: '닉네임을 입력해주세요 (2자 이상)',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                    prefixIcon: Icon(
                      Icons.account_circle,
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
              ),
              const SizedBox(height: 16),
              // 비밀번호 입력
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.accentColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
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
              ),
              const SizedBox(height: 16),
              // 비밀번호 확인
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.accentColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: confirmPasswordController,
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
                onPressed: isLoading ? null : signUp,
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