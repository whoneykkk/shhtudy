import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'my_page_screen.dart';

class NoticeScreen extends StatelessWidget {
  const NoticeScreen({super.key});

  // 임시 공지사항 데이터
  final List<Notice> tempNotices = const [
    Notice(
      id: '1', 
      title: '시스템 점검 안내', 
      content: '안녕하세요. Shh-tudy 입니다.\n\n서비스 안정화를 위한 시스템 점검이 진행될 예정입니다.\n\n점검 일시: 2024년 3월 20일 02:00 ~ 06:00\n점검 내용: 서버 안정화 및 성능 개선\n\n더 나은 서비스를 제공하도록 하겠습니다.\n감사합니다.',
      date: '2024.03.19',
    ),
    Notice(
      id: '2', 
      title: '신규 기능 업데이트', 
      content: '안녕하세요. Shh-tudy 입니다.\n\n새로운 기능이 추가되었습니다.\n\n1. 실시간 소음 알림\n2. 좌석 이용 통계\n3. UI/UX 개선\n\n많은 이용 부탁드립니다.\n감사합니다.',
      date: '2024.03.15',
    ),
    Notice(
      id: '3', 
      title: '좌석 예약 시스템 개선 안내', 
      content: '안녕하세요. Shh-tudy 입니다.\n\n좌석 예약 시스템이 개선되었습니다.\n\n- 선호 좌석 등록 기능\n- 예약 자동 연장 기능\n- 빠른 좌석 변경 기능\n\n더 편리한 서비스로 찾아뵙겠습니다.\n감사합니다.',
      date: '2024.03.10',
    ),
    Notice(
      id: '4', 
      title: '소음 측정 알고리즘 개선', 
      content: '안녕하세요. Shh-tudy 입니다.\n\n소음 측정 알고리즘이 개선되었습니다.\n\n- 더 정확한 소음 레벨 측정\n- 소음 패턴 분석 기능 추가\n- 개인화된 소음 허용 범위 설정\n\n더 쾌적한 스터디 환경을 제공하겠습니다.\n감사합니다.',
      date: '2024.03.05',
    ),
    Notice(
      id: '5', 
      title: '앱 버전 업데이트 안내 (v1.2.0)', 
      content: '안녕하세요. Shh-tudy 입니다.\n\n앱 버전이 업데이트 되었습니다.\n\n- 성능 개선 및 버그 수정\n- 디자인 리뉴얼\n- 신규 통계 기능 추가\n\n더 나은 서비스로 찾아뵙겠습니다.\n감사합니다.',
      date: '2024.02.28',
    ),
  ];

  void _showNoticeDetail(BuildContext context, Notice notice) {
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
                notice.date,
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
    return Scaffold(
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
          onPressed: () => Navigator.pop(context),
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
                            child: Text(
                              notice.title,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textColor,
                              ),
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
                            notice.date,
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
    );
  }
} 