import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'my_page_screen.dart';
import '../../config/api_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../services/user_service.dart';
import '../../services/notice_service.dart';
import '../../services/alert_service.dart';

class NoticeScreen extends StatefulWidget {
  const NoticeScreen({super.key});

  @override
  State<NoticeScreen> createState() => _NoticeScreenState();
}

class _NoticeScreenState extends State<NoticeScreen> {
  // 임시 데이터 제거하고 MyPageScreen의 데이터 참조
  bool isLoading = false;
  
  @override
  void initState() {
    super.initState();
    // 화면 진입 시 최신 공지사항 로드
    _loadNotices();
  }
  
  // 공지사항 데이터를 서버에서 로드
  Future<void> _loadNotices() async {
    setState(() {
      isLoading = true;
    });
    
    try {
      // NoticeService를 사용하여 공지사항 로드
      final notices = await NoticeService.getAllNotices();
      
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('공지사항 로딩 오류: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // 모든 공지사항 읽음 처리 함수
  void _markAllAsRead() {
    // NoticeService를 사용하여 모든 공지사항 읽음 처리
    NoticeService.markAllAsRead();
    
    // UI 상태 업데이트 (기존 로직과의 호환성 유지)
    for (int i = 0; i < MyPageScreen.tempNotices.length; i++) {
      final notice = MyPageScreen.tempNotices[i];
      MyPageScreen.tempNotices[i] = Notice(
        id: notice.id,
        title: notice.title,
        content: notice.content,
        createdAt: notice.createdAt,
        isRead: true,
      );
    }
    
    // 알림 상태 업데이트
    AlertService.updateAlertStatus();
  }

  // 개별 공지사항 읽음 처리 함수
  void _markAsRead(Notice notice) {
    // NoticeService를 사용하여 읽음 처리
    NoticeService.markAsRead(notice.id);
    
    // UI 상태 업데이트 (기존 로직과의 호환성 유지)
    setState(() {
      // 마이페이지의 공지사항 읽음 처리
      for (int i = 0; i < MyPageScreen.tempNotices.length; i++) {
        if (MyPageScreen.tempNotices[i].id == notice.id) {
          MyPageScreen.tempNotices[i] = Notice(
            id: notice.id,
            title: notice.title,
            content: notice.content,
            createdAt: notice.createdAt,
            isRead: true,
          );
          break;
        }
      }
    });
  }

  void _showNoticeDetail(BuildContext context, Notice notice) {
    // 공지사항 열람 시 즉시 읽음 처리
    _markAsRead(notice);
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      notice.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                notice.formattedDate,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textColor.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 16),
              Divider(
                color: AppTheme.textColor.withOpacity(0.1),
                thickness: 1,
              ),
              const SizedBox(height: 16),
              Text(
                notice.content,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // 뒤로가기 버튼 처리
      onWillPop: () async {
        // 화면에서 나갈 때 모든 공지사항을 읽음 처리
        _markAllAsRead();
        return true; // true를 반환하여 뒤로가기 허용
      },
      child: Scaffold(
        backgroundColor: AppTheme.accentColor,
        appBar: AppBar(
          backgroundColor: AppTheme.accentColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: AppTheme.primaryColor,
              size: 20,
            ),
            onPressed: () {
              // 뒤로가기 버튼 클릭 시 명시적으로 읽음 처리 후 화면 닫기
              _markAllAsRead();
              Navigator.pop(context);
            },
          ),
          title: Text(
            '공지사항',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: MyPageScreen.tempNotices.length,
          itemBuilder: (context, index) {
            final notice = MyPageScreen.tempNotices[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    offset: const Offset(0, 2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _showNoticeDetail(context, notice),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.circle_notifications,
                              color: AppTheme.primaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      notice.title,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.textColor,
                                      ),
                                    ),
                                  ),
                                  if (!notice.isRead)
                                    Container(
                                      width: 8,
                                      height: 8,
                                      margin: const EdgeInsets.only(left: 8),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          notice.content.split('\n').first,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textColor.withOpacity(0.7),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 12,
                              color: AppTheme.textColor.withOpacity(0.5),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              notice.formattedDate,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textColor.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
} 