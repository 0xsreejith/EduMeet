import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zego_uikit/zego_uikit.dart';

void main() {
  testWidgets('ZegoScreenUtilInit in MaterialApp builder allows ZegoAudioVideoView to render without error', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) {
          return ZegoScreenUtilInit(
            designSize: const Size(360, 690),
            builder: (context, _) => child ?? const SizedBox.shrink(),
          );
        },
        home: Scaffold(
          body: ZegoAudioVideoView(
            user: ZegoUIKitUser(id: 'u1', name: 'User 1'),
          ),
        ),
      ),
    );

    // Pump frames to complete screen size future
    await tester.pumpAndSettle();

    expect(find.byType(ZegoAudioVideoView), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
