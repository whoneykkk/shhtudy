import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../auth/login_screen.dart';
import 'notice_screen.dart';
import 'message_screen.dart';
import '../../models/user_profile.dart';
import '../../services/user_service.dart';
import 'dart:math' as math;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  
  // 사용자 프로필 정보
  UserProfile? userProfile;
  bool isLoading = true;
  
  // 상세 정보 표시 여부
  bool _showDetailStats = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  // 사용자 프로필 정보 불러오기
  Future<void> _loadUserProfile() async {
    setState(() {
      isLoading = true;
    });

    try {
      // 서버에서 최신 프로필 정보 가져오기
      final profile = await UserService.getUserProfile();
      
      if (!mounted) return; // 위젯이 아직 유효한지 확인
      
      if (profile != null) {
        setState(() {
          userProfile = profile;
          isLoading = false;
        });
      } else {
        // 서버에서 프로필을 가져오지 못한 경우
        setState(() {
          isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('세션이 만료되었습니다. 다시 로그인해주세요.'),
            duration: Duration(seconds: 3),
          ),
        );
        
        // 로그인 화면으로 이동
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        });
      }
    } catch (e) {
      if (!mounted) return;
      
      print('프로필 로딩 오류: $e');
      setState(() {
        isLoading = false;
      });
      
      // 오류 발생 시 로그인 화면으로 이동
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('사용자 정보를 찾을 수 없습니다. 다시 로그인해주세요.'),
          duration: Duration(seconds: 3),
        ),
      );
      
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      });
    }
  }

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
            onPressed: () async {
              // 로딩 상태 표시
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );
              
              try {
                // Firebase 로그아웃
                await FirebaseAuth.instance.signOut();
                
                // 서버측 로그아웃 처리
                await UserService.logout();
                
                // 자동 로그인 설정 제거
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('auto_login', false);
                
                // 로딩 다이얼로그 닫기
                Navigator.pop(context);
                
                // 로그인 화면으로 이동
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
              } catch (e) {
                // 로딩 다이얼로그 닫기
                Navigator.pop(context);
                
                // 에러 메시지 표시
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('로그아웃 중 오류가 발생했습니다: $e')),
                );
              }
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
                  const Spacer(),
                ],
              ),
            ),
            // 본문
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
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
                          if (isLoading)
                            const Padding(
                              padding: EdgeInsets.all(32.0),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          else
                            Column(
                              children: [
                                // 사용자 기본 정보 카드
                          Container(
                            width: double.infinity,
                                  padding: const EdgeInsets.all(24),
                                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.03),
                                        blurRadius: 10,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                            ),
                            child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                      // 이름과 등급
                                Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: _getGradeColor(userProfile?.grade),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              _getGradeText(userProfile?.grade),
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            userProfile?.userAccountId ?? '--',
                                            style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      
                                      const SizedBox(height: 16),
                                      // 구분선
                                      Divider(
                                        color: Colors.grey.withOpacity(0.2),
                                        thickness: 1,
                                      ),
                                      const SizedBox(height: 16),
                                      
                                      // 이름 정보
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: AppTheme.primaryColor.withOpacity(0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.badge,
                                              color: AppTheme.primaryColor,
                                              size: 18,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            '이름: ',
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: AppTheme.textColor.withOpacity(0.7),
                                            ),
                                          ),
                                          Text(
                                            userProfile?.name ?? '--',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.textColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                      
                                      const SizedBox(height: 16),
                                      
                                      // 전화번호 정보
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: AppTheme.primaryColor.withOpacity(0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.phone,
                                              color: AppTheme.primaryColor,
                                              size: 18,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            '전화번호: ',
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: AppTheme.textColor.withOpacity(0.7),
                                            ),
                                          ),
                                          Text(
                                            userProfile?.phoneNumber ?? '--',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.textColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                      
                                      const SizedBox(height: 16),
                                      
                                      // 포인트 정보
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: AppTheme.primaryColor.withOpacity(0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.card_giftcard,
                                              color: AppTheme.primaryColor,
                                              size: 18,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '포인트: ${userProfile?.points ?? 0} P',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppTheme.primaryColor,
                                                ),
                                              ),
                                              Text(
                                                '(${_getPointsStatusText(userProfile?.grade, userProfile?.points ?? 0)})',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: AppTheme.textColor.withOpacity(0.6),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      
                                      // 현재 좌석 정보 (있을 경우)
                                      if (userProfile?.currentSeat != null) ...[
                          const SizedBox(height: 16),
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: AppTheme.primaryColor.withOpacity(0.1),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.chair_outlined,
                                                color: AppTheme.primaryColor,
                                                size: 18,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              '현재 좌석: ',
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: AppTheme.textColor.withOpacity(0.7),
                                              ),
                                            ),
                                            Text(
                                              userProfile?.currentSeat ?? '--',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: AppTheme.textColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                
                                // 상세 정보 보기 버튼
                                Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.only(top: 0, left: 16, right: 16, bottom: 16),
                                  decoration: BoxDecoration(
                                    color: AppTheme.accentColor,
                                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          _showDetailStats = !_showDetailStats;
                                        });
                                      },
                                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                                        child: Center(
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                _showDetailStats ? '상세 정보 접기' : '상세 정보 보기',
                                                style: TextStyle(
                                                  color: AppTheme.primaryColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Icon(
                                                _showDetailStats ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                                color: AppTheme.primaryColor,
                                                size: 20,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                
                                const SizedBox(height: 0),
                                
                                // 주요 통계 그리드 (2x2) - 접기/펼치기 기능 적용
                                if (_showDetailStats) ...[
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _buildStatCardGridItem(
                                                icon: Icons.timer,
                                                title: '남은 시간',
                                                value: _formatRemainingTime(userProfile?.remainingTime ?? 0),
                                                iconColor: AppTheme.primaryColor,
                                              ),
                                            ),
                                            SizedBox(width: 12),
                                            Expanded(
                                              child: _buildStatCardGridItem(
                                                icon: Icons.mood,
                                                title: '매너 점수',
                                                value: '${userProfile?.mannerScore ?? 0}점',
                                                iconColor: Colors.amber,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _buildStatCardGridItem(
                                                icon: Icons.volume_up,
                                                title: '평균 데시벨',
                                                value: '${userProfile?.averageDecibel != null ? userProfile!.averageDecibel.toString() : 0}dB',
                                                iconColor: AppTheme.normalColor,
                                              ),
                                            ),
                                            SizedBox(width: 12),
                                            Expanded(
                                              child: _buildStatCardGridItem(
                                                icon: Icons.notifications_active,
                                                title: '소음 발생',
                                                value: '${userProfile?.noiseOccurrence ?? 0}회',
                                                iconColor: userProfile?.noiseOccurrence != null && userProfile!.noiseOccurrence > 5 
                                                    ? AppTheme.warningColor 
                                                    : AppTheme.quietColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                
                    const SizedBox(height: 16),
                              ],
                            ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
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
                    
                    const SizedBox(height: 24),
                    
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

  // 통계 카드 위젯 생성 메서드
  Widget _buildStatCard({required IconData icon, required String title, required String value, required Color iconColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: iconColor,
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textColor.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
          ),
        ],
      ),
    );
  }

  // 통계 카드 그리드 아이템 (새로운 디자인)
  Widget _buildStatCardGridItem({required IconData icon, required String title, required String value, required Color iconColor}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 20,
              color: iconColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textColor.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // 등급에 따른 컬러 반환
  Color _getGradeColor(String? grade) {
    if (grade == null) return AppTheme.normalColor;
    
    switch (grade.toUpperCase()) {
      case 'WARNING':
        return AppTheme.warningColor;
      case 'SILENT':
        return AppTheme.quietColor;
      case 'GOOD':
      default:
        return AppTheme.normalColor;
    }
  }

  // 등급 표시 텍스트 반환
  String _getGradeText(String? grade) {
    if (grade == null) return 'B';
    
    switch (grade.toUpperCase()) {
      case 'WARNING':
        return 'C';
      case 'SILENT':
        return 'A';
      case 'GOOD':
        return 'B';
      default:
        return grade;
    }
  }

  // 남은 시간 포맷팅
  String _formatRemainingTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    
    return '${hours}시간 ${minutes}분';
  }

  // 승급까지 남은 포인트 계산
  String _getPointsToNextGrade(String? grade) {
    if (grade == null) return '0 P';
    
    final userPoints = userProfile?.points ?? 0;
    
    switch (grade.toUpperCase()) {
      case 'WARNING': // C등급
        final remainingPoints = 300 - userPoints;
        return remainingPoints <= 0 ? '승급 가능' : '$remainingPoints P';
      case 'GOOD': // B등급
        final remainingPoints = 700 - userPoints;
        return remainingPoints <= 0 ? '승급 가능' : '$remainingPoints P';
      case 'SILENT': // A등급 (최고 등급)
        final remainingPoints = 1000 - userPoints;
        return remainingPoints <= 0 ? '최고 등급' : '$remainingPoints P';
      default:
        return '0 P';
    }
  }
  
  // 포인트 상태 텍스트 (진행 상황 포함)
  String _getPointsStatusText(String? grade, int points) {
    if (grade == null) return '';
    
    switch (grade.toUpperCase()) {
      case 'WARNING': // C등급
        final nextThreshold = 300;
        if (points >= nextThreshold) {
          return '다음 등급(B)으로 자동 승급 예정';
        } else {
          final percentage = ((points / nextThreshold) * 100).round();
          return 'B등급까지 ${nextThreshold - points}P 남음 ($percentage%)';
        }
      case 'GOOD': // B등급
        final nextThreshold = 700;
        if (points >= nextThreshold) {
          return '다음 등급(A)으로 자동 승급 예정';
        } else {
          final percentage = (((points - 300) / (nextThreshold - 300)) * 100).round();
          return 'A등급까지 ${nextThreshold - points}P 남음 ($percentage%)';
        }
      case 'SILENT': // A등급 (최고 등급)
        final maxThreshold = 1000;
        if (points >= maxThreshold) {
          return '최고 등급 달성 (100%)';
        } else {
          final percentage = (((points - 700) / (maxThreshold - 700)) * 100).round();
          return '최고 등급 달성 ($percentage%)';
        }
      default:
        return '';
    }
  }
} 