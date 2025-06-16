import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../config/api_config.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  // SharedPreferences 키 상수
  static const String userProfileKey = 'user_profile';
  static const String authTokenKey = 'auth_token';
  static const String firebaseTokenKey = 'firebase_token';

  // API 기본 URL
  static final String baseUrl = ApiConfig.baseUrl;

  // 로그인 후 사용자 정보 저장
  static Future<void> saveUserProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(userProfileKey, jsonEncode(profile.toJson()));
  }

  // 저장된 사용자 정보 가져오기 (로컬)
  static Future<UserProfile?> getLocalUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = prefs.getString(userProfileKey);
    
    if (profileJson != null) {
      try {
        return UserProfile.fromJson(jsonDecode(profileJson));
      } catch (e) {
        print('사용자 프로필 파싱 오류: $e');
        return null;
      }
    }
    return null;
  }

  // 현재 인증 토큰 가져오기
  static Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(authTokenKey);
  }
  
  // 사용자 정보 가져오기 (서버)
  static Future<UserProfile?> getUserProfile() async {
    try {
      final token = await getAuthToken();
      if (token == null) {
        print('인증 토큰이 없습니다.');
        return null;
      }
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/users/profile'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['data'] != null) {
          final userData = responseData['data'];
          // 사용자 프로필 정보 생성 및 저장
          final userProfile = UserProfile(
            userId: userData['userId'],
            name: userData['name'], 
            nickname: userData['nickname'],
            grade: userData['grade'],
            remainingTime: userData['remainingTime'],
            currentSeat: userData['currentSeat'],
            averageDecibel: userData['averageDecibel'] != null 
                ? double.parse(userData['averageDecibel'].toString())
                : 0.0,
            noiseOccurrence: userData['noiseOccurrence'] ?? 0,
            mannerScore: userData['mannerScore'] ?? 100,
            points: userData['points'] ?? 500,
            phoneNumber: userData['phoneNumber'] ?? '',
          );
          // 로컬에도 저장 - 캐싱용으로만 유지
          await saveUserProfile(userProfile);
          return userProfile;
        }
      }
      print('사용자 프로필 조회 실패: ${response.statusCode}, ${response.body}');
      return null;
    } catch (e) {
      print('사용자 프로필 조회 중 오류: $e');
      return null;
    }
  }
  
  // 로그아웃
  static Future<bool> logout() async {
    try {
      // Firebase 로그아웃
      await FirebaseAuth.instance.signOut();
      
      // SharedPreferences에서 모든 사용자 관련 데이터 삭제
      final prefs = await SharedPreferences.getInstance();
      
      // 필수 로그인 정보 삭제
      await prefs.remove(userProfileKey);
      await prefs.remove(authTokenKey);
      await prefs.remove(firebaseTokenKey);
      
      // 추가 정보 삭제
      await prefs.remove('user_id');
      await prefs.remove('user_name');
      
      // 자동 로그인 설정 해제
      await prefs.setBool('auto_login', false);
      
      return true;
    } catch (e) {
      print('로그아웃 중 오류: $e');
      return false;
    }
  }

  // 사용자가 로그인되어 있는지 확인
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(authTokenKey);
  }
  
  // 토큰 저장
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(authTokenKey, token);
  }
  
  // 토큰 가져오기
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(authTokenKey);
  }
}