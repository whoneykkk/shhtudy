import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'my_page_screen.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // 임시 쪽지 데이터
  static final List<Message> tempReceivedMessages = [
    Message(
      messageId: 1, 
      senderId: 'b-4', 
      receiverId: 'user123',
      content: '조용히 해주세요. 책상을 두드리는 소리가 들립니다.', 
      sentAt: DateTime(2024, 3, 19, 16, 25),
      isRead: false,
      isSent: false,
    ),
    Message(
      messageId: 3, 
      senderId: 'c-2', 
      receiverId: 'user123',
      content: '자리 잠시 비울 예정인가요? 책과 노트북이 자리에 있어서 여쭤봅니다.', 
      sentAt: DateTime(2024, 3, 18, 13, 40),
      isRead: false,
      isSent: false,
    ),
    Message(
      messageId: 5, 
      senderId: 'a-3', 
      receiverId: 'user123',
      content: '창가 쪽 냉방이 너무 강한 것 같아요. 관리자에게 문의 부탁드립니다.', 
      sentAt: DateTime(2024, 3, 15, 10, 15),
      isRead: false,
      isSent: false,
    ),
    Message(
      messageId: 7, 
      senderId: 'd-1', 
      receiverId: 'user123',
      content: '전화 통화는 밖에서 부탁드립니다.', 
      sentAt: DateTime(2024, 3, 13, 14, 22),
      isRead: false,
      isSent: false,
    ),
  ];
  
  static final List<Message> tempSentMessages = [
    Message(
      messageId: 2, 
      senderId: 'user123',
      receiverId: 'b-1',
      content: '죄송합니다. 앞으로 조심하겠습니다.', 
      sentAt: DateTime(2024, 3, 19, 16, 32),
      isRead: true,
      isSent: true,
    ),
    Message(
      messageId: 4, 
      senderId: 'user123',
      receiverId: 'c-2',
      content: '네, 잠시 화장실 다녀오겠습니다. 10분 내로 돌아올게요.', 
      sentAt: DateTime(2024, 3, 18, 13, 45),
      isRead: true,
      isSent: true,
    ),
    Message(
      messageId: 6, 
      senderId: 'user123',
      receiverId: 'a-3',
      content: '저도 그렇게 느꼈어요. 안내데스크에 말씀드렸습니다.', 
      sentAt: DateTime(2024, 3, 15, 10, 20),
      isRead: true,
      isSent: true,
    ),
    Message(
      messageId: 8, 
      senderId: 'user123',
      receiverId: 'd-5',
      content: '앞자리 학생분 노트북 소리가 너무 큰데 줄여주실 수 있을까요?', 
      sentAt: DateTime(2024, 3, 12, 11, 5),
      isRead: true,
      isSent: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // 화면 진입 시에는 읽음 처리하지 않음
  }

  @override
  void dispose() {
    // _markAllAsRead() 호출 제거
    _tabController.dispose();
    super.dispose();
  }

  // 모든 받은 쪽지 읽음 처리 함수
  void _markAllAsRead() {
    // 실제 구현에서는 API 호출하여 서버에 읽음 상태 업데이트 필요
    for (int i = 0; i < tempReceivedMessages.length; i++) {
      final message = tempReceivedMessages[i];
      tempReceivedMessages[i] = Message(
        messageId: message.messageId,
        senderId: message.senderId,
        receiverId: message.receiverId,
        content: message.content,
        sentAt: message.sentAt,
        isRead: true,
        isSent: message.isSent,
      );
    }
    
    // 마이페이지의 쪽지도 읽음 처리 (필요시)
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
  }

  // 개별 메시지 읽음 처리 함수
  void _markAsRead(Message message) {
    // 보낸 쪽지는 읽음 처리하지 않음
    if (message.isSent) return;
    
    // 실제 구현에서는 API 호출하여 서버에 읽음 상태 업데이트 필요
    setState(() {
      // 현재 화면의 메시지 읽음 처리
      for (int i = 0; i < tempReceivedMessages.length; i++) {
        if (tempReceivedMessages[i].messageId == message.messageId) {
          tempReceivedMessages[i] = Message(
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
      
      // 마이페이지의 메시지도 읽음 처리
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
        body: TabBarView(
          controller: _tabController,
          children: [
            // 받은 쪽지
            _buildMessageList(tempReceivedMessages),
            // 보낸 쪽지
            _buildMessageList(tempSentMessages),
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