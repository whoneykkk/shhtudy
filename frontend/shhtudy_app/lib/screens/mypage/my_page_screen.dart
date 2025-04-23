import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../auth/login_screen.dart';

// TODO: 실제 데이터 모델 구현 필요
class Notice {
  final String id;
  final String title;
  final String content;
  final String date;

  const Notice({
    required this.id, 
    required this.title, 
    required this.content,
    required this.date,
  });
}

class Message {
  final String id;
  final String fromSeat;
  final String content;
  final String date;
  final bool isSent;  // 보낸 쪽지 여부

  const Message({
    required this.id, 
    required this.fromSeat, 
    required this.content, 
    required this.date,
    required this.isSent,
  });
}

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  // TODO: 임시 데이터 - 실제 구현 시 API 호출로 대체 필요
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
  ];

  final List<Message> tempMessages = const [
    Message(
      id: '1', 
      fromSeat: 'b-4', 
      content: '조용히 해주세요 조용히 해주세요 조용히 해주세요 조용히 해주세요 조용히 해주세요', 
      date: '03.19 16:25',
      isSent: false,
    ),
    Message(
      id: '2', 
      fromSeat: 'b-1', 
      content: '책상 발로 차지 말아주세요', 
      date: '03.19 16:32',
      isSent: true,
    ),
  ];

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('로그아웃'),
        content: const Text('로그아웃 하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '아니오',
              style: TextStyle(
                color: AppTheme.textColor,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: 로그아웃 API 호출
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
              shadowColor: Colors.transparent,
              splashFactory: NoSplash.splashFactory,
              surfaceTintColor: Colors.transparent,
            ),
            child: const Text('예'),
          ),
        ],
      ),
    );
  }

  void _showAllNotices(BuildContext context) {
    // TODO: 전체 공지사항 화면으로 이동
    print('전체 공지사항 보기');
  }

  void _showAllMessages(BuildContext context) {
    // TODO: 전체 쪽지함 화면으로 이동
    print('전체 쪽지함 보기');
  }

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

  void _showMessageDetail(BuildContext context, Message message) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    message.isSent ? '-> ${message.fromSeat}' : '<- ${message.fromSeat}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    message.date,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textColor.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                message.content,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    '닫기',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // 상단 바
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.menu_book,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '마이 페이지',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            // 본문
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // 내 정보 섹션
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.person_outline,
                                  color: AppTheme.primaryColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  '내 정보',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text('이름: '),
                                    const Text('홍길동'),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Text('전화번호: '),
                                    const Text('010-1234-5678'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 공지사항 섹션
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.campaign_outlined,
                                  color: AppTheme.primaryColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  '공지사항',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                GestureDetector(
                                  onTap: () => _showAllNotices(context),
                                  child: Icon(
                                    Icons.add,
                                    color: AppTheme.primaryColor,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                for (var i = 0; i < tempNotices.length; i++) ...[
                                  GestureDetector(
                                    onTap: () => _showNoticeDetail(context, tempNotices[i]),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              tempNotices[i].title,
                                              style: const TextStyle(fontSize: 14),
                                            ),
                                          ),
                                          Text(
                                            tempNotices[i].date,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppTheme.textColor.withOpacity(0.6),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (i < tempNotices.length - 1)
                                    Divider(
                                      color: AppTheme.textColor.withOpacity(0.1),
                                      height: 16,
                                      thickness: 1,
                                    ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 쪽지 섹션
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.mail_outline,
                                  color: AppTheme.primaryColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  '쪽지',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                GestureDetector(
                                  onTap: () => _showAllMessages(context),
                                  child: Icon(
                                    Icons.add,
                                    color: AppTheme.primaryColor,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                for (var i = 0; i < tempMessages.length; i++) ...[
                                  GestureDetector(
                                    onTap: () => _showMessageDetail(context, tempMessages[i]),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                                      child: Row(
                                        children: [
                                          // 화살표와 좌석번호
                                          Text(
                                            tempMessages[i].isSent 
                                                ? '-> ${tempMessages[i].fromSeat}'
                                                : '<- ${tempMessages[i].fromSeat}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          // 구분선
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                            child: Text(
                                              '|',
                                              style: TextStyle(
                                                color: AppTheme.textColor.withOpacity(0.3),
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          // 쪽지 내용
                                          Expanded(
                                            child: Text(
                                              tempMessages[i].content,
                                              style: const TextStyle(fontSize: 14),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          // 날짜
                                          Text(
                                            tempMessages[i].date,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppTheme.textColor.withOpacity(0.6),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (i < tempMessages.length - 1)
                                    Divider(
                                      color: AppTheme.textColor.withOpacity(0.1),
                                      height: 16,
                                      thickness: 1,
                                    ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 로그아웃 버튼
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showLogoutDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    splashFactory: NoSplash.splashFactory,
                    surfaceTintColor: Colors.transparent,
                  ),
                  child: const Text(
                    '로그아웃',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 