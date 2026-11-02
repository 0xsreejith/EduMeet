import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/grade_entity.dart';
import '../../data/repositories/mock_grade_repository.dart';

final gradeRepositoryProvider = Provider<GradeRepository>((ref) {
  return MockGradeRepository();
});

final subjectGradesProvider =
    StreamProvider.family<List<SubjectGradeEntity>, String>((ref, studentId) {
  final repo = ref.watch(gradeRepositoryProvider);
  return repo.getSubjectGrades(studentId);
});

final recentAssignmentsProvider =
    StreamProvider.family<List<AssignmentEntity>, String>((ref, studentId) {
  final repo = ref.watch(gradeRepositoryProvider);
  return repo.getRecentAssignments(studentId);
});

final academicBadgesProvider =
    StreamProvider.family<List<AcademicBadgeEntity>, String>((ref, studentId) {
  final repo = ref.watch(gradeRepositoryProvider);
  return repo.getAcademicBadges(studentId);
});

final teacherSubmissionsProvider =
    StreamProvider.family<List<TeacherSubmissionEntity>, String>((ref, teacherId) {
  final repo = ref.watch(gradeRepositoryProvider);
  return repo.getTeacherSubmissions(teacherId);
});


