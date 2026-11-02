enum AttendanceStatus {
  present,
  late,
  absent;

  String get displayName {
    switch (this) {
      case AttendanceStatus.present:
        return 'Present';
      case AttendanceStatus.late:
        return 'Late (5m)';
      case AttendanceStatus.absent:
        return 'Absent';
    }
  }

  static AttendanceStatus fromString(String? status) {
    switch (status?.toLowerCase()) {
      case 'late':
        return AttendanceStatus.late;
      case 'absent':
        return AttendanceStatus.absent;
      case 'present':
      default:
        return AttendanceStatus.present;
    }
  }
}

class AttendanceRecordEntity {
  final String id;
  final String classId;
  final String className;
  final String studentId;
  final String studentName;
  final String? studentAvatar;
  final AttendanceStatus status;
  final DateTime date;

  const AttendanceRecordEntity({
    required this.id,
    required this.classId,
    required this.className,
    required this.studentId,
    required this.studentName,
    this.studentAvatar,
    required this.status,
    required this.date,
  });

  AttendanceRecordEntity copyWith({
    String? id,
    String? classId,
    String? className,
    String? studentId,
    String? studentName,
    String? studentAvatar,
    AttendanceStatus? status,
    DateTime? date,
  }) {
    return AttendanceRecordEntity(
      id: id ?? this.id,
      classId: classId ?? this.classId,
      className: className ?? this.className,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      studentAvatar: studentAvatar ?? this.studentAvatar,
      status: status ?? this.status,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'classId': classId,
      'className': className,
      'studentId': studentId,
      'studentName': studentName,
      'studentAvatar': studentAvatar,
      'status': status.name,
      'date': date.toIso8601String(),
    };
  }

  factory AttendanceRecordEntity.fromMap(Map<String, dynamic> map, String id) {
    return AttendanceRecordEntity(
      id: id,
      classId: map['classId'] as String? ?? '',
      className: map['className'] as String? ?? '',
      studentId: map['studentId'] as String? ?? '',
      studentName: map['studentName'] as String? ?? '',
      studentAvatar: map['studentAvatar'] as String?,
      status: AttendanceStatus.fromString(map['status'] as String?),
      date: map['date'] != null
          ? DateTime.tryParse(map['date'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

