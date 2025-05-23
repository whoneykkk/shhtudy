import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../config/api_config.dart';
import '../services/user_service.dart';
import '../screens/mypage/my_page_screen.dart';

class NoticeService {
  // API 기본 URL
  static final String baseUrl = ApiConfig.baseUrl;

  // 모든 공지사항 가져오기
  static Future<List<Notice>> getAllNotices() async {
    try {
      final token = await UserService.getToken();
      if (token == null) {
        throw Exception('인증 토큰이 없습니다.');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/notices'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> noticesJson = data['data'];
          
          // 정적 리스트 업데이트 (기존 코드와의 호환성 유지)
          MyPageScreen.tempNotices = noticesJson.map((json) {
            return Notice.fromJson(json);
          }).toList();
          
          return MyPageScreen.tempNotices;
        }
      }
      
      throw Exception('공지사항 로드 실패: ${response.statusCode}');
    } catch (e) {
      print('공지사항 로드 중 오류: $e');
      return [];
    }
  }

  // 개별 공지사항 읽음 처리
  static Future<bool> markAsRead(int noticeId) async {
    try {
      final token = await UserService.getToken();
      if (token == null) {
        throw Exception('인증 토큰이 없습니다.');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/notices/$noticeId/read'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // UI 상태 업데이트 (기존 코드와의 호환성 유지)
        for (int i = 0; i < MyPageScreen.tempNotices.length; i++) {
          if (MyPageScreen.tempNotices[i].id == noticeId) {
            MyPageScreen.tempNotices[i] = Notice(
              id: MyPageScreen.tempNotices[i].id,
              title: MyPageScreen.tempNotices[i].title,
              content: MyPageScreen.tempNotices[i].content,
              createdAt: MyPageScreen.tempNotices[i].createdAt,
              isRead: true,
            );
            break;
          }
        }
        return true;
      }
      return false;
    } catch (e) {
      print('공지사항 읽음 처리 중 오류: $e');
      return false;
    }
  }

  // 모든 공지사항 읽음 처리
  static Future<bool> markAllAsRead() async {
    try {
      final token = await UserService.getToken();
      if (token == null) {
        throw Exception('인증 토큰이 없습니다.');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/notices/read-all'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // UI 상태 업데이트 (기존 코드와의 호환성 유지)
        for (int i = 0; i < MyPageScreen.tempNotices.length; i++) {
          MyPageScreen.tempNotices[i] = Notice(
            id: MyPageScreen.tempNotices[i].id,
            title: MyPageScreen.tempNotices[i].title,
            content: MyPageScreen.tempNotices[i].content,
            createdAt: MyPageScreen.tempNotices[i].createdAt,
            isRead: true,
          );
        }
        return true;
      }
      return false;
    } catch (e) {
      print('모든 공지사항 읽음 처리 중 오류: $e');
      return false;
    }
  }
} 