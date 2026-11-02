import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edumeet/core/services/zego_service.dart';
import 'package:edumeet/features/auth/domain/entities/user_entity.dart';
import 'package:edumeet/features/auth/presentation/providers/auth_provider.dart';
import 'package:edumeet/features/live_classroom/presentation/dialogs/dev_rtc_launcher_sheet.dart';
import '../../helpers/test_http_overrides.dart';

void main() {
  setUpAll(() {
    HttpOverrides.global = TestHttpOverrides();
  });

  group('DevRtcLauncherSheet & Unique User ID Tests', () {
    test('ZegoService generates unique user ID containing session suffix', () {
      final userId1 = ZegoService.generateUniqueUserId('student_sarah_01');
      final userId2 = ZegoService.generateUniqueUserId('teacher_eleanor_01');

      expect(userId1.startsWith('student_sarah_01_'), isTrue);
      expect(userId2.startsWith('teacher_eleanor_01_'), isTrue);
      expect(ZegoService.sessionInstanceSuffix.isNotEmpty, isTrue);
    });

    testWidgets('DevRtcLauncherSheet renders role cards, manual Room ID, and unique test ID',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1179, 2556);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final container = ProviderContainer();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => DevRtcLauncherSheet.show(context),
                  child: const Text('Open Sheet'),
                ),
              ),
            ),
          ),
        ),
      );

      // Open bottom sheet
      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      // Verify Header & Credential Status
      expect(find.text('DEV RTC TEST'), findsOneWidget);
      expect(find.text('Two-Device Session'), findsOneWidget);
      expect(find.textContaining('Mock RTC Mode'), findsOneWidget);

      // Verify Role Selector Cards
      expect(find.text('Teacher (Host)'), findsOneWidget);
      expect(find.text('Student'), findsOneWidget);

      // Verify Manual Room ID field
      expect(find.text('2. Manual Room ID Entry'), findsOneWidget);
      expect(find.text('edumeet_demo_room'), findsWidgets);

      // Verify Unique Test Identity
      expect(find.text('3. Generated Test Identity'), findsOneWidget);
      expect(find.textContaining('User ID:'), findsOneWidget);

      // Tap Student role card
      await tester.tap(find.text('Student'));
      await tester.pumpAndSettle();

      expect(container.read(authNotifierProvider).user?.role, UserRole.student);
      expect(find.text('Join Live Class as Student'), findsOneWidget);

      // Tap Teacher role card
      await tester.tap(find.text('Teacher (Host)'));
      await tester.pumpAndSettle();

      expect(container.read(authNotifierProvider).user?.role, UserRole.teacher);
      expect(find.text('Start Live Class as Teacher (Host)'), findsOneWidget);

      // Test preset chips: tap physics_101
      await tester.tap(find.text('physics_101'));
      await tester.pump();

      expect(find.widgetWithText(TextField, 'physics_101'), findsOneWidget);
    });
  });
}

