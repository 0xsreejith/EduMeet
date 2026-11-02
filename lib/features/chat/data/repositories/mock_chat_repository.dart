import 'dart:async';
import '../../domain/entities/chat_entity.dart';

abstract class ChatRepository {
  Stream<List<ChatConversationEntity>> getConversations();
  Stream<List<ChatMessageEntity>> getMessages(String conversationId);
  Stream<List<AnnouncementEntity>> getAnnouncements();
  Stream<List<NotificationAlertEntity>> getNotifications();
  Future<void> sendMessage(ChatMessageEntity message);
  Future<void> markNotificationsAsRead();
}

class MockChatRepository implements ChatRepository {
  final _conversationsController = StreamController<List<ChatConversationEntity>>.broadcast();
  final _messagesController = StreamController<Map<String, List<ChatMessageEntity>>>.broadcast();
  final _announcementsController = StreamController<List<AnnouncementEntity>>.broadcast();
  final _notificationsController = StreamController<List<NotificationAlertEntity>>.broadcast();

  final List<ChatConversationEntity> _conversations = [
    const ChatConversationEntity(
      id: 'conv_math_group',
      title: 'Advanced Mathematics Group',
      lastMessage: "Prof. Harrison: Don't forget the problem set submission by Friday!",
      lastMessageTime: '10:42 AM',
      unreadCount: 2,
      isPinned: true,
      isOnline: true,
      avatarUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDvmcMnkDVCqv8QycMVfWr1x1lD9dSrUTTVAOlwFeiNGw3SKaW3gLjYk-4gtvyHwpL7WrOLv4jDT1cviGC3sC-Ke3WW7wXztREOp7GNYLseb2whqOpW8xUUfnpYBKWB6mhfKhLawlOTqf8u2fseatMINdw2FWmmQ4578QVlLayIrgwIFD3Nk-VtWtU2aJszqoA1YY05ywg-HZMBJo8DUP6lyq97PnVLf6_D1EHidYM',
    ),
    const ChatConversationEntity(
      id: 'conv_prof_sarah',
      title: 'Prof. Sarah Jenkins',
      lastMessage: 'Great job on your UI/UX case study review! Keep it up.',
      lastMessageTime: 'Yesterday',
      unreadCount: 1,
      isOnline: true,
      avatarUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCLMiLHURG7rLEZkK9TRhrETFhVCnrIY0gmd6hHY4mCf-NON6UBHRgvo75fDoFEf6dFHFwn1eePPjZr47poN42POH5PMs8xtlpKHkDWr9QTbpaRv0TtK_3vHQShOdJ5FsYJqnsOyBuISKsQ1GR_RL7ajMTXf7WGmz4D_Z6915w7I6cLkTnpIUdbBK__290WgcwWZl6mCekr1i-HdwKJXjKT9_EDCK715FFLPj-yOmw',
    ),
    const ChatConversationEntity(
      id: 'conv_physics_circle',
      title: 'Physics Study Circle',
      lastMessage: 'Alex: Are we meeting at the library at 4 PM?',
      lastMessageTime: 'Oct 24',
      avatarUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDyrtUS4X1vQHqLV4fuRI1IiRA96nCJxKZX_xZi53qMycsqWZWLMqMcjDCBb1rLuEkjd2ENnVaZqj2oEgXhPTLIxYgIqBI7tWhU57nwwir86RJ6Isc8VcTZ7NNLSZP3iUX_fRIaq88eXg_R2du8uclAd7GBNtqw6f7sfqJz4A7uLfKKn2O4v4XXxI8BHPaaTrfXOQf8pPaJAINwdU9nLgAGFrumm56XxiKBxGGKY70',
    ),
    const ChatConversationEntity(
      id: 'conv_alan_turing',
      title: 'Dr. Alan Turing',
      lastMessage: "Your algorithm optimization looks solid. Let's discuss tomorrow.",
      lastMessageTime: 'Oct 21',
      avatarUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDkuYA25yBS8dNZ1zYQsJ9SPzn8CqkRCT15RI-JnVCN041dm-4LmD-xHo8ghQeNl4cCcWKAXrg21VHwzYA3Cy41_fayrNAxNWyThZKC0zCLedDhUUVoPsme2GBsxhyLwqjpsG3Xpx2eayvXxVMn56rU9GLVnTMas3nfZTClElQV2WJrS5VUYuV3VmDiDM_nMRNJ4rvGfuzXB9koIIYlGJ8mUJdRO_tTuj1R1uEkIEI',
    ),
  ];

