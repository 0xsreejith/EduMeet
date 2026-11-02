import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/chat_entity.dart';
import '../../data/repositories/mock_chat_repository.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return MockChatRepository();
});

final conversationsStreamProvider = StreamProvider<List<ChatConversationEntity>>((ref) {
  final repo = ref.watch(chatRepositoryProvider);
  return repo.getConversations();
});

final messagesFamilyProvider =
    StreamProvider.family<List<ChatMessageEntity>, String>((ref, conversationId) {
  final repo = ref.watch(chatRepositoryProvider);
  return repo.getMessages(conversationId);
});

final announcementsStreamProvider = StreamProvider<List<AnnouncementEntity>>((ref) {
  final repo = ref.watch(chatRepositoryProvider);
  return repo.getAnnouncements();
});

final notificationsStreamProvider = StreamProvider<List<NotificationAlertEntity>>((ref) {
  final repo = ref.watch(chatRepositoryProvider);
  return repo.getNotifications();
});

