import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../auth/login_screen.dart';
import 'notice_screen.dart';
import 'message_screen.dart';

// 공지사항 모델 클래스
class Notice {
  final int id;
  final String title;
  final String content;
  final DateTime createdAt;
  final bool isRead; // 읽음 여부

  const Notice({
    required this.id, 
    required this.title, 
    required this.content,
    required this.createdAt,
    this.isRead = false,
  });
  
  // 날짜 포맷팅
  String get formattedDate {
    return '${createdAt.year}.${_twoDigits(createdAt.month)}.${_twoDigits(createdAt.day)}';
  }
  
  // JSON 데이터로부터 객체 생성 (API 응답 처리용)
  factory Notice.fromJson(Map<String, dynamic> json, {bool? isReadStatus}) {
    return Notice(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
      isRead: isReadStatus ?? false,
    );
  }
  
  static String _twoDigits(int n) {
    if (n >= 10) return '$n';
    return '0$n';
  }
}

// 쪽지 모델 클래스
class Message {
  final int messageId;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime sentAt;
  final bool isRead; // 읽음 여부
  final bool isSent; // 보낸 쪽지 여부 (프론트엔드 표시용)

  const Message({
    required this.messageId, 
    required this.senderId, 
    required this.receiverId,
    required this.content, 
    required this.sentAt,
    required this.isRead,
    required this.isSent,
  });
  
  // 날짜 포맷팅
  String get formattedDate {
    return '${_twoDigits(sentAt.month)}.${_twoDigits(sentAt.day)} ${_twoDigits(sentAt.hour)}:${_twoDigits(sentAt.minute)}';
  }

  // 보낸/받은 사람 (좌석 ID 표시)
  String get contactSeatId => isSent ? receiverId : senderId;
  
  // JSON 데이터로부터 객체 생성 (API 응답 처리용)
  factory Message.fromJson(Map<String, dynamic> json, String currentUserId) {
    final bool isSentMessage = json['sender_id'] == currentUserId;
    
    return Message(
      messageId: json['message_id'],
      senderId: json['sender_id'],
      receiverId: json['receiver_id'],
      content: json['content'],
      sentAt: DateTime.parse(json['sent_at']),
      isRead: json['is_read'] == 1,
      isSent: isSentMessage,
    );
  }
  
