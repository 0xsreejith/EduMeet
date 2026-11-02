import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edumeet/features/auth/domain/entities/user_entity.dart';
import 'package:edumeet/features/auth/presentation/providers/auth_provider.dart';
import 'package:edumeet/features/grades/presentation/screens/student_profile_grades_screen.dart';
import 'package:edumeet/features/attendance/presentation/screens/attendance_progress_screen.dart';
import 'package:edumeet/features/home/presentation/screens/home_dashboard_screen.dart';
import 'package:edumeet/features/schedule/presentation/screens/classes_schedule_screen.dart';
import '../helpers/test_http_overrides.dart';

void main() {
  setUpAll(() {
    HttpOverrides.global = TestHttpOverrides();
  });

  group('Teacher Flow Separation Tests', () {
    testWidgets('Teacher Profile renders faculty overview, managed classes, and grading, but NO student grades',
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
            home: StudentProfileGradesScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Teacher-specific assertions
      expect(find.text('Dr. Eleanor Vance'), findsOneWidget);
      expect(find.text('FACULTY-01'), findsOneWidget);
      expect(find.text('My Taught Classes'), findsOneWidget);
      expect(find.text('Pending Student Submissions'), findsOneWidget);
      expect(find.text('Teaching Performance & Insights'), findsOneWidget);

      // Student-specific assertions MUST NOT be present
      expect(find.text('Subject Grades'), findsNothing);
      expect(find.text('View Transcript'), findsNothing);
      expect(find.text('Earned Badges'), findsNothing);
    });

    testWidgets('Teacher Attendance screen renders Faculty Attendance Desk and class register',
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
            home: AttendanceProgressScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Teacher attendance desk assertions
      expect(find.text('FACULTY ATTENDANCE DESK'), findsOneWidget);
      expect(find.text('Class Register & Analytics'), findsOneWidget);
      expect(find.text("Today's Student Roster"), findsOneWidget);
      expect(find.text('Select Class to Take Attendance'), findsOneWidget);
      expect(find.text('Previous Session Reports'), findsOneWidget);

      // Student-specific standing MUST NOT be present
      expect(find.text('ATTENDANCE OVERVIEW'), findsNothing);
      expect(find.text('48 Sessions Attended'), findsNothing);
    });

    testWidgets('Teacher Home screen renders Teacher greeting and Start Teaching Live launcher',
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
            home: HomeDashboardScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Good morning, Dr. Eleanor Vance!'), findsOneWidget);
      expect(find.text('Start Teaching Live'), findsOneWidget);
      expect(find.text('Teacher Quick Controls'), findsOneWidget);
      expect(find.text("Today's Teaching Schedule"), findsOneWidget);
    });

    testWidgets('Teacher Classes & Schedule screen renders teacher classes with code copy action',
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
            home: ClassesScheduleScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('My Teaching Classes'), findsOneWidget);
      expect(find.text('+ Create Class'), findsOneWidget);
    });
  });

  group('Student Flow Separation Tests', () {
    testWidgets('Student Profile renders Sarah Rivera, subject grades, assignments and badges',
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
            home: StudentProfileGradesScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Student-specific assertions
      expect(find.text('Sarah Rivera'), findsOneWidget);
      expect(find.text('SID-88492'), findsOneWidget);
      expect(find.text('Subject Grades'), findsOneWidget);
      expect(find.text('Recent Assignments'), findsOneWidget);
      expect(find.text('Earned Badges'), findsOneWidget);

      // Teacher-specific components MUST NOT be present
      expect(find.text('My Taught Classes'), findsNothing);
      expect(find.text('Pending Student Submissions'), findsNothing);
      expect(find.text('Teaching Performance & Insights'), findsNothing);
    });

    testWidgets('Student Attendance renders personal standing and monthly matrix',
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
            home: AttendanceProgressScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Student attendance assertions
      expect(find.text('ATTENDANCE OVERVIEW'), findsOneWidget);
      expect(find.text('Your Standing'), findsOneWidget);
      expect(find.text('48 Sessions Attended'), findsOneWidget);
      expect(find.text('Subject Breakdown'), findsOneWidget);

      // Teacher components MUST NOT be present
      expect(find.text('FACULTY ATTENDANCE DESK'), findsNothing);
      expect(find.text("Today's Student Roster"), findsNothing);
    });

    testWidgets('Student Home screen renders Student greeting and Join Live Classroom',
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
            home: HomeDashboardScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Good morning, Sarah Rivera!'), findsOneWidget);
      expect(find.text('Join Live Classroom'), findsOneWidget);
      expect(find.text('Overall Progress'), findsOneWidget);
      expect(find.text("Today's Learning Schedule"), findsOneWidget);
    });
  });
}

