import 'package:flutter_test/flutter_test.dart';
import 'package:edumeet/core/services/zego_service.dart';

void main() {
  group('ZegoService Unit Tests', () {
    test('generateRoomId produces valid prefixed room IDs', () {
      final roomId1 = ZegoService.generateRoomId();
      expect(roomId1.startsWith('edumeet_'), isTrue);
      expect(roomId1.length, greaterThan(8));

      final customRoom = ZegoService.generateRoomId(prefix: 'physics101');
      expect(customRoom.startsWith('physics101_'), isTrue);
    });

    test('Credentials validation requires explicit non-zero app ID and non-empty sign', () {
      // By default in test environment, no --dart-define is set
      expect(ZegoService.appId, 0);
      expect(ZegoService.appSign, isEmpty);
      expect(ZegoService.hasValidCredentials, isFalse);
    });

    test('initUser rejects gracefully when credentials are not configured', () async {
      final success = await ZegoService.initUser(
        userId: 'test_user',
        userName: 'Test User',
      );
      expect(success, isFalse);
    });

    test('joinClassroom rejects gracefully when credentials are not configured', () async {
      final success = await ZegoService.joinClassroom(
        roomId: 'test_room',
        isTeacher: true,
      );
      expect(success, isFalse);
    });
  });
}

