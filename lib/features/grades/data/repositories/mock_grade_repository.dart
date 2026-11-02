import 'dart:async';
import '../../domain/entities/grade_entity.dart';

abstract class GradeRepository {
  Stream<List<SubjectGradeEntity>> getSubjectGrades(String studentId);
  Stream<List<AssignmentEntity>> getRecentAssignments(String studentId);
  Stream<List<AcademicBadgeEntity>> getAcademicBadges(String studentId);
  Stream<List<TeacherSubmissionEntity>> getTeacherSubmissions(String teacherId);
  Future<void> gradeSubmission(String submissionId, String grade, int score);
}

class MockGradeRepository implements GradeRepository {
  final _submissionsController = StreamController<List<TeacherSubmissionEntity>>.broadcast();

  final List<TeacherSubmissionEntity> _submissions = [
    const TeacherSubmissionEntity(
      id: 'sub_01',
      studentName: 'Sarah Rivera',
      studentAvatar:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCQjI1qXCNdDbmzsagtIRxOQYp16Sjp95PitdfQFaA7TZUOmy87OZIvDlcfBibox5B37p5hJnncpDZZdJ9hrpSqxBJXCEHo2lLZSL7VC9wXU3bVgHDi9y4jJO6EiRB9_YeLgeCaD15wpWkgH5KB0lKFIywQublF4BeJ-3eQTIILbN_W3UuSXCC5TSyRNvkAL3H-tpC75aUv4-EF1K-bKpjq_xjxXAeMdw2gVvVs2Ms',
      assignmentTitle: 'Calculus Derivatives Problem Set #4',
      className: 'Advanced Mathematics',
      submittedTime: '2 hours ago',
      currentGrade: 'A',
      currentScore: 98,
      isGraded: false,
    ),
    const TeacherSubmissionEntity(
      id: 'sub_02',
      studentName: 'Alex Chen',
      studentAvatar:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBYktLnkLWwy_rCQySLTZ3XzeGRSEomgyAC8rU2uV4Kd1OZfhu60QnUuW07l9V2RHuqLMVcS73VKCNUpwsweqZIPmEf2aYuWySytpbUoeJISEyQxBw033MrXjf1bb4JoXVvTULD-Pgodlr_clv8hMT-WbmZR2f1WBXKQlosTOcl_9psE_sZg-WIMi7UK4ErNLbhk7DWKm8rsn3neeYXuONNsnVI07P9_wbpqF4QzF8',
      assignmentTitle: 'Series Convergence Lab Proof',
      className: 'Advanced Mathematics',
      submittedTime: '4 hours ago',
      currentGrade: 'B+',
      currentScore: 88,
      isGraded: false,
    ),
    const TeacherSubmissionEntity(
      id: 'sub_03',
      studentName: 'Maya Patel',
      studentAvatar:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDXAWLE5Zq9IxEWr1UMXUTb3JRkoan1lNi24Yom4fjVwVn4iurU6X8wP0KMF73KZ2wSmg9G8oLy_qGJT-w1xyh5XAdbfoYJ4pg21Ktmw-prTLrPs-XQ1toCmmKBBbjUXK7AoDjAWtsOYmCXo__HH_9auY2vYuKaEA2wt05rMQMCF2O4AkTpgqRI_mqrUkYMa514Uqx6LZLfoIxYv7yL0IcSjvw-NglFrvOnPoeH0aA',
      assignmentTitle: 'Vector Spaces & Orthogonality Exam',
      className: 'Linear Algebra & Vectors',
      submittedTime: 'Yesterday',
      currentGrade: 'A',
      currentScore: 95,
      isGraded: true,
    ),
  ];

  final List<SubjectGradeEntity> _grades = const [
    SubjectGradeEntity(
      id: 'grade_01',
      subjectName: 'Advanced Mathematics',
      teacherName: 'Dr. Elizabeth Vance',
      gradeLetter: 'A',
      percentage: 96,
      iconType: 'math',
    ),
    SubjectGradeEntity(
      id: 'grade_02',
      subjectName: 'Physics',
      teacherName: 'Prof. Marcus Brody',
      gradeLetter: 'A-',
      percentage: 91,
      iconType: 'physics',
    ),
    SubjectGradeEntity(
      id: 'grade_03',
      subjectName: 'Chemistry',
      teacherName: 'Dr. Sarah Chen',
      gradeLetter: 'B+',
      percentage: 87,
      iconType: 'chemistry',
    ),
  ];

  final List<AssignmentEntity> _assignments = const [
    AssignmentEntity(
      id: 'asg_01',
      title: 'Calculus Derivatives Quiz',
      subjectName: 'Advanced Mathematics',
      scoreText: '48/50',
      isCompleted: true,
    ),
    AssignmentEntity(
      id: 'asg_02',
      title: 'Quantum Mechanics Essay',
      subjectName: 'Physics',
      scoreText: '95/100',
      isCompleted: true,
    ),
    AssignmentEntity(
      id: 'asg_03',
      title: 'Organic Synthesis Lab Report',
      subjectName: 'Chemistry',
      scoreText: 'Grading',
      isCompleted: false,
    ),
  ];

  final List<AcademicBadgeEntity> _badges = const [
    AcademicBadgeEntity(
      id: 'badge_01',
      title: 'Math Wiz',
      subtitle: 'Top 5%',
      iconName: 'military_tech',
      isEarned: true,
    ),
    AcademicBadgeEntity(
      id: 'badge_02',
      title: '30d Streak',
      subtitle: 'Active',
      iconName: 'local_fire_department',
      isEarned: true,
    ),
    AcademicBadgeEntity(
      id: 'badge_03',
      title: 'Fast Solver',
      subtitle: 'Speed',
      iconName: 'psychology',
      isEarned: true,
    ),
  ];

  @override
  Stream<List<SubjectGradeEntity>> getSubjectGrades(String studentId) async* {
    yield _grades;
  }

  @override
  Stream<List<AssignmentEntity>> getRecentAssignments(String studentId) async* {
    yield _assignments;
  }

  @override
  Stream<List<AcademicBadgeEntity>> getAcademicBadges(String studentId) async* {
    yield _badges;
  }

  @override
  Stream<List<TeacherSubmissionEntity>> getTeacherSubmissions(String teacherId) async* {
    yield _submissions;
    yield* _submissionsController.stream;
  }

  @override
  Future<void> gradeSubmission(String submissionId, String grade, int score) async {
    final index = _submissions.indexWhere((s) => s.id == submissionId);
    if (index != -1) {
      _submissions[index] = _submissions[index].copyWith(
        currentGrade: grade,
        currentScore: score,
        isGraded: true,
      );
      _submissionsController.add(List.from(_submissions));
    }
  }
}


