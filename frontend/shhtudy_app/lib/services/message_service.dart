import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../services/user_service.dart';
import '../services/alert_service.dart';
import '../screens/mypage/my_page_screen.dart';

class MessageService {
  static final String baseUrl = ApiConfig.baseUrl;

  // 쪽지 목록 조회 (받은/보낸/전체)
  static Future<List<Map<String, dynamic>>> getMessageList({String type = 'all'}) async {
    try {
      final token = await UserService.getToken();
      if (token == null) {
        throw Exception('인증 토큰이 없습니다.');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/messages?type=$type'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['data'] != null) {
          // 응답 데이터가 content 배열을 포함하는 경우
          if (responseData['data'] is Map && responseData['data']['content'] != null) {
            return List<Map<String, dynamic>>.from(responseData['data']['content']);
          }
          print('메시지 응답이 페이지 형태가 아닙니다');
          return [];
        }
        return [];
      } else if (response.statusCode == 404) {
        // 404 에러는 메시지가 없다는 의미로 처리
        return [];
      }
      
      throw Exception('쪽지 목록 로드 실패: ${response.statusCode}');
    } catch (e) {
      print('쪽지 목록 로드 중 오류: $e');
      // Mock 데이터 반환
      return _getMockMessages(type);
    }
  }

  // 쪽지 상세 조회
  static Future<Map<String, dynamic>?> getMessageDetail(Object messageId) async {
    try {
      final token = await UserService.getToken();
      if (token == null) {
        throw Exception('인증 토큰이 없습니다.');
      }

      // 메시지 ID 타입 검증
      String messageIdStr;
      if (messageId is int) {
        messageIdStr = messageId.toString();
      } else if (messageId is String) {
        messageIdStr = messageId;
      } else {
        throw Exception('유효하지 않은 메시지 ID 타입입니다.');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/messages/$messageIdStr'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['data'] != null) {
          return responseData['data'];
        }
      }
      
      throw Exception('쪽지 상세 조회 실패: ${response.statusCode}');
    } catch (e) {
      print('쪽지 상세 조회 중 오류: $e');
      return null;
    }
  }

  // 쪽지 답장 보내기
  static Future<bool> sendReply(Object messageId, String content) async {
    try {
      final token = await UserService.getToken();
      if (token == null) {
        throw Exception('인증 토큰이 없습니다.');
      }

      // 메시지 ID 타입 검증
      String messageIdStr;
      if (messageId is int) {
        messageIdStr = messageId.toString();
      } else if (messageId is String) {
        messageIdStr = messageId;
      } else {
        throw Exception('유효하지 않은 메시지 ID 타입입니다.');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/messages/$messageIdStr/reply'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'content': content,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      }
      
      throw Exception('답장 전송 실패: ${response.statusCode}');
    } catch (e) {
      print('답장 전송 중 오류: $e');
      return false;
    }
  }

  // 좌석으로 쪽지 보내기
  static Future<bool> sendToSeat(int seatId, String content) async {
    try {
      final token = await UserService.getToken();
      if (token == null) {
        throw Exception('인증 토큰이 없습니다.');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/seats/$seatId/message'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'content': content,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      }
      
      throw Exception('쪽지 전송 실패: ${response.statusCode}');
    } catch (e) {
      print('쪽지 전송 중 오류: $e');
      return false;
    }
  }

  // 읽지 않은 쪽지 수 조회
  static Future<int> getUnreadCount() async {
    try {
      final token = await UserService.getToken();
      if (token == null) {
        throw Exception('인증 토큰이 없습니다.');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/messages/unread-count'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['data'] != null) {
          return responseData['data'] as int;
        }
      }
      
      throw Exception('읽지 않은 쪽지 수 조회 실패: ${response.statusCode}');
    } catch (e) {
      print('읽지 않은 쪽지 수 조회 중 오류: $e');
      throw e;
    }
  }

  // 쪽지 삭제
  static Future<bool> deleteMessage(Object messageId) async {
    try {
      final token = await UserService.getToken();
      if (token == null) {
        throw Exception('인증 토큰이 없습니다.');
      }

      // 메시지 ID 타입 검증
      String messageIdStr;
      if (messageId is int) {
        messageIdStr = messageId.toString();
      } else if (messageId is String) {
        messageIdStr = messageId;
      } else {
        throw Exception('유효하지 않은 메시지 ID 타입입니다.');
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/api/messages/$messageIdStr'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return true;
      }
      
      throw Exception('쪽지 삭제 실패: ${response.statusCode}');
    } catch (e) {
      print('쪽지 삭제 중 오류: $e');
      return false;
    }
  }

  // 쪽지 읽음 처리
  static Future<bool> markAsRead(Object messageId) async {
    try {
      final token = await UserService.getToken();
      if (token == null) {
        throw Exception('인증 토큰이 없습니다.');
      }

      // 메시지 ID 타입 검증
      String messageIdStr;
      if (messageId is int) {
        messageIdStr = messageId.toString();
      } else if (messageId is String) {
        messageIdStr = messageId;
      } else {
        throw Exception('유효하지 않은 메시지 ID 타입입니다.');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/messages/$messageIdStr/read'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return true;
      }
      
      throw Exception('쪽지 읽음 처리 실패: ${response.statusCode}');
    } catch (e) {
      print('쪽지 읽음 처리 중 오류: $e');
      return false;
    }
  }

  // 모든 쪽지 읽음 처리
  static Future<bool> markAllAsRead() async {
    try {
      final token = await UserService.getToken();
      if (token == null) {
        throw Exception('인증 토큰이 없습니다.');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/messages/read-all'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final success = data['success'] == true;
        if (success) {
          // 모든 쪽지 읽음 처리 성공 시 알림 상태 업데이트
          AlertService.updateAlertStatus();
        }
        return success;
      }
      
      throw Exception('모든 쪽지 읽음 처리 실패: ${response.statusCode}');
    } catch (e) {
      print('모든 쪽지 읽음 처리 중 오류: $e');
      return false;
    }
  }

  // Mock 데이터 생성 (백엔드 개발 전 테스트용)
  static List<Map<String, dynamic>> _getMockMessages(String type) {
    final mockMessages = [
      {
        'id': 1,
        'counterpartDisplayName': 'A-3번 (김철수)',
        'contentPreview': '조용히 해주세요.',
        'isRead': false,
        'sentAt': '2024.05.23 14:30',
        'isSentByMe': false,
      },
      {
        'id': 2,
        'counterpartDisplayName': 'B-5번 (이영희)',
        'contentPreview': '네, 죄송합니다.',
        'isRead': true,
        'sentAt': '2024.05.23 13:45',
        'isSentByMe': true,
      },
      {
        'id': 3,
        'counterpartDisplayName': '퇴실한 사용자 (박민수)',
        'contentPreview': '안녕하세요! 혹시 펜 빌려주실 수 있나요?',
        'isRead': true,
        'sentAt': '2024.05.23 12:15',
        'isSentByMe': false,
      },
    ];

    switch (type) {
      case 'received':
        return mockMessages.where((msg) => !(msg['isSentByMe'] as bool)).toList();
      case 'sent':
        return mockMessages.where((msg) => (msg['isSentByMe'] as bool)).toList();
      default:
        return mockMessages;
    }
  }
} 