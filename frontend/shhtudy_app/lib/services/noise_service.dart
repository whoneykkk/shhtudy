import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_profile.dart';
import '../config/api_config.dart';
import '../services/user_service.dart';
// import 'package:flutter/services.dart';  // 향후 마이크 플랫폼 채널 사용 시 필요

class NoiseService {
  // API 기본 URL
  static final String baseUrl = ApiConfig.baseUrl;
  static const String noiseLogsKey = 'noise_logs_cache';
  
  // 마이크 채널 및 관련 변수 (향후 구현 시 주석 해제)
  // static const MethodChannel _channel = MethodChannel('com.shhtudy.microphone');
  // static Function(int)? _noiseCallback;
  // static bool _isListening = false;

  // 소음 통계 데이터 가져오기
  static Future<Map<String, dynamic>?> getNoiseStats() async {
    try {
      // 사용자 프로필에서 소음 데이터 확인
      final UserProfile? userProfile = await UserService.getUserProfile();
      
      if (userProfile != null) {
        // 사용자 프로필에서 소음 관련 데이터 추출
        return {
          'grade': userProfile.grade,
          'averageDecibel': userProfile.averageDecibel,
          'noiseOccurrence': userProfile.noiseOccurrence,
          'currentSeat': userProfile.currentSeat,
        };
      }
      
      // 데이터가 없는 경우 기본값 반환
      return {
        'grade': 'GOOD',
        'averageDecibel': 0.0,
        'noiseOccurrence': 0,
        'currentSeat': '--',
      };
    } catch (e) {
      print('소음 통계 데이터 가져오기 오류: $e');
      // 오류 발생 시 기본값 반환
      return {
        'grade': 'GOOD',
        'averageDecibel': 0.0,
        'noiseOccurrence': 0,
        'currentSeat': '--',
      };
    }
  }

  // 내 좌석의 실시간 소음 레벨 가져오기 (아직 API 없어서 더미 데이터 반환)
  static Future<int?> getCurrentNoiseLevel() async {
    try {
      final userProfile = await UserService.getUserProfile();
      
      // 좌석이 없으면 null 반환
      if (userProfile?.currentSeat == null) {
        return null;
      }
      
      // TODO: 실제 구현 시 외부 마이크 모듈 초기화 코드 추가
      // 예시: await _initMicrophoneModule();
      
      // API 구현 시 주석 해제
      /*
      final token = await UserService.getAuthToken();
      if (token == null) {
        return null;
      }
      
      final response = await http.get(
        Uri.parse('$baseUrl/noise/current'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return data['data']['level'];
        }
      }
      
      print('실시간 소음 레벨 가져오기 실패: ${response.statusCode}, ${response.body}');
      */
      
      // 임시로 랜덤한 소음 레벨 생성 (30~60 사이)
      final DateTime now = DateTime.now();
      // 시간에 따라 약간 변동하는 값 생성 (테스트용)
      final int baseLevel = 40;
      final int variation = (now.second % 10) - 5; // -5~+4 범위의 변동값
      final int randomLevel = baseLevel + variation;
      
      return randomLevel;
    } catch (e) {
      print('실시간 소음 레벨 가져오기 오류: $e');
      return null;
    }
  }

  // 소음 로그 가져오기 (아직 API 없어서 더미 데이터 반환)
  static Future<List<Map<String, dynamic>>> getNoiseLogs() async {
    try {
      final token = await UserService.getAuthToken();
      
      // 토큰이 없으면 캐시 데이터 반환
      if (token == null) {
        return _getDummyData();
      }
      
      // API 구현 시 주석 해제
      /*
      final response = await http.get(
        Uri.parse('$baseUrl/noise/logs'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> logs = data['data'];
          
          // 캐시에 저장
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(noiseLogsKey, jsonEncode(logs));
          
          return logs.cast<Map<String, dynamic>>();
        }
      }
      
      print('소음 로그 가져오기 실패: ${response.statusCode}, ${response.body}');
      return _getDummyData();
      */
      
      // API 연동 전에는 더미 데이터 반환
      return _getDummyData();
    } catch (e) {
      print('소음 로그 가져오기 오류: $e');
      return _getDummyData();
    }
  }
  
  // 더미 데이터 생성 (API 연동 전 테스트용)
  static List<Map<String, dynamic>> _getDummyData() {
    final now = DateTime.now();
    
    return [
      {
        'level': 55,
        'isExceeded': true,
        'timestamp': DateTime(now.year, now.month, now.day, 14, 32).toIso8601String(),
      },
      {
        'level': 48,
        'isExceeded': false,
        'timestamp': DateTime(now.year, now.month, now.day, 13, 45).toIso8601String(),
      },
      {
        'level': 42,
        'isExceeded': false,
        'timestamp': DateTime(now.year, now.month, now.day, 12, 15).toIso8601String(),
      },
      {
        'level': 37,
        'isExceeded': false,
        'timestamp': DateTime(now.year, now.month, now.day, 10, 30).toIso8601String(),
      },
      {
        'level': 51,
        'isExceeded': true,
        'timestamp': DateTime(now.year, now.month, now.day, 9, 15).toIso8601String(),
      },
    ];
  }

  // TODO: 외부 마이크 연동을 위한 메서드 (향후 구현 예정)
  /*
  // 마이크 모듈 초기화
  static Future<bool> _initMicrophoneModule() async {
    try {
      final bool result = await _channel.invokeMethod('initMicrophone');
      return result;
    } catch (e) {
      print('마이크 모듈 초기화 오류: $e');
      return false;
    }
  }
  
  // 실시간 소음 레벨 리스너 설정
  static Future<bool> listenToNoiseLevel(Function(int) callback) async {
    if (_isListening) {
      // 이미 리스닝 중인 경우 콜백만 업데이트
      _noiseCallback = callback;
      return true;
    }
    
    try {
      _noiseCallback = callback;
      
      // 네이티브 쪽 리스너 설정
      await _channel.invokeMethod('startListening');
      
      // 리스닝 이벤트 설정
      _channel.setMethodCallHandler((call) async {
        if (call.method == 'onNoiseLevel') {
          final int level = call.arguments as int;
          if (_noiseCallback != null) {
            _noiseCallback!(level);
          }
        }
      });
      
      _isListening = true;
      return true;
    } catch (e) {
      print('소음 레벨 리스너 설정 오류: $e');
      return false;
    }
  }
  
  // 리스너 정리
  static Future<void> disposeListener() async {
    if (!_isListening) return;
    
    try {
      await _channel.invokeMethod('stopListening');
      _isListening = false;
      _noiseCallback = null;
    } catch (e) {
      print('소음 레벨 리스너 정리 오류: $e');
    }
  }
  */
} 