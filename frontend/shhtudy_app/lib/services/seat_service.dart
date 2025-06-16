import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../services/user_service.dart';
import '../services/message_service.dart';

class SeatService {
  static final String baseUrl = ApiConfig.baseUrl;
  static Timer? _refreshTimer;
  static final _seatController = StreamController<List<Map<String, dynamic>>>.broadcast();
  static Stream<List<Map<String, dynamic>>> get seatStream => _seatController.stream;

  // 자동 갱신 시작
  static void startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      try {
        final seats = await getAllSeats();
        _seatController.add(seats);
      } catch (e) {
        print('좌석 자동 갱신 중 오류: $e');
      }
    });
  }

  // 자동 갱신 중지
  static void stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  // 모든 좌석 현황 조회 (등급별 접근 가능 여부 포함)
  static Future<List<Map<String, dynamic>>> getAllSeats() async {
    try {
      final token = await UserService.getToken();
      if (token == null) {
        throw Exception('인증 토큰이 없습니다.');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/seats'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['data'] != null) {
          return List<Map<String, dynamic>>.from(responseData['data']);
        }
      }
      
      throw Exception('좌석 현황 조회 실패: ${response.statusCode}');
    } catch (e) {
      print('좌석 현황 조회 중 오류: $e');
      throw e;
    }
  }

  // 구역별 좌석 조회
  static Future<List<Map<String, dynamic>>> getSeatsByZone(String zone) async {
    try {
      final token = await UserService.getToken();
      if (token == null) {
        throw Exception('인증 토큰이 없습니다.');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/seats/zone/$zone'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['data'] != null) {
          return List<Map<String, dynamic>>.from(responseData['data']);
        }
      }
      
      throw Exception('$zone구역 좌석 조회 실패: ${response.statusCode}');
    } catch (e) {
      print('$zone구역 좌석 조회 중 오류: $e');
      throw e;
    }
  }

  // 접근 가능한 구역 목록 조회
  static Future<List<String>> getAccessibleZones() async {
    try {
      final token = await UserService.getToken();
      if (token == null) {
        throw Exception('인증 토큰이 없습니다.');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/seats/accessible-zones'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['data'] != null) {
          return List<String>.from(responseData['data']);
        }
      }
      
      throw Exception('접근 가능한 구역 조회 실패: ${response.statusCode}');
    } catch (e) {
      print('접근 가능한 구역 조회 중 오류: $e');
      throw e;
    }
  }

  // 특정 좌석으로 쪽지 보내기
  static Future<bool> sendMessageToSeat(int seatId, String content) async {
    return await MessageService.sendToSeat(seatId, content);
  }

  // 등급별 접근 가능 여부 확인 (클라이언트 사이드 검증)
  static bool canAccessZone(String zone, String userGrade) {
    switch (zone.toUpperCase()) {
      case 'A':
        return userGrade.toUpperCase() == 'SILENT'; // A등급만
      case 'B':
        return ['SILENT', 'GOOD'].contains(userGrade.toUpperCase()); // A, B등급만
      case 'C':
      case 'F':
        return true; // 모든 등급
      default:
        return false;
    }
  }

  // 등급별 접근 메시지 반환
  static String getAccessibilityMessage(String zone, String userGrade) {
    if (canAccessZone(zone, userGrade)) {
      return '접근 가능';
    }
    
    switch (zone.toUpperCase()) {
      case 'A':
        return 'A구역은 A등급(조용함) 사용자만 이용 가능합니다.';
      case 'B':
        return 'B구역은 A등급(조용함), B등급(양호) 사용자만 이용 가능합니다.';
      default:
        return '아직 접근할 수 없는 구역입니다.';
    }
  }

  // 호환성을 위한 별칭 메서드
  static Future<List<Map<String, dynamic>>> getSeatStatus() async {
    return await getAllSeats();
  }
} 