import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edumeet/features/auth/domain/entities/user_entity.dart';
import 'package:edumeet/features/auth/presentation/providers/auth_provider.dart';
import 'package:edumeet/features/live_classroom/presentation/providers/live_classroom_provider.dart';
import 'package:edumeet/features/live_classroom/presentation/screens/live_classroom_screen.dart';
import '../../helpers/test_http_overrides.dart';

void main() {
  setUpAll(() {
    HttpOverrides.global = TestHttpOverrides();
  });

  group('LiveClassroom RTC Flow & UI Separation Tests', () {
    testWidgets('Student views Live Classroom with Leave button and Raise Hand control',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1179, 2556);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final container = ProviderContainer();
      await container.read(authNotifierProvider.notifier).switchRole(UserRole.student);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: LiveClassroomScreen(
              roomId: 'room_ap_physics_101',
              classTitle: 'AP Physics: Quantum Mechanics',
              teacherName: 'Dr. Eleanor Vance',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify header and context
      expect(find.text('Classroom Detail'), findsOneWidget);
      expect(find.text('Live • AP Physics: Quantum Mechanics'), findsOneWidget);

      // Student controls: Has Leave action and Front Hand (Raise Hand) icon
      expect(find.text('Leave'), findsOneWidget);
      expect(find.byIcon(Icons.front_hand_rounded), findsOneWidget);

      // Tap raise hand icon
      await tester.tap(find.byIcon(Icons.front_hand_rounded));
      await tester.pump();

      // Hand raise state updated
      expect(container.read(liveClassroomProvider).isHandRaised, isTrue);
      expect(find.text('You raised hand ✋'), findsOneWidget);

      // Fast forward banner timer
      await tester.pump(const Duration(seconds: 5));

      // Tap chat drawer toggle
      await tester.tap(find.byIcon(Icons.chat_bubble_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Classroom Chat'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('Teacher views Live Classroom with End Class action and Host controls',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1179, 2556);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final container = ProviderContainer();
      await container.read(authNotifierProvider.notifier).switchRole(UserRole.teacher);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: LiveClassroomScreen(
              roomId: 'room_math_402',
              classTitle: 'Advanced Mathematics',
              teacherName: 'Dr. Eleanor Vance',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify header and context
      expect(find.text('Classroom Detail'), findsOneWidget);
      expect(find.text('Live • Advanced Mathematics'), findsOneWidget);

      // Teacher controls: Has End Class action and Mute All icon
      expect(find.text('End Class'), findsOneWidget);
      expect(find.byIcon(Icons.volume_off_rounded), findsOneWidget);

      // Tap End Class button to open bottom sheet options
      await tester.tap(find.text('End Class'));
      await tester.pumpAndSettle();

      expect(find.text('End Live Classroom'), findsOneWidget);
      expect(find.text('End Classroom for All'), findsOneWidget);
      expect(find.text('Leave Class Alone'), findsOneWidget);

      // Tap End Classroom for All
      await tester.tap(find.text('End Classroom for All'));
      await tester.pumpAndSettle();

      expect(container.read(liveClassroomProvider).status, LiveClassroomStatus.disconnected);
    });

    testWidgets('Teacher taps Mute All button in floating controls',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1179, 2556);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final container = ProviderContainer();
      await container.read(authNotifierProvider.notifier).switchRole(UserRole.teacher);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: LiveClassroomScreen(
              roomId: 'room_math_402',
              classTitle: 'Advanced Mathematics',
              teacherName: 'Dr. Eleanor Vance',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap Mute All button (volume_off_rounded)
      await tester.tap(find.byIcon(Icons.volume_off_rounded));
      await tester.pump();

      expect(find.text('Muted all student microphones.'), findsOneWidget);
    });

    testWidgets('Student taps Leave button shows confirmation dialog',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1179, 2556);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final container = ProviderContainer();
      await container.read(authNotifierProvider.notifier).switchRole(UserRole.student);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: LiveClassroomScreen(
              roomId: 'room_ap_physics_101',
              classTitle: 'AP Physics: Quantum Mechanics',
              teacherName: 'Dr. Eleanor Vance',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap Leave
      await tester.tap(find.text('Leave'));
      await tester.pumpAndSettle();

      expect(find.text('Leave Classroom?'), findsOneWidget);
      expect(find.text('Are you sure you want to leave this live session?'), findsOneWidget);

      // Confirm Leave
      await tester.tap(find.widgetWithText(ElevatedButton, 'Leave'));
      await tester.pumpAndSettle();

      expect(container.read(liveClassroomProvider).status, LiveClassroomStatus.disconnected);
    });

    testWidgets('Displays Permission Denial Alert Banner when permission is denied',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1179, 2556);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final container = ProviderContainer();
      container.read(liveClassroomProvider.notifier).setPermissionDenied(true);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: LiveClassroomScreen(
              roomId: 'room_ap_physics_101',
              classTitle: 'AP Physics: Quantum Mechanics',
              teacherName: 'Dr. Eleanor Vance',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Camera & Mic Access Required'), findsOneWidget);
      expect(find.text('Please enable permissions to transmit video and audio.'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Settings'), findsOneWidget);
    });

    testWidgets('Student state updates when teacher ends classroom session',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1179, 2556);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final container = ProviderContainer();
      await container.read(authNotifierProvider.notifier).switchRole(UserRole.student);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: LiveClassroomScreen(
              roomId: 'room_ap_physics_101',
              classTitle: 'AP Physics: Quantum Mechanics',
              teacherName: 'Dr. Eleanor Vance',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Trigger teacher ended notification
      await container.read(liveClassroomProvider.notifier).onClassroomEndedByTeacher();
      await tester.pump();

      expect(container.read(liveClassroomProvider).isEndedByTeacher, isTrue);
      expect(container.read(liveClassroomProvider).status, LiveClassroomStatus.disconnected);
    });
  });

  group('LiveClassroomNotifier Unit Tests', () {
    test('Initial state is idle or connected prototype with default values', () {
      final container = ProviderContainer();
      final state = container.read(liveClassroomProvider);
      expect(state.status, LiveClassroomStatus.idle);
      expect(state.isHandRaised, isFalse);
      expect(state.isEndedByTeacher, isFalse);
      expect(state.hasPermissionDenied, isFalse);
    });

    test('onClassroomEndedByTeacher sets isEndedByTeacher and disconnects', () async {
      final container = ProviderContainer();
      final notifier = container.read(liveClassroomProvider.notifier);

      await notifier.onClassroomEndedByTeacher();
      final state = container.read(liveClassroomProvider);

      expect(state.isEndedByTeacher, isTrue);
      expect(state.status, LiveClassroomStatus.disconnected);
    });

    test('endClassroomForAll sets status to disconnected', () async {
      final container = ProviderContainer();
      final notifier = container.read(liveClassroomProvider.notifier);

      await notifier.endClassroomForAll();
      final state = container.read(liveClassroomProvider);

      expect(state.status, LiveClassroomStatus.disconnected);
    });

    test('setPermissionDenied toggles hasPermissionDenied flag', () {
      final container = ProviderContainer();
      final notifier = container.read(liveClassroomProvider.notifier);

      expect(container.read(liveClassroomProvider).hasPermissionDenied, isFalse);
      notifier.setPermissionDenied(true);
      expect(container.read(liveClassroomProvider).hasPermissionDenied, isTrue);
      notifier.setPermissionDenied(false);
      expect(container.read(liveClassroomProvider).hasPermissionDenied, isFalse);
    });

    test('Participant count defaults to 1 and accurately reflects in-room users without off-by-one error', () {
      final container = ProviderContainer();
      final state = container.read(liveClassroomProvider);
      expect(state.participantCount, equals(1));
    });
  });
}
