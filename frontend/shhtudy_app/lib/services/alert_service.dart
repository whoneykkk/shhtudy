import 'package:shared_preferences/shared_preferences.dart';
import '../screens/mypage/my_page_screen.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../services/user_service.dart';

/**
 * 알림 관리 서비스
 * 
 * 공지사항과 쪽지(향후 구현)의 읽지 않은 상태를 관리하며,
 * 다른 화면에서 알림 상태 변화를 구독할 수 있는 스트림을 제공합니다.
 */
class AlertService {
  // 알림 상태 변화를 구독할 수 있는 스트림 컨트롤러
  static final StreamController<bool> _alertStreamController = StreamController<bool>.broadcast();
  
  // 알림 상태 변화를 구독할 수 있는 스트림
  static Stream<bool> get alertStream => _alertStreamController.stream;
  
  // API 기본 URL
  static final String baseUrl = ApiConfig.baseUrl;
  
  /**
   * 읽지 않은 알림이 있는지 확인 (공지사항 + 쪽지)
   * 로컬 데이터 기반으로 확인합니다.
   */
  static bool hasUnreadAlerts() {
    // 1. 읽지 않은 공지사항 확인
    bool hasUnreadNotices = MyPageScreen.tempNotices.any((notice) => !notice.isRead);
    
    // 2. 읽지 않은 쪽지 확인 (쪽지 기능 구현 전이라면 무시됨)
    bool hasUnreadMessages = MyPageScreen.tempMessages.any((message) => !message.isRead && !message.isSent);
    
    // 둘 중 하나라도 있으면 true 반환
    return hasUnreadNotices || hasUnreadMessages;
  }

  /**
   * 알림 상태를 캐시에 저장
   */
  static Future<void> cacheAlertStatus(bool hasUnread) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_unread_alerts', hasUnread);
  }

  /**
   * 캐시된 알림 상태 확인
   */
  static Future<bool> getCachedAlertStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('has_unread_alerts') ?? false;
  }

  /**
   * 현재 알림 상태 업데이트, 캐시 및 알림
   * 가능하면 백엔드 API를 호출하고, 실패 시 로컬 상태를 사용합니다.
   */
  static Future<bool> updateAlertStatus() async {
    try {
      // 백엔드 API를 통해 알림 상태 확인
      final token = await UserService.getToken();
      if (token != null) {
        try {
          final response = await http.get(
            Uri.parse('$baseUrl/api/alerts/unread-status'),
            headers: {
              'Authorization': 'Bearer $token',
            },
          ).timeout(const Duration(seconds: 3));
          
          if (response.statusCode == 200) {
            final Map<String, dynamic> data = json.decode(response.body);
            if (data['success'] == true && data['data'] != null) {
              final hasUnread = data['data']['hasUnreadMessages'] ?? false;
              await cacheAlertStatus(hasUnread);
              _alertStreamController.add(hasUnread);
              return hasUnread;
            }
          }
        } catch (e) {
          print('알림 상태 업데이트 API 호출 오류: $e');
        }
      }
    } catch (e) {
      print('알림 상태 업데이트 중 오류: $e');
    }
    
    // API 호출 실패 시 로컬 상태 사용 (기존 방식)
    final bool hasUnread = hasUnreadAlerts();
    await cacheAlertStatus(hasUnread);
    _alertStreamController.add(hasUnread);
    return hasUnread;
  }
  
  // 서비스 정리 함수
  static void dispose() {
    _alertStreamController.close();
  }
} 