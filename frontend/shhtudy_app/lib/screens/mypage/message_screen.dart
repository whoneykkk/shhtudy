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
  final List<Message> tempReceivedMessages = [
    Message(
      id: '1', 
      fromSeat: 'b-4', 
      content: '조용히 해주세요. 책상을 두드리는 소리가 들립니다.', 
      date: '03.19 16:25',
      isSent: false,
    ),
    Message(
      id: '3', 
      fromSeat: 'c-2', 
      content: '자리 잠시 비울 예정인가요? 책과 노트북이 자리에 있어서 여쭤봅니다.', 
      date: '03.18 13:40',
      isSent: false,
    ),
    Message(
      id: '5', 
      fromSeat: 'a-3', 
      content: '창가 쪽 냉방이 너무 강한 것 같아요. 관리자에게 문의 부탁드립니다.', 
      date: '03.15 10:15',
      isSent: false,
    ),
    Message(
      id: '7', 
      fromSeat: 'd-1', 
      content: '전화 통화는 밖에서 부탁드립니다.', 
      date: '03.13 14:22',
      isSent: false,
    ),
  ];
  
  final List<Message> tempSentMessages = [
    Message(
      id: '2', 
      fromSeat: 'b-1', 
      content: '죄송합니다. 앞으로 조심하겠습니다.', 
      date: '03.19 16:32',
      isSent: true,
    ),
    Message(
      id: '4', 
      fromSeat: 'c-2', 
      content: '네, 잠시 화장실 다녀오겠습니다. 10분 내로 돌아올게요.', 
      date: '03.18 13:45',
      isSent: true,
    ),
    Message(
      id: '6', 
      fromSeat: 'a-3', 
      content: '저도 그렇게 느꼈어요. 안내데스크에 말씀드렸습니다.', 
      date: '03.15 10:20',
      isSent: true,
    ),
    Message(
      id: '8', 
      fromSeat: 'd-5', 
      content: '앞자리 학생분 노트북 소리가 너무 큰데 줄여주실 수 있을까요?', 
      date: '03.12 11:05',
      isSent: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
                    '답장: ${originalMessage.fromSeat}',
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
                                      message.fromSeat,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: message.isSent ? AppTheme.primaryColor : AppTheme.quietColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              Text(
                                message.date,
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
                            style: const TextStyle(
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