  static String _twoDigits(int n) {
    if (n >= 10) return '$n';
    return '0$n';
  }
}

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  // 임시 데이터 - 실제 구현 시 API 호출로 대체 필요
  static final List<Notice> tempNotices = [
    Notice(
      id: 1, 
      title: '시스템 점검 안내', 
      content: '안녕하세요. Shh-tudy 입니다.\n\n서비스 안정화를 위한 시스템 점검이 진행될 예정입니다.\n\n점검 일시: 2024년 3월 20일 02:00 ~ 06:00\n점검 내용: 서버 안정화 및 성능 개선\n\n더 나은 서비스를 제공하도록 하겠습니다.\n감사합니다.',
      createdAt: DateTime(2024, 3, 19),
      isRead: true,
    ),
    Notice(
      id: 2, 
      title: '신규 기능 업데이트', 
      content: '안녕하세요. Shh-tudy 입니다.\n\n새로운 기능이 추가되었습니다.\n\n1. 실시간 소음 알림\n2. 좌석 이용 통계\n3. UI/UX 개선\n\n많은 이용 부탁드립니다.\n감사합니다.',
      createdAt: DateTime(2024, 3, 15),
      isRead: false,
    ),
  ];

  static final List<Message> tempMessages = [
    Message(
      messageId: 1, 
      senderId: 'b-4',
      receiverId: 'user123',
      content: '조용히 해주세요 조용히 해주세요 조용히 해주세요 조용히 해주세요 조용히 해주세요', 
      sentAt: DateTime(2024, 3, 19, 16, 25),
      isRead: false,
      isSent: false,
    ),
    Message(
      messageId: 2, 
      senderId: 'user123',
      receiverId: 'b-1',
      content: '책상 발로 차지 말아주세요', 
      sentAt: DateTime(2024, 3, 19, 16, 32),
      isRead: true,
      isSent: true,
    ),
  ];

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  // 읽지 않은 공지사항 개수
  int get unreadNoticeCount => MyPageScreen.tempNotices.where((notice) => !notice.isRead).length;
  
  // 읽지 않은 쪽지 개수
  int get unreadMessageCount => MyPageScreen.tempMessages.where((message) => !message.isRead && !message.isSent).length;

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
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NoticeScreen()),
    ).then((_) {
      // 화면으로 돌아왔을 때 상태 즉시 업데이트
      setState(() {
        // 이미 Notice 화면에서 나올 때 읽음 처리가 되었을 것임
      });
    });
  }

  void _showAllMessages(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MessageScreen()),
    ).then((_) {
      // 화면으로 돌아왔을 때 상태 즉시 업데이트
      setState(() {
        // 이미 Message 화면에서 나올 때 읽음 처리가 되었을 것임
      });
    });
  }

  void _showNoticeDetail(BuildContext context, Notice notice) {
    // 공지사항 읽음 처리
    setState(() {
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

  void _showMessageDetail(BuildContext context, Message message) {
    // 쪽지 읽음 처리 (받은 쪽지만)
    if (!message.isSent) {
      setState(() {
        for (int i = 0; i < MyPageScreen.tempMessages.length; i++) {
          if (MyPageScreen.tempMessages[i].messageId == message.messageId && !MyPageScreen.tempMessages[i].isSent) {
            MyPageScreen.tempMessages[i] = Message(
              messageId: message.messageId,
              senderId: message.senderId,
              receiverId: message.receiverId,
              content: message.content,
              sentAt: message.sentAt,
              isRead: true,
              isSent: message.isSent,
            );
            break;
          }
        }
      });
    }

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
                    message.contactSeatId,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    message.formattedDate,
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
                  // 프로필 버튼
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MyPageScreen(),
                        ),
                      );
                    },
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.primaryColor.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.grey[200],
                            child: Icon(
                              Icons.person_outline,
                              color: AppTheme.textColor,
                              size: 20,
                            ),
                          ),
                        ),
                        // 읽지 않은 알림이 있을 경우 표시 (숫자 없이 빨간 동그라미만)
                        if (unreadNoticeCount > 0 || unreadMessageCount > 0)
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 12,
                                minHeight: 12,
                              ),
                            ),
                          ),
                      ],
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
                                Text(
                                  '공지사항',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textColor,
                                  ),
                                ),
                                if (unreadNoticeCount > 0) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
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
                                for (var i = 0; i < MyPageScreen.tempNotices.length; i++) ...[
                                  GestureDetector(
                                    onTap: () => _showNoticeDetail(context, MyPageScreen.tempNotices[i]),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              MyPageScreen.tempNotices[i].title,
                                              style: const TextStyle(fontSize: 14),
                                            ),
                                          ),
                                          Text(
                                            MyPageScreen.tempNotices[i].formattedDate,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppTheme.textColor.withOpacity(0.6),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (i < MyPageScreen.tempNotices.length - 1)
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
                                Text(
                                  '쪽지',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textColor,
                                  ),
                                ),
                                if (unreadMessageCount > 0) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
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
                                for (var i = 0; i < MyPageScreen.tempMessages.length; i++) ...[
                                  GestureDetector(
                                    onTap: () => _showMessageDetail(context, MyPageScreen.tempMessages[i]),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                                      child: Row(
                                        children: [
                                          // 화살표와 좌석번호
                                          Text(
                                            MyPageScreen.tempMessages[i].contactSeatId,
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
                                              MyPageScreen.tempMessages[i].content,
                                              style: const TextStyle(fontSize: 14),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          // 날짜
                                          Text(
                                            MyPageScreen.tempMessages[i].formattedDate,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppTheme.textColor.withOpacity(0.6),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (i < MyPageScreen.tempMessages.length - 1)
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