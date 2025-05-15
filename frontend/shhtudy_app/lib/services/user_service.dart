import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../config/api_config.dart';

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
        Uri.parse('$baseUrl/users/profile'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final userData = data['data'];
          // 사용자 프로필 정보 생성 및 저장
          final userProfile = UserProfile(
            userId: userData['userId'],
            name: userData['name'], 
            userAccountId: userData['userAccountId'],
            grade: userData['grade'],
            remainingTime: userData['remainingTime'],
            currentSeat: userData['currentSeat'],
            averageDecibel: userData['averageDecibel'] != null 
                ? double.parse(userData['averageDecibel'].toString())
                : 0.0,
            noiseOccurrence: userData['noiseOccurrence'] ?? 0,
            mannerScore: userData['mannerScore'] ?? 0,
            points: userData['points'] ?? 0,
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
      final token = await getAuthToken();
      
      // 서버에 로그아웃 요청 (토큰이 있는 경우만)
      if (token != null) {
        try {
          // 네트워크 문제가 있더라도 계속 진행하기 위해 try-catch로 감싸기
          final response = await http.post(
            Uri.parse('$baseUrl/users/logout'),
            headers: {
              'Authorization': 'Bearer $token',
            },
          ).timeout(const Duration(seconds: 5)); // 짧은 타임아웃 설정
          
          print('로그아웃 응답 코드: ${response.statusCode}');
        } catch (e) {
          print('서버 로그아웃 요청 실패 (로컬 정리는 계속 진행): $e');
        }
      }
      
      // SharedPreferences에서 모든 사용자 관련 데이터 삭제
      final prefs = await SharedPreferences.getInstance();
      
      // 필수 로그인 정보 삭제
      await prefs.remove(userProfileKey);
      await prefs.remove(authTokenKey);
      await prefs.remove(firebaseTokenKey);
      
      // 추가 정보 삭제 (전체 초기화는 아님)
      await prefs.remove('user_id');
      await prefs.remove('user_name');
      
      // 자동 로그인 설정 해제 (마지막 사용 전화번호는 유지)
      await prefs.setBool('auto_login', false);
      
      return true;
    } catch (e) {
      print('로그아웃 중 오류: $e');
      // 오류 발생해도 최소한의 로컬 데이터는 삭제 시도
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(userProfileKey);
        await prefs.remove(authTokenKey);
        await prefs.remove(firebaseTokenKey);
      } catch (innerError) {
        print('로그아웃 오류 후 로컬 데이터 삭제 중 추가 오류: $innerError');
      }
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