import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'my_page_screen.dart';
import '../../config/api_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // 임시 데이터 제거 - API로 가져오는 데이터 사용
  bool isLoading = false;
  List<Message> receivedMessages = [];
  List<Message> sentMessages = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadMessages(); // 서버에서 메시지 로드
  }
  
  // 서버에서 메시지 데이터 로드
  Future<void> _loadMessages() async {
    setState(() {
      isLoading = true;
    });
    
    try {
      // 사용자 토큰 가져오기
      final token = await UserService.getToken();
      if (token == null) {
        throw Exception('로그인이 필요합니다');
      }
      
      // 백엔드 API URL
      final baseUrl = '${ApiConfig.baseUrl}';
      
      // 메시지 API 호출
      final response = await http.get(
        Uri.parse('$baseUrl/messages'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> messagesJson = data['data'];
          final String currentUserId = await _getCurrentUserId();
          
          // 정적 리스트 업데이트
          MyPageScreen.tempMessages = messagesJson.map((json) {
            return Message.fromJson(json, currentUserId);
          }).toList();
          
          // 받은 메시지와 보낸 메시지 구분
          setState(() {
            receivedMessages = MyPageScreen.tempMessages
                .where((message) => !message.isSent)
                .toList();
                
            sentMessages = MyPageScreen.tempMessages
                .where((message) => message.isSent)
                .toList();
                
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
        }
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('메시지 로딩 오류: $e');
      setState(() {
        isLoading = false;
      });
    }
  }
  
  // 현재 사용자 ID 가져오기
  Future<String> _getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id') ?? '';
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // 모든 받은 쪽지 읽음 처리 함수
  void _markAllAsRead() {
    // 백엔드 API 호출 (구현 시)
    _markMessagesAsReadApi();
    
    // UI 업데이트
    setState(() {
      // 메시지 로컬 상태 업데이트
      for (int i = 0; i < receivedMessages.length; i++) {
        final message = receivedMessages[i];
        receivedMessages[i] = Message(
          messageId: message.messageId,
          senderId: message.senderId,
          receiverId: message.receiverId,
          content: message.content,
          sentAt: message.sentAt,
          isRead: true,
          isSent: message.isSent,
        );
      }
      
      // 마이페이지 메시지 상태 업데이트
      for (int i = 0; i < MyPageScreen.tempMessages.length; i++) {
        final message = MyPageScreen.tempMessages[i];
        if (!message.isSent) { // 받은 쪽지만 처리
          MyPageScreen.tempMessages[i] = Message(
            messageId: message.messageId,
            senderId: message.senderId,
            receiverId: message.receiverId,
            content: message.content,
            sentAt: message.sentAt,
            isRead: true,
            isSent: message.isSent,
          );
        }
      }
    });
  }
  
  // 백엔드 API를 통해 모든 메시지 읽음 처리
  Future<void> _markMessagesAsReadApi() async {
    try {
      final token = await UserService.getToken();
      if (token != null) {
        // 백엔드 API 호출
        final baseUrl = '${ApiConfig.baseUrl}';
        await http.post(
          Uri.parse('$baseUrl/messages/read-all'),
          headers: {
            'Authorization': 'Bearer $token',
          },
        );
      }
    } catch (e) {
      print('메시지 읽음 처리 오류: $e');
    }
  }

  // 개별 메시지 읽음 처리 함수
  void _markAsRead(Message message) {
    // 보낸 쪽지는 읽음 처리하지 않음
    if (message.isSent) return;
    
    // 백엔드 API 호출 (구현 시)
    _markMessageAsReadApi(message.messageId);
    
    // UI 업데이트
    setState(() {
      // 현재 화면의 메시지 상태 업데이트
      for (int i = 0; i < receivedMessages.length; i++) {
        if (receivedMessages[i].messageId == message.messageId) {
          receivedMessages[i] = Message(
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
      
      // 마이페이지의 메시지 상태 업데이트
      for (int i = 0; i < MyPageScreen.tempMessages.length; i++) {
        if (MyPageScreen.tempMessages[i].messageId == message.messageId && 
            !MyPageScreen.tempMessages[i].isSent) {
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
  
  // 백엔드 API를 통해 개별 메시지 읽음 처리
  Future<void> _markMessageAsReadApi(int messageId) async {
    try {
      final token = await UserService.getToken();
      if (token != null) {
        // 백엔드 API 호출
        final baseUrl = '${ApiConfig.baseUrl}';
        await http.post(
          Uri.parse('$baseUrl/messages/$messageId/read'),
          headers: {
            'Authorization': 'Bearer $token',
          },
        );
      }
    } catch (e) {
      print('메시지 읽음 처리 오류: $e');
    }
  }

  void _showMessageDetail(BuildContext context, Message message) {
    // 메시지 열람 시 즉시 읽음 처리
    _markAsRead(message);
    
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
                    message.isSent ? '-> ${message.contactSeatId}' : '<- ${message.contactSeatId}',
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
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (!message.isSent) 
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showReplyDialog(context, message);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.primaryColor,
                      ),
                      child: const Text('답장하기'),
                    ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.textColor,
                    ),
                    child: const Text('닫기'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReplyDialog(BuildContext context, Message originalMessage) {
    final TextEditingController _contentController = TextEditingController();
    
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
                    '답장: ${originalMessage.contactSeatId}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  originalMessage.content,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textColor.withOpacity(0.8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _contentController,
                decoration: InputDecoration(
                  hintText: '메시지를 입력하세요',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: AppTheme.accentColor,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // TODO: 실제 메시지 전송 API 연동
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('답장이 전송되었습니다'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                    ),
                    child: const Text('전송'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNewMessageDialog(BuildContext context) {
    final TextEditingController _seatController = TextEditingController();
    final TextEditingController _contentController = TextEditingController();
    
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
                  const Text(
                    '새 쪽지 작성',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _seatController,
                decoration: InputDecoration(
                  hintText: '받는 좌석 (예: a-1)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: AppTheme.accentColor,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _contentController,
                decoration: InputDecoration(
                  hintText: '메시지를 입력하세요',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: AppTheme.accentColor,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // TODO: 실제 메시지 전송 API 연동
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('쪽지가 전송되었습니다'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                    ),
                    child: const Text('전송'),
                  ),
                ],
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
        // 화면에서 나갈 때 모든 받은 쪽지를 읽음 처리
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
            '쪽지함',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.edit,
                color: AppTheme.primaryColor,
              ),
              onPressed: () => _showNewMessageDialog(context),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: AppTheme.textColor.withOpacity(0.6),
            indicatorColor: AppTheme.primaryColor.withOpacity(0.7),
            indicatorWeight: 2,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: '받은쪽지'),
              Tab(text: '보낸쪽지'),
            ],
          ),
        ),
        body: isLoading 
          ? Center(child: CircularProgressIndicator())
          : TabBarView(
            controller: _tabController,
            children: [
              // 받은 쪽지
              _buildMessageList(receivedMessages),
              // 보낸 쪽지
              _buildMessageList(sentMessages),
            ],
          ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showNewMessageDialog(context),
          backgroundColor: AppTheme.primaryColor,
          child: const Icon(Icons.edit, color: Colors.white),
          elevation: 2,
        ),
      ),
    );
  }

  Widget _buildMessageList(List<Message> messages) {
    return messages.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.mail_outline,
                  size: 48,
                  color: AppTheme.textColor.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  '쪽지가 없습니다',
                  style: TextStyle(
                    color: AppTheme.textColor.withOpacity(0.5),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
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
                    onTap: () => _showMessageDetail(context, message),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // 방향 및 좌석 표시
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: message.isSent 
                                      ? AppTheme.primaryColor.withOpacity(0.1)
                                      : AppTheme.quietColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      message.isSent ? Icons.send : Icons.inbox,
                                      size: 14,
                                      color: message.isSent ? AppTheme.primaryColor : AppTheme.quietColor,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      message.contactSeatId,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: message.isSent ? AppTheme.primaryColor : AppTheme.quietColor,
                                      ),
                                    ),
                                    // 읽지 않은 쪽지 표시
                                    if (!message.isRead && !message.isSent) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const Spacer(),
                              Text(
                                message.formattedDate,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textColor.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // 메시지 내용
                          Text(
                            message.content,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textColor,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
  }
} 