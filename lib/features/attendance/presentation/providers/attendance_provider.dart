import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/attendance_entity.dart';
import '../../data/repositories/mock_attendance_repository.dart';

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return MockAttendanceRepository();
});

final attendanceRecordsProvider =
    StreamProvider.family<List<AttendanceRecordEntity>, String>((ref, studentId) {
  final repo = ref.watch(attendanceRepositoryProvider);
  return repo.getAttendanceRecords(studentId);
});

final classRosterStreamProvider =
    StreamProvider.family<List<AttendanceRecordEntity>, String>((ref, classId) {
  final repo = ref.watch(attendanceRepositoryProvider);
  return repo.getClassRoster(classId);
});


