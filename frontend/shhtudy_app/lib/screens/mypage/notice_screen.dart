import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'my_page_screen.dart';

class NoticeScreen extends StatefulWidget {
  const NoticeScreen({super.key});

  @override
  State<NoticeScreen> createState() => _NoticeScreenState();
}

class _NoticeScreenState extends State<NoticeScreen> {
  // 임시 공지사항 데이터 - 실제로는 API로 가져온 데이터 사용 예정
  static final List<Notice> tempNotices = [
    Notice(
      id: 1, 
      title: '시스템 점검 안내', 
      content: '안녕하세요. Shh-tudy 입니다.\n\n서비스 안정화를 위한 시스템 점검이 진행될 예정입니다.\n\n점검 일시: 2024년 3월 20일 02:00 ~ 06:00\n점검 내용: 서버 안정화 및 성능 개선\n\n더 나은 서비스를 제공하도록 하겠습니다.\n감사합니다.',
      createdAt: DateTime(2024, 3, 19),
      isRead: false,
    ),
    Notice(
      id: 2, 
      title: '신규 기능 업데이트', 
      content: '안녕하세요. Shh-tudy 입니다.\n\n새로운 기능이 추가되었습니다.\n\n1. 실시간 소음 알림\n2. 좌석 이용 통계\n3. UI/UX 개선\n\n많은 이용 부탁드립니다.\n감사합니다.',
      createdAt: DateTime(2024, 3, 15),
      isRead: false,
    ),
    Notice(
      id: 3, 
      title: '좌석 예약 시스템 개선 안내', 
      content: '안녕하세요. Shh-tudy 입니다.\n\n좌석 예약 시스템이 개선되었습니다.\n\n- 선호 좌석 등록 기능\n- 예약 자동 연장 기능\n- 빠른 좌석 변경 기능\n\n더 편리한 서비스로 찾아뵙겠습니다.\n감사합니다.',
      createdAt: DateTime(2024, 3, 10),
      isRead: false,
    ),
    Notice(
      id: 4, 
      title: '소음 측정 알고리즘 개선', 
      content: '안녕하세요. Shh-tudy 입니다.\n\n소음 측정 알고리즘이 개선되었습니다.\n\n- 더 정확한 소음 레벨 측정\n- 소음 패턴 분석 기능 추가\n- 개인화된 소음 허용 범위 설정\n\n더 쾌적한 스터디 환경을 제공하겠습니다.\n감사합니다.',
      createdAt: DateTime(2024, 3, 5),
      isRead: false,
    ),
    Notice(
      id: 5, 
      title: '앱 버전 업데이트 안내 (v1.2.0)', 
      content: '안녕하세요. Shh-tudy 입니다.\n\n앱 버전이 업데이트 되었습니다.\n\n- 성능 개선 및 버그 수정\n- 디자인 리뉴얼\n- 신규 통계 기능 추가\n\n더 나은 서비스로 찾아뵙겠습니다.\n감사합니다.',
      createdAt: DateTime(2024, 2, 28),
      isRead: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    // 화면 진입 시에는 읽음 처리하지 않음
  }

  // 모든 공지사항 읽음 처리 함수
  void _markAllAsRead() {
    // 실제 구현에서는 API 호출하여 서버에 읽음 상태 업데이트 필요
    for (int i = 0; i < tempNotices.length; i++) {
      final notice = tempNotices[i];
      tempNotices[i] = Notice(
        id: notice.id,
        title: notice.title,
        content: notice.content,
        createdAt: notice.createdAt,
        isRead: true,
      );
    }
    
    // 마이페이지의 공지사항도 읽음 처리
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
  }

  // 개별 공지사항 읽음 처리 함수
  void _markAsRead(Notice notice) {
    // 실제 구현에서는 API 호출하여 서버에 읽음 상태 업데이트 필요
    setState(() {
      // 현재 화면의 공지사항 읽음 처리
      for (int i = 0; i < tempNotices.length; i++) {
        if (tempNotices[i].id == notice.id) {
          tempNotices[i] = Notice(
            id: notice.id,
            title: notice.title,
            content: notice.content,
            createdAt: notice.createdAt,
            isRead: true,
          );
          break;
        }
      }
      
      // 마이페이지의 공지사항도 읽음 처리
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
        body: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: tempNotices.length,
          itemBuilder: (context, index) {
            final notice = tempNotices[index];
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