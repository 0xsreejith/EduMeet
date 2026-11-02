class SubjectGradeEntity {
  final String id;
  final String subjectName;
  final String teacherName;
  final String gradeLetter; // 'A', 'A-', 'B+'
  final int percentage; // 96, 91, 87
  final String iconType; // 'math', 'physics', 'chemistry', 'cs'

  const SubjectGradeEntity({
    required this.id,
    required this.subjectName,
    required this.teacherName,
    required this.gradeLetter,
    required this.percentage,
    required this.iconType,
  });
}

class AssignmentEntity {
  final String id;
  final String title;
  final String subjectName;
  final String scoreText; // '48/50', '95/100', 'Grading'
  final bool isCompleted;

  const AssignmentEntity({
    required this.id,
    required this.title,
    required this.subjectName,
    required this.scoreText,
    required this.isCompleted,
  });
}

class AcademicBadgeEntity {
  final String id;
  final String title;
  final String subtitle;
  final String iconName; // 'trophy', 'flame', 'brain', 'clock'
  final bool isEarned;

  const AcademicBadgeEntity({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.iconName,
    this.isEarned = true,
  });
}

class TeacherSubmissionEntity {
  final String id;
  final String studentName;
  final String studentAvatar;
  final String assignmentTitle;
  final String className;
  final String submittedTime;
  final String? currentGrade;
  final int? currentScore;
  final bool isGraded;

  const TeacherSubmissionEntity({
    required this.id,
    required this.studentName,
    required this.studentAvatar,
    required this.assignmentTitle,
    required this.className,
    required this.submittedTime,
    this.currentGrade,
    this.currentScore,
    this.isGraded = false,
  });

  TeacherSubmissionEntity copyWith({
    String? currentGrade,
    int? currentScore,
    bool? isGraded,
  }) {
    return TeacherSubmissionEntity(
      id: id,
      studentName: studentName,
      studentAvatar: studentAvatar,
      assignmentTitle: assignmentTitle,
      className: className,
      submittedTime: submittedTime,
      currentGrade: currentGrade ?? this.currentGrade,
      currentScore: currentScore ?? this.currentScore,
      isGraded: isGraded ?? this.isGraded,
    );
  }
}


