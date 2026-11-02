import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:edumeet/core/widgets/edumeet_bottom_nav.dart';

void main() {
  group('EduMeetBottomNav layout & positioning tests', () {
    testWidgets('EduMeetBottomNav stays pinned to the bottom of the screen inside a Scaffold',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1179, 2556);
      tester.view.devicePixelRatio = 3.0; // 393 x 852 logical (iPhone 17)
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      int tappedIndex = -1;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const Center(
              child: Text('Home Dashboard Body'),
            ),
            bottomNavigationBar: EduMeetBottomNav(
              currentIndex: 0,
              isTeacher: false,
              onTap: (index) => tappedIndex = index,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the bottom nav widget
      final bottomNavFinder = find.byType(EduMeetBottomNav);
      expect(bottomNavFinder, findsOneWidget);

      final navRect = tester.getRect(bottomNavFinder);
      const logicalHeight = 852.0;

      // Bottom bar must be anchored at the very bottom edge of the screen
      expect(navRect.bottom, closeTo(logicalHeight, 0.5));

      // Bottom bar height must be compact (between 50 and 120 px, including safe padding), NEVER the full screen!
      expect(navRect.height, lessThan(120));
      expect(navRect.height, greaterThan(40));

      // The body text must be visible and placed above the bottom navigation bar
      final bodyTextFinder = find.text('Home Dashboard Body');
      expect(bodyTextFinder, findsOneWidget);

      final bodyRect = tester.getRect(bodyTextFinder);
      expect(bodyRect.top, lessThan(navRect.top));

      // Test tapping an item
      await tester.tap(find.text('Classes'));
      expect(tappedIndex, 1);
    });

    testWidgets('EduMeetBottomNav renders role-appropriate tab labels for teacher and student',
        (WidgetTester tester) async {
      // Student mode
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: EduMeetBottomNav(
              currentIndex: 0,
              isTeacher: false,
              onTap: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Classes'), findsOneWidget);
      expect(find.text('Chat'), findsOneWidget);
      expect(find.text('Progress'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);

      // Teacher mode
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: EduMeetBottomNav(
              currentIndex: 0,
              isTeacher: true,
              onTap: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Classes'), findsOneWidget);
      expect(find.text('Chat'), findsOneWidget);
      expect(find.text('Attendance'), findsOneWidget);
      expect(find.text('Faculty'), findsOneWidget);
    });
  });
}

