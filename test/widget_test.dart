import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edumeet/app/app.dart';
import 'package:edumeet/core/widgets/edumeet_bottom_nav.dart';
import 'helpers/test_http_overrides.dart';

void main() {
  setUpAll(() {
    HttpOverrides.global = TestHttpOverrides();
  });

  testWidgets('EduMeet App smoke and initialization test', (WidgetTester tester) async {
    // Provide a standard phone screen size
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(
        child: EduMeetApp(),
      ),
    );

    // Initial pump
    await tester.pumpAndSettle();

    // Verify EduMeet branding or bottom navigation is rendered
    expect(find.text('EduMeet'), findsWidgets);

    // Verify EduMeetBottomNav is located at the bottom of the screen
    final navFinder = find.byType(EduMeetBottomNav);
    expect(navFinder, findsOneWidget);

    final navRect = tester.getRect(navFinder);
    final screenHeight = 2400 / 2.75;
    expect(navRect.bottom, closeTo(screenHeight, 0.5));
    expect(navRect.height, lessThan(120));

    // Verify home screen dashboard elements are rendered above the bottom bar
    expect(find.text('Welcome back,'), findsOneWidget);
    final welcomeRect = tester.getRect(find.text('Welcome back,'));
    expect(welcomeRect.top, lessThan(navRect.top));

    // Tap 'Classes' tab and verify navigation
    await tester.tap(find.text('Classes'));
    await tester.pumpAndSettle();
    expect(find.text('Enrolled Classes'), findsOneWidget);

    // Tap 'Chat' tab and verify navigation
    await tester.tap(find.text('Chat'));
    await tester.pumpAndSettle();
    expect(find.text('Messages (3)'), findsOneWidget);

    // Tap 'Progress' tab and verify navigation
    await tester.tap(find.text('Progress'));
    await tester.pumpAndSettle();
    expect(find.text('ATTENDANCE OVERVIEW'), findsOneWidget);

    // Tap 'Profile' tab and verify navigation
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Sarah Rivera'), findsOneWidget);
  });
}
