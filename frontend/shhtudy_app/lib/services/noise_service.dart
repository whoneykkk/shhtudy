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

  // 소음 세션 로그 조회 (API 명세서 기반)
  static Future<List<Map<String, dynamic>>> getNoiseSessionLogs() async {
    try {
      final token = await UserService.getToken();
      if (token == null) {
        throw Exception('인증 토큰이 없습니다.');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/noise-logs'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
      
      throw Exception('소음 로그 조회 실패: ${response.statusCode}');
    } catch (e) {
      print('소음 로그 조회 중 오류: $e');
      // Mock 데이터 반환
      return _getMockNoiseLogs();
    }
  }

  // 기존 getNoiseLogs 메소드는 호환성을 위해 유지
  static Future<List<Map<String, dynamic>>> getNoiseLogs() async {
    return await getNoiseSessionLogs();
  }

  // 내 좌석의 실시간 소음 레벨 가져오기 (아직 API 없어서 더미 데이터 반환)
  static Future<int> getCurrentNoiseLevel() async {
    try {
      // 실제 API 호출 (향후 구현)
      // final response = await http.get(Uri.parse('$baseUrl/noise/current'));
      
      // 임시로 랜덤 값 반환 (35-55dB 범위)
      return 35 + (DateTime.now().millisecondsSinceEpoch % 21);
    } catch (e) {
      print('현재 소음 레벨 가져오기 오류: $e');
      return 40; // 기본값
    }
  }

  // Mock 소음 로그 데이터 생성
  static List<Map<String, dynamic>> _getMockNoiseLogs() {
    final now = DateTime.now();
    return [
      {
        'sessionId': 1,
        'startTime': now.subtract(Duration(hours: 2)).toIso8601String(),
        'endTime': now.subtract(Duration(hours: 1, minutes: 30)).toIso8601String(),
        'averageDecibel': 42,
        'maxDecibel': 58,
        'noiseExceededCount': 3,
        'seatCode': 'A-4',
      },
      {
        'sessionId': 2,
        'startTime': now.subtract(Duration(hours: 5)).toIso8601String(),
        'endTime': now.subtract(Duration(hours: 3, minutes: 45)).toIso8601String(),
        'averageDecibel': 38,
        'maxDecibel': 45,
        'noiseExceededCount': 0,
        'seatCode': 'A-4',
      },
      {
        'sessionId': 3,
        'startTime': now.subtract(Duration(days: 1, hours: 2)).toIso8601String(),
        'endTime': now.subtract(Duration(days: 1, hours: 1)).toIso8601String(),
        'averageDecibel': 45,
        'maxDecibel': 62,
        'noiseExceededCount': 5,
        'seatCode': 'B-2',
      },
    ];
  }

  // 실시간 소음 모니터링 시작 (향후 구현)
  static Future<void> startNoiseMonitoring(Function(int) onNoiseLevel) async {
    // TODO: 마이크 권한 요청 및 실시간 소음 측정
    // _noiseCallback = onNoiseLevel;
    // _isListening = true;
    print('소음 모니터링 시작 (구현 예정)');
  }

  // 실시간 소음 모니터링 중지 (향후 구현)
  static Future<void> stopNoiseMonitoring() async {
    // TODO: 소음 측정 중지
    // _isListening = false;
    // _noiseCallback = null;
    print('소음 모니터링 중지 (구현 예정)');
  }

  // 소음 데이터 서버에 전송 (향후 구현)
  static Future<bool> sendNoiseData(int decibelLevel) async {
    try {
      final token = await UserService.getToken();
      if (token == null) {
        throw Exception('인증 토큰이 없습니다.');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/noise/record'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'decibelLevel': decibelLevel,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['success'] == true;
      }
      
      return false;
    } catch (e) {
      print('소음 데이터 전송 중 오류: $e');
      return false;
    }
  }
} 