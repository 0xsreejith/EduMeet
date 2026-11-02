class ClassEntity {
  final String id;
  final String title;
  final String subject;
  final String teacherId;
  final String teacherName;
  final String? teacherAvatar;
  final String? teacherTitle;
  final String roomCode;
  final String scheduleTime; // e.g. "10:00 AM - 11:30 AM"
  final String roomNumber; // e.g. "Hall 4B"
  final int studentCount;
  final List<String> enrolledStudentIds;
  final List<String> studentAvatars;
  final bool isLive;
  final String? activeSessionId;
  final String? description;
  final double rating;
  final DateTime createdAt;

  const ClassEntity({
    required this.id,
    required this.title,
    required this.subject,
    required this.teacherId,
    required this.teacherName,
    this.teacherAvatar,
    this.teacherTitle,
    required this.roomCode,
    required this.scheduleTime,
    required this.roomNumber,
    required this.studentCount,
    this.enrolledStudentIds = const [],
    this.studentAvatars = const [],
    this.isLive = false,
    this.activeSessionId,
    this.description,
    this.rating = 4.9,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subject': subject,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'teacherAvatar': teacherAvatar,
      'teacherTitle': teacherTitle,
      'roomCode': roomCode,
      'scheduleTime': scheduleTime,
      'roomNumber': roomNumber,
      'studentCount': studentCount,
      'enrolledStudentIds': enrolledStudentIds,
      'studentAvatars': studentAvatars,
      'isLive': isLive,
      'activeSessionId': activeSessionId,
      'description': description,
      'rating': rating,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ClassEntity.fromMap(Map<String, dynamic> map, String id) {
    return ClassEntity(
      id: id,
      title: map['title'] as String? ?? 'Untitled Class',
      subject: map['subject'] as String? ?? 'General',
      teacherId: map['teacherId'] as String? ?? '',
      teacherName: map['teacherName'] as String? ?? 'Teacher',
      teacherAvatar: map['teacherAvatar'] as String?,
      teacherTitle: map['teacherTitle'] as String?,
      roomCode: map['roomCode'] as String? ?? 'EDUM01',
      scheduleTime: map['scheduleTime'] as String? ?? '10:00 AM',
      roomNumber: map['roomNumber'] as String? ?? 'Virtual Room',
      studentCount: (map['studentCount'] as num?)?.toInt() ?? 0,
      enrolledStudentIds: List<String>.from(map['enrolledStudentIds'] ?? []),
      studentAvatars: List<String>.from(map['studentAvatars'] ?? []),
      isLive: map['isLive'] as bool? ?? false,
      activeSessionId: map['activeSessionId'] as String?,
      description: map['description'] as String?,
      rating: (map['rating'] as num?)?.toDouble() ?? 4.9,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  ClassEntity copyWith({
    String? title,
    String? subject,
    String? scheduleTime,
    String? roomNumber,
    int? studentCount,
    List<String>? enrolledStudentIds,
    List<String>? studentAvatars,
    bool? isLive,
    String? activeSessionId,
    String? description,
    double? rating,
  }) {
    return ClassEntity(
      id: id,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      teacherId: teacherId,
      teacherName: teacherName,
      teacherAvatar: teacherAvatar,
      teacherTitle: teacherTitle,
      roomCode: roomCode,
      scheduleTime: scheduleTime ?? this.scheduleTime,
      roomNumber: roomNumber ?? this.roomNumber,
      studentCount: studentCount ?? this.studentCount,
      enrolledStudentIds: enrolledStudentIds ?? this.enrolledStudentIds,
      studentAvatars: studentAvatars ?? this.studentAvatars,
      isLive: isLive ?? this.isLive,
      activeSessionId: activeSessionId ?? this.activeSessionId,
      description: description ?? this.description,
      rating: rating ?? this.rating,
      createdAt: createdAt,
    );
  }
}

