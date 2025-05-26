import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../services/user_service.dart';
import '../services/message_service.dart';

class SeatService {
  static final String baseUrl = ApiConfig.baseUrl;

  // 모든 좌석 현황 조회 (등급별 접근 가능 여부 포함)
  static Future<List<Map<String, dynamic>>> getAllSeats() async {
    try {
      final token = await UserService.getToken();
      if (token == null) {
        throw Exception('인증 토큰이 없습니다.');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/seats'),
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
      
      throw Exception('좌석 현황 조회 실패: ${response.statusCode}');
    } catch (e) {
      print('좌석 현황 조회 중 오류: $e');
      // Mock 데이터 반환
      return _getMockSeatData();
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
        Uri.parse('$baseUrl/seats/zone/$zone'),
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
      
      throw Exception('$zone구역 좌석 조회 실패: ${response.statusCode}');
    } catch (e) {
      print('$zone구역 좌석 조회 중 오류: $e');
      // Mock 데이터에서 해당 구역만 필터링
      return _getMockSeatData().where((seat) => 
        seat['locationCode'].toString().startsWith(zone.toUpperCase())
      ).toList();
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
        Uri.parse('$baseUrl/seats/accessible-zones'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return List<String>.from(data['data']);
        }
      }
      
      throw Exception('접근 가능한 구역 조회 실패: ${response.statusCode}');
    } catch (e) {
      print('접근 가능한 구역 조회 중 오류: $e');
      // 기본값으로 모든 구역 반환
      return ['A', 'B', 'C', 'D'];
    }
  }

  // 특정 좌석으로 쪽지 보내기
  static Future<bool> sendMessageToSeat(int seatId, String content) async {
    // MessageService의 sendToSeat 메서드를 사용하여 중복 제거
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
      case 'D':
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

  // Mock 데이터 생성 (백엔드 API 실패 시 대체용)
  static List<Map<String, dynamic>> _getMockSeatData() {
    List<Map<String, dynamic>> seats = [];
    
    // A구역 (16개) - A등급만 접근 가능
    for (int i = 1; i <= 16; i++) {
      seats.add({
        'seatId': i,
        'locationCode': 'A-$i',
        'status': i % 4 == 0 ? 'EMPTY' : (i % 4 == 1 ? 'SILENT' : (i % 4 == 2 ? 'GOOD' : 'WARNING')),
        'accessible': false, // 기본적으로 접근 불가로 설정 (사용자 등급에 따라 변경)
        'accessibilityMessage': 'A구역은 A등급(조용함) 사용자만 이용 가능합니다.',
      });
    }
    
    // B구역 (21개) - A, B등급 접근 가능
    for (int i = 1; i <= 21; i++) {
      seats.add({
        'seatId': 16 + i,
        'locationCode': 'B-$i',
        'status': i % 4 == 0 ? 'EMPTY' : (i % 4 == 1 ? 'SILENT' : (i % 4 == 2 ? 'GOOD' : 'WARNING')),
        'accessible': true, // B구역은 대부분 접근 가능
        'accessibilityMessage': '접근 가능',
      });
    }
    
    // C구역 (16개) - 모든 등급 접근 가능
    for (int i = 1; i <= 16; i++) {
      seats.add({
        'seatId': 37 + i,
        'locationCode': 'C-$i',
        'status': i % 4 == 0 ? 'EMPTY' : (i % 4 == 1 ? 'SILENT' : (i % 4 == 2 ? 'GOOD' : 'WARNING')),
        'accessible': true,
        'accessibilityMessage': '접근 가능',
      });
    }
    
    // D구역 (11개) - 모든 등급 접근 가능
    for (int i = 1; i <= 11; i++) {
      seats.add({
        'seatId': 53 + i,
        'locationCode': 'D-$i',
        'status': i % 4 == 0 ? 'EMPTY' : (i % 4 == 1 ? 'SILENT' : (i % 4 == 2 ? 'GOOD' : 'WARNING')),
        'accessible': true,
        'accessibilityMessage': '접근 가능',
      });
    }
    
    return seats;
  }

  // 호환성을 위한 별칭 메서드
  static Future<List<Map<String, dynamic>>> getSeatStatus() async {
    return await getAllSeats();
  }
} 