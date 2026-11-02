enum UserRole {
  teacher,
  student;

  String get displayName => this == UserRole.teacher ? 'Teacher' : 'Student';
  bool get isTeacher => this == UserRole.teacher;
  bool get isStudent => this == UserRole.student;

  static UserRole fromString(String? role) {
    if (role == null) return UserRole.student;
    return role.toLowerCase() == 'teacher' ? UserRole.teacher : UserRole.student;
  }
}

class UserEntity {
  final String id;
  final String email;
  final String displayName;
  final UserRole role;
  final String? avatarUrl;
  final String? studentId;
  final String? title; // e.g. "Dr. Eleanor Vance", "Lead Principal Designer"
  final String? bio;
  final double? gpa;
  final String? gradeLevel; // e.g. "Grade 12 • STEM"
  final double? rating; // For teachers, e.g. 4.9
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
    this.avatarUrl,
    this.studentId,
    this.title,
    this.bio,
    this.gpa,
    this.gradeLevel,
    this.rating,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'role': role.name,
      'avatarUrl': avatarUrl,
      'studentId': studentId,
      'title': title,
      'bio': bio,
      'gpa': gpa,
      'gradeLevel': gradeLevel,
      'rating': rating,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserEntity.fromMap(Map<String, dynamic> map, String id) {
    return UserEntity(
      id: id,
      email: map['email'] as String? ?? '',
      displayName: map['displayName'] as String? ?? 'User',
      role: UserRole.fromString(map['role'] as String?),
      avatarUrl: map['avatarUrl'] as String?,
      studentId: map['studentId'] as String?,
      title: map['title'] as String?,
      bio: map['bio'] as String?,
      gpa: (map['gpa'] as num?)?.toDouble(),
      gradeLevel: map['gradeLevel'] as String?,
      rating: (map['rating'] as num?)?.toDouble(),
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  UserEntity copyWith({
    String? displayName,
    UserRole? role,
    String? avatarUrl,
    String? studentId,
    String? title,
    String? bio,
    double? gpa,
    String? gradeLevel,
    double? rating,
  }) {
    return UserEntity(
      id: id,
      email: email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      studentId: studentId ?? this.studentId,
      title: title ?? this.title,
      bio: bio ?? this.bio,
      gpa: gpa ?? this.gpa,
      gradeLevel: gradeLevel ?? this.gradeLevel,
      rating: rating ?? this.rating,
      createdAt: createdAt,
    );
  }
}

