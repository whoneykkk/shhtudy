class NotificationModel {
  final int id;
  final String title;
  final String message;
  final DateTime createdAt;
  final NotificationType type;
  final bool isRead;
  final String? relatedId; // 관련 항목 ID (예: 메시지 ID, 공지사항 ID 등)

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.type,
    this.isRead = false,
    this.relatedId,
  });

  // JSON 변환 메소드
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      createdAt: DateTime.parse(json['created_at']),
      type: NotificationType.values.firstWhere(
        (type) => type.toString().split('.').last == json['type'],
        orElse: () => NotificationType.system,
      ),
      isRead: json['is_read'] ?? false,
      relatedId: json['related_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'created_at': createdAt.toIso8601String(),
      'type': type.toString().split('.').last,
      'is_read': isRead,
      'related_id': relatedId,
    };
  }

  // 알림 아이콘 선택 도우미 메소드
  IconData get icon {
    switch (type) {
      case NotificationType.message:
        return Icons.mail_outline;
      case NotificationType.notice:
        return Icons.campaign_outlined;
      case NotificationType.system:
        return Icons.notifications_outlined;
      case NotificationType.error:
        return Icons.error_outline;
    }
  }
  
  // 시간 포맷팅 도우미 메소드
  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    // 1시간 이내
    if (difference.inHours < 1) {
      return '${difference.inMinutes}분 전';
    }
    // 오늘
    else if (now.day == createdAt.day && now.month == createdAt.month && now.year == createdAt.year) {
      return '${createdAt.hour}:${createdAt.minute < 10 ? '0' : ''}${createdAt.minute}';
    }
    // 어제
    else if (now.day - createdAt.day == 1 && now.month == createdAt.month && now.year == createdAt.year) {
      return '어제';
    }
    // 일주일 이내
    else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    }
    // 그 외
    else {
      return '${createdAt.year}.${createdAt.month}.${createdAt.day}';
    }
  }
}

// 알림 타입 열거형
enum NotificationType {
  message,  // 쪽지 알림
  notice,   // 공지사항 알림
  system,   // 시스템 알림
  error,    // 오류 알림
}

// 알림 클릭 핸들러를 위한 콜백 타입 정의
typedef NotificationTapCallback = void Function(NotificationModel notification);

// 알림 관리 클래스 (플러터에서 import 하지 않고도 사용하기 위해 직접 정의)
class Icons {
  static const mail_outline = 0xe3eb;
  static const campaign_outlined = 0xe1ca;
  static const notifications_outlined = 0xe4a0;
  static const error_outline = 0xe1c8;
} 