import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edumeet/features/chat/domain/entities/chat_entity.dart';
import 'package:edumeet/features/chat/presentation/providers/chat_provider.dart';

void main() {
  group('Chat & Announcements Repository Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('Loads pre-seeded Stitch conversations', () async {
      final repo = container.read(chatRepositoryProvider);
      final conversations = await repo.getConversations().first;

      expect(conversations.isNotEmpty, true);
      expect(conversations.any((c) => c.title.contains('Advanced Mathematics')), true);
      expect(conversations.any((c) => c.isPinned), true);
    });

    test('Loads announcements and alerts', () async {
      final repo = container.read(chatRepositoryProvider);
      final announcements = await repo.getAnnouncements().first;
      final alerts = await repo.getNotifications().first;

      expect(announcements.isNotEmpty, true);
      expect(announcements.any((a) => a.title.contains('Mid-Term Examination')), true);

      expect(alerts.isNotEmpty, true);
      expect(alerts.any((n) => n.title.contains('Assignment Graded')), true);
    });

    test('Sending a message appends to conversation messages stream', () async {
      final repo = container.read(chatRepositoryProvider);
      const convId = 'conv_math_group';

      final initialMessages = await repo.getMessages(convId).first;
      final initialCount = initialMessages.length;

      final testMessage = ChatMessageEntity(
        id: 'msg_test_${DateTime.now().millisecondsSinceEpoch}',
        conversationId: convId,
        senderId: 'student_sarah_01',
        senderName: 'Sarah Rivera',
        senderAvatar: null,
        senderRole: 'Student',
        text: 'Hello team, the problem set notes have been reviewed!',
        timestamp: DateTime.now(),
      );

      await repo.sendMessage(testMessage);
      final updatedMessages = await repo.getMessages(convId).first;

      expect(updatedMessages.length, initialCount + 1);
      expect(updatedMessages.last.text, contains('problem set notes'));
    });
  });
}
