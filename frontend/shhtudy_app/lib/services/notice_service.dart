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

  // 공지사항 목록 조회
  static Future<List<Notice>> getNotices() async {
    try {
      final token = await UserService.getToken();
      if (token == null) {
        throw Exception('인증 토큰이 없습니다.');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/notices'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print('공지사항 목록 조회 응답 상태 코드: ${response.statusCode}');
      print('공지사항 목록 조회 응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['data'] != null && responseData['data']['content'] != null) {
          final List<dynamic> noticesJson = responseData['data']['content'];
          return noticesJson.map((json) => Notice.fromJson(json)).toList();
        }
        return [];
      }
      
      throw Exception('공지사항 목록 조회 실패: ${response.statusCode}');
    } catch (e) {
      print('공지사항 목록 조회 중 오류: $e');
      throw e;
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
        Uri.parse('$baseUrl/api/notices/$noticeId/read'),
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

  // 공지사항 상세 조회
  static Future<Map<String, dynamic>> getNoticeDetail(int noticeId) async {
    try {
      final token = await UserService.getToken();
      if (token == null) {
        throw Exception('인증 토큰이 없습니다.');
      }

      print('공지사항 상세 조회 요청 ID: $noticeId');
      final response = await http.get(
        Uri.parse('$baseUrl/api/notices/$noticeId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print('공지사항 상세 조회 응답 상태 코드: ${response.statusCode}');
      print('공지사항 상세 조회 응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['data'] != null) {
          return responseData['data'];
        }
        throw Exception('공지사항 상세 데이터가 없습니다.');
      }
      
      throw Exception('공지사항 상세 조회 실패: ${response.statusCode}');
    } catch (e) {
      print('공지사항 상세 조회 중 오류: $e');
      throw e;
    }
  }
} 