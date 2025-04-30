import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 전화번호로 Firebase 인증
  Future<String?> signInWithPhoneNumber(String phoneNumber) async {
    try {
      // Firebase에서 ID 토큰 가져오기
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        return await currentUser.getIdToken();
      }
      return null;
    } catch (e) {
      print('Firebase 인증 에러: $e');
      return null;
    }
  }

  // 로그아웃
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // 현재 사용자의 ID 토큰 가져오기
  Future<String?> getCurrentUserToken() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        return await user.getIdToken();
      }
      return null;
    } catch (e) {
      print('토큰 가져오기 에러: $e');
      return null;
    }
  }
} 