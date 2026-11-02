import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edumeet/features/auth/domain/entities/user_entity.dart';
import 'package:edumeet/features/auth/presentation/providers/auth_provider.dart';
import 'package:edumeet/features/grades/presentation/screens/student_profile_grades_screen.dart';
import 'package:edumeet/features/home/presentation/screens/home_dashboard_screen.dart';
import 'package:edumeet/features/live_classroom/presentation/screens/live_classroom_screen.dart';
import 'helpers/test_http_overrides.dart';

void main() {
  setUpAll(() {
    HttpOverrides.global = TestHttpOverrides();
  });

  group('Responsive Layout & Overflow Verification Tests', () {
    testWidgets('StudentProfileGradesScreen renders with Dr. Eleanor Vance without overflow on iPhone 17',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1179, 2556);
      tester.view.devicePixelRatio = 3.0; // 393 x 852 logical
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final container = ProviderContainer();
      // Authenticate as teacher (Dr. Eleanor Vance with long title)
      await container.read(authNotifierProvider.notifier).switchRole(UserRole.teacher);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: StudentProfileGradesScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Dr. Eleanor Vance'), findsOneWidget);
      expect(find.text('FACULTY-01'), findsOneWidget);
      expect(find.byType(StudentProfileGradesScreen), findsOneWidget);
    });

    testWidgets('StudentProfileGradesScreen renders without overflow on compact iPhone SE (320x568)',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(640, 1136);
      tester.view.devicePixelRatio = 2.0; // 320 x 568 logical
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final container = ProviderContainer();
      await container.read(authNotifierProvider.notifier).switchRole(UserRole.teacher);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: StudentProfileGradesScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Dr. Eleanor Vance'), findsOneWidget);
    });

    testWidgets('HomeDashboardScreen renders without overflow on iPad tablet (1024x1366)',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(2048, 2732);
      tester.view.devicePixelRatio = 2.0; // 1024 x 1366 logical
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HomeDashboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(HomeDashboardScreen), findsOneWidget);
    });

    testWidgets('LiveClassroomScreen renders long title "React & Modern Hooks Architecture" without overflow on iPhone 17 (393x852)',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1179, 2556);
      tester.view.devicePixelRatio = 3.0; // 393 x 852 logical
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final container = ProviderContainer();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: LiveClassroomScreen(
              roomId: 'room_react_101',
              classTitle: 'React & Modern Hooks Architecture',
              teacherName: 'Marcus Chen',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Classroom Detail'), findsOneWidget);
      expect(find.textContaining('React & Modern Hooks Architecture'), findsOneWidget);
      expect(find.text('24'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('LiveClassroomScreen renders long title without overflow on compact iPhone SE (320x568)',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(640, 1136);
      tester.view.devicePixelRatio = 2.0; // 320 x 568 logical
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final container = ProviderContainer();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: LiveClassroomScreen(
              roomId: 'room_react_101',
              classTitle: 'React & Modern Hooks Architecture',
              teacherName: 'Marcus Chen',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Classroom Detail'), findsOneWidget);
      expect(find.text('24'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}

