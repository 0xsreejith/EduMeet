class ChatMessageEntity {
  final String id;
  final String conversationId; // classId or direct userId
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final String senderRole; // 'Teacher' or 'Student'
  final String text;
  final DateTime timestamp;
  final bool isPinned;

  const ChatMessageEntity({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.senderRole,
    required this.text,
    required this.timestamp,
    this.isPinned = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'senderName': senderName,
      'senderAvatar': senderAvatar,
      'senderRole': senderRole,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'isPinned': isPinned,
    };
  }

  factory ChatMessageEntity.fromMap(Map<String, dynamic> map, String id) {
    return ChatMessageEntity(
      id: id,
      conversationId: map['conversationId'] as String? ?? '',
      senderId: map['senderId'] as String? ?? '',
      senderName: map['senderName'] as String? ?? '',
      senderAvatar: map['senderAvatar'] as String?,
      senderRole: map['senderRole'] as String? ?? 'Student',
      text: map['text'] as String? ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
      isPinned: map['isPinned'] as bool? ?? false,
    );
  }
}

class ChatConversationEntity {
  final String id;
  final String title;
  final String lastMessage;
  final String lastMessageTime;
  final String? avatarUrl;
  final int unreadCount;
  final bool isPinned;
  final bool isOnline;

  const ChatConversationEntity({
    required this.id,
    required this.title,
    required this.lastMessage,
    required this.lastMessageTime,
    this.avatarUrl,
    this.unreadCount = 0,
    this.isPinned = false,
    this.isOnline = false,
  });
}

class AnnouncementEntity {
  final String id;
  final String title;
  final String content;
  final String postedBy;
  final String timeAgo;
  final bool isPinned;
  final String? actionLabel;

  const AnnouncementEntity({
    required this.id,
    required this.title,
    required this.content,
    required this.postedBy,
    required this.timeAgo,
    this.isPinned = false,
    this.actionLabel,
  });
}

class NotificationAlertEntity {
  final String id;
  final String title;
  final String message;
  final String timeAgo;
  final String type; // 'assignment', 'live_class', 'forum'
  final bool isRead;

  const NotificationAlertEntity({
    required this.id,
    required this.title,
    required this.message,
    required this.timeAgo,
    required this.type,
    this.isRead = false,
  });
}

