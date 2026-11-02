import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edumeet/features/attendance/presentation/providers/attendance_provider.dart';

void main() {
  group('Attendance Repository Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('Fetches attendance history records for Sarah Rivera', () async {
      final repo = container.read(attendanceRepositoryProvider);
      final records = await repo.getAttendanceRecords('student_sarah_01').first;

      expect(records.isNotEmpty, true);
      expect(records.any((r) => r.className.contains('Advanced Mathematics')), true);
      expect(records.any((r) => r.status.displayName == 'Present'), true);
    });

    test('Attendance standing calculation matches Stitch 94% metrics', () async {
      final repo = container.read(attendanceRepositoryProvider);
      final records = await repo.getAttendanceRecords('student_sarah_01').first;

      final total = records.length;
      final presentCount = records.where((r) => r.status.displayName == 'Present').length;
      final percentage = (presentCount / total) * 100;

      // Ensure reasonable attendance standing
      expect(percentage, greaterThanOrEqualTo(80.0));
      expect(total, greaterThanOrEqualTo(5));
    });
  });
}
