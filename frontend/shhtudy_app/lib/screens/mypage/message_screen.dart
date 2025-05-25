import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'my_page_screen.dart';
import '../../services/message_service.dart';
import '../../services/alert_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  bool isLoading = false;
  List<ConversationThread> conversationThreads = [];
  Set<String> expandedThreads = {};
  final TextEditingController _replyController = TextEditingController();
  bool _allExpanded = false; // 전체 펼침 상태 관리
  Set<int> expandedMessages = {}; // 확장된 메시지 ID 관리
  Map<int, String> fullMessageContents = {}; // 전체 메시지 내용 캐시

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }
  
  // 메시지 로드 (MessageService 사용)
  Future<void> _loadMessages() async {
    setState(() => isLoading = true);
    
    try {
      final messageDataList = await MessageService.getMessageList();
      final currentUserId = await _getCurrentUserId();
      
      // Map 데이터를 Message 객체로 변환
      final messages = messageDataList.map((data) {
        return Message.fromJson(data, currentUserId);
      }).toList();
      
      _groupMessagesIntoThreads(messages);
    } catch (e) {
      print('메시지 로딩 오류: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }
  
  // 현재 사용자 ID 가져오기
  Future<String> _getCurrentUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('user_id') ?? 'current_user';
    } catch (e) {
      return 'current_user';
    }
  }
  
  // 메시지를 대화 스레드로 그룹화
  void _groupMessagesIntoThreads(List<Message> messages) {
    Map<String, List<Message>> groupedMessages = {};
    
    for (final message in messages) {
      final key = message.counterpartDisplayName;
      groupedMessages.putIfAbsent(key, () => []).add(message);
    }
    
    conversationThreads = groupedMessages.entries.map((entry) {
      final sortedMessages = entry.value..sort((a, b) => a.sentAt.compareTo(b.sentAt));
      return ConversationThread(
        counterpartName: entry.key,
        messages: sortedMessages,
        lastMessageTime: sortedMessages.last.sentAt,
        hasUnread: sortedMessages.any((msg) => !msg.isRead && !msg.isSent),
      );
    }).toList();
    
    conversationThreads.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
    
    // 읽지 않은 메시지가 있는 스레드 자동 펼치기
    for (final thread in conversationThreads) {
      if (thread.hasUnread) {
        expandedThreads.add(thread.counterpartName);
      }
    }
  }

  // 전체 펼치기/접기 토글
  void _toggleAllThreads() {
    setState(() {
      if (_allExpanded) {
        // 모두 접기
        expandedThreads.clear();
        _allExpanded = false;
      } else {
        // 모두 펼치기
        expandedThreads.addAll(conversationThreads.map((t) => t.counterpartName));
        _allExpanded = true;
      }
    });
  }

  // 메시지 상세 조회 및 확장/축소
  Future<void> _toggleMessageExpansion(Message message) async {
    final messageId = message.messageId;
    
    if (expandedMessages.contains(messageId)) {
      // 이미 확장된 상태면 축소
      setState(() {
        expandedMessages.remove(messageId);
      });
    } else {
      // 축소된 상태면 상세 조회 후 확장
      if (fullMessageContents.containsKey(messageId)) {
        // 이미 캐시된 내용이 있으면 바로 확장
        setState(() {
          expandedMessages.add(messageId);
        });
      } else {
        // 캐시된 내용이 없으면 API 호출
        try {
          final detailMessage = await MessageService.getMessageDetail(messageId);
          if (mounted && detailMessage != null) {
            setState(() {
              expandedMessages.add(messageId);
              fullMessageContents[messageId] = detailMessage['content'] ?? message.content;
            });
          }
        } catch (e) {
          print('메시지 상세 조회 오류: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('메시지를 불러올 수 없습니다.'), backgroundColor: Colors.red),
            );
          }
        }
      }
    }
  }

  // 답장 보내기
  Future<void> _sendReply(ConversationThread thread, String content) async {
    if (content.trim().isEmpty) return;
    
    try {
      final firstMessage = thread.messages.first;
      await MessageService.sendReply(firstMessage.messageId, content);
      await AlertService.updateAlertStatus();
      await _loadMessages(); // 새로고침
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('답장을 보냈습니다! 📩'), backgroundColor: AppTheme.primaryColor),
        );
      }
    } catch (e) {
      print('답장 전송 오류: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('답장 전송에 실패했습니다.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // 메시지 삭제
  Future<void> _deleteMessage(Message message) async {
    try {
      await MessageService.deleteMessage(message.messageId);
      await AlertService.updateAlertStatus();
      await _loadMessages(); // 새로고침
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('메시지가 삭제되었습니다.'), backgroundColor: AppTheme.primaryColor),
        );
      }
    } catch (e) {
      print('메시지 삭제 오류: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('삭제에 실패했습니다.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // 스레드 전체 삭제
  Future<void> _deleteThread(ConversationThread thread) async {
    try {
      for (final message in thread.messages) {
        await MessageService.deleteMessage(message.messageId);
      }
      await AlertService.updateAlertStatus();
      await _loadMessages(); // 새로고침
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('대화가 삭제되었습니다.'), backgroundColor: AppTheme.primaryColor),
        );
      }
    } catch (e) {
      print('스레드 삭제 오류: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('삭제에 실패했습니다.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // 답장 다이얼로그
  void _showReplyDialog(ConversationThread thread) {
    _replyController.clear();
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(20),
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('${thread.counterpartName}에게 답장', 
                       style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _replyController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: '답장 내용을 입력하세요...',
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('취소', style: TextStyle(color: AppTheme.textColor)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () async {
                      final content = _replyController.text.trim();
                      if (content.isNotEmpty) {
                        Navigator.pop(context);
                        await _sendReply(thread, content);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('보내기'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 메시지 삭제 확인 다이얼로그
  void _showDeleteMessageDialog(Message message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('메시지 삭제'),
        content: Text('이 메시지를 삭제하시겠습니까?\n\n"${message.content}"'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소', style: TextStyle(color: AppTheme.textColor)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteMessage(message);
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // 스레드 삭제 확인 다이얼로그
  void _showDeleteThreadDialog(ConversationThread thread) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('대화 삭제'),
        content: Text('${thread.counterpartName}과의 모든 대화(${thread.messages.length}개)를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소', style: TextStyle(color: AppTheme.textColor)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteThread(thread);
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.accentColor, // 공지사항과 같은 배경색
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
          // 모던한 펼치기/접기 아이콘
          IconButton(
            onPressed: _toggleAllThreads,
            icon: Icon(
              _allExpanded ? Icons.unfold_less : Icons.unfold_more,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
      body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : conversationThreads.isEmpty
          ? const Center(child: Text('쪽지가 없습니다.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: conversationThreads.length,
              itemBuilder: (context, index) => _buildConversationThread(conversationThreads[index]),
            ),
    );
  }

  Widget _buildConversationThread(ConversationThread thread) {
    final isExpanded = expandedThreads.contains(thread.counterpartName);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 스레드 헤더
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: thread.hasUnread ? AppTheme.primaryColor.withOpacity(0.1) : Colors.transparent,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: InkWell(
              onTap: () {
                setState(() {
                  if (isExpanded) {
                    expandedThreads.remove(thread.counterpartName);
                  } else {
                    expandedThreads.add(thread.counterpartName);
                  }
                });
              },
              child: Row(
                children: [
                  // 프로필 아바타
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryColor,
                          AppTheme.primaryColor.withOpacity(0.7),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        thread.counterpartName[0],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // 메시지 정보
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              thread.counterpartName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textColor,
                              ),
                            ),
                            if (thread.hasUnread) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${thread.messages.where((m) => !m.isRead && !m.isSent).length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        if (!isExpanded)
                          Text(
                            thread.messages.last.content,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textColor.withOpacity(0.7),
                            ),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          thread.messages.last.formattedDate,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textColor.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 휴지통 아이콘만 우측 끝에 배치
                  IconButton(
                    onPressed: () => _showDeleteThreadDialog(thread),
                    icon: const Icon(Icons.delete_outline),
                    color: Colors.grey.withOpacity(0.6),
                  ),
                ],
              ),
            ),
          ),
          // 펼쳐진 상태일 때만 메시지 스레드 표시
          if (isExpanded) ...[
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: thread.messages.asMap().entries.map((entry) {
                  final index = entry.key;
                  final message = entry.value;
                  final isFirst = index == 0;
                  
                  return _buildMessageBubble(message, isFirst);
                }).toList(),
              ),
            ),
            // 답장 버튼
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showReplyDialog(thread),
                  icon: const Icon(Icons.reply, size: 18),
                  label: const Text('답장하기'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message, bool isFirst) {
    return Container(
      margin: EdgeInsets.only(
        bottom: 12,
        left: isFirst ? 0 : 24,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isFirst)
            Container(
              margin: const EdgeInsets.only(right: 12, top: 8),
              child: Icon(
                Icons.subdirectory_arrow_right,
                size: 16,
                color: AppTheme.primaryColor.withOpacity(0.6),
              ),
            ),
          Expanded(
            child: GestureDetector(
              onTap: () => _toggleMessageExpansion(message),
              onLongPress: () => _showDeleteMessageDialog(message),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: message.isSent 
                    ? LinearGradient(
                        colors: [
                          AppTheme.primaryColor.withOpacity(0.1),
                          AppTheme.primaryColor.withOpacity(0.05),
                        ],
                      )
                    : LinearGradient(
                        colors: [
                          AppTheme.accentColor,
                          AppTheme.accentColor.withOpacity(0.7),
                        ],
                      ),
                  borderRadius: BorderRadius.circular(12),
                  border: message.isSent 
                    ? Border.all(color: AppTheme.primaryColor.withOpacity(0.3))
                    : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 5,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: message.isSent 
                              ? AppTheme.primaryColor.withOpacity(0.2)
                              : Colors.white.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                message.isSent ? Icons.send : Icons.inbox,
                                size: 14,
                                color: message.isSent ? AppTheme.primaryColor : AppTheme.textColor.withOpacity(0.7),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                message.isSent ? '나' : '상대방',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: message.isSent ? AppTheme.primaryColor : AppTheme.textColor.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Text(
                          message.formattedDate,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.textColor.withOpacity(0.5),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // 심플한 삭제 버튼 (동그라미 배경 제거)
                        GestureDetector(
                          onTap: () => _showDeleteMessageDialog(message),
                          child: Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.grey.withOpacity(0.6), // 회색으로 변경
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // 메시지 내용 (미리보기 또는 전체 표시)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          expandedMessages.contains(message.messageId) 
                            ? (fullMessageContents[message.messageId] ?? message.content)
                            : message.content,
                          maxLines: expandedMessages.contains(message.messageId) ? null : null,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textColor,
                            height: 1.5,
                          ),
                        ),
                        if (message.content.endsWith('...') && !expandedMessages.contains(message.messageId))
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '탭하여 전체 내용 보기',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.primaryColor.withOpacity(0.7),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        if (expandedMessages.contains(message.messageId) && fullMessageContents[message.messageId] != message.content)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '탭하여 접기',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.primaryColor.withOpacity(0.7),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 대화 스레드 모델
class ConversationThread {
  final String counterpartName;
  final List<Message> messages;
  final DateTime lastMessageTime;
  final bool hasUnread;

  ConversationThread({
    required this.counterpartName,
    required this.messages,
    required this.lastMessageTime,
    required this.hasUnread,
  });
} 