  final Map<String, List<ChatMessageEntity>> _messagesByConv = {
    'conv_math_group': [
      ChatMessageEntity(
        id: 'msg_01',
        conversationId: 'conv_math_group',
        senderId: 'teacher_eleanor_01',
        senderName: 'Dr. Eleanor Vance',
        senderRole: 'Teacher',
        text: 'Hello! Welcome to the session channel. Feel free to ask questions here.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
      ChatMessageEntity(
        id: 'msg_02',
        conversationId: 'conv_math_group',
        senderId: 'student_sarah_01',
        senderName: 'Sarah Rivera',
        senderRole: 'Student',
        text: 'Thank you! I had a quick question regarding the assignment rubric.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
      ),
      ChatMessageEntity(
        id: 'msg_03',
        conversationId: 'conv_math_group',
        senderId: 'teacher_eleanor_01',
        senderName: 'Dr. Eleanor Vance',
        senderRole: 'Teacher',
        text: 'Please check page 42 for the wave-particle duality theorem summary.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
      ),
      ChatMessageEntity(
        id: 'msg_04',
        conversationId: 'conv_math_group',
        senderId: 'student_alex_02',
        senderName: 'Alex M.',
        senderRole: 'Student',
        text: 'Thank you! That makes total sense now.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
      ),
    ],
  };

  final List<AnnouncementEntity> _announcements = [
    const AnnouncementEntity(
      id: 'ann_01',
      title: 'Mid-Term Examination Schedule Released',
      content:
          'The upcoming mid-term exams for all enrolled courses will begin next Monday. Please check your student portal for room allocations and detailed syllabi.',
      postedBy: 'Posted by Academic Office',
      timeAgo: '2h ago',
      isPinned: true,
      actionLabel: 'View Portal',
    ),
    const AnnouncementEntity(
      id: 'ann_02',
      title: 'Annual Tech Hackathon 2024',
      content:
          'Register your teams of up to 4 students for the 48-hour coding sprint. Exciting prizes and mentorship sessions with industry leaders await!',
      postedBy: 'Posted by CS Department',
      timeAgo: 'Yesterday',
      actionLabel: 'Register Team',
    ),
  ];

  List<NotificationAlertEntity> _notifications = [
    const NotificationAlertEntity(
      id: 'notif_01',
      title: 'Assignment Graded',
      message: 'Prof. Sarah Jenkins graded your submission for "UI/UX Wireframing". Score: 96/100',
      timeAgo: '15m ago',
      type: 'assignment',
    ),
    const NotificationAlertEntity(
      id: 'notif_02',
      title: 'Live Class Starting Soon',
      message: '"Advanced Mathematics Lecture 8" begins in 15 minutes. Get your notes ready!',
      timeAgo: '1h ago',
      type: 'live_class',
    ),
    const NotificationAlertEntity(
      id: 'notif_03',
      title: 'New Reply in Forum',
      message: 'Alex replied to your discussion thread in Physics Study Circle.',
      timeAgo: '3h ago',
      type: 'forum',
    ),
  ];

  MockChatRepository() {
    _conversationsController.add(_conversations);
    _messagesController.add(_messagesByConv);
    _announcementsController.add(_announcements);
    _notificationsController.add(_notifications);
  }

  @override
  Stream<List<ChatConversationEntity>> getConversations() async* {
    yield _conversations;
    yield* _conversationsController.stream;
  }

  @override
  Stream<List<ChatMessageEntity>> getMessages(String conversationId) async* {
    yield _messagesByConv[conversationId] ?? [];
    yield* _messagesController.stream.map((map) => map[conversationId] ?? []);
  }

  @override
  Stream<List<AnnouncementEntity>> getAnnouncements() async* {
    yield _announcements;
    yield* _announcementsController.stream;
  }

  @override
  Stream<List<NotificationAlertEntity>> getNotifications() async* {
    yield _notifications;
    yield* _notificationsController.stream;
  }

  @override
  Future<void> sendMessage(ChatMessageEntity message) async {
    final list = _messagesByConv.putIfAbsent(message.conversationId, () => []);
    list.add(message);
    _messagesController.add(Map.from(_messagesByConv));
  }

  @override
  Future<void> markNotificationsAsRead() async {
    _notifications = _notifications
        .map(
          (n) => NotificationAlertEntity(
            id: n.id,
            title: n.title,
            message: n.message,
            timeAgo: n.timeAgo,
            type: n.type,
            isRead: true,
          ),
        )
        .toList();
    _notificationsController.add(List.from(_notifications));
  }
}

