import 'dart:async';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  final _controller = StreamController<UserEntity?>.broadcast();
  UserEntity? _currentUser;

  // Pre-configured Stitch design personas
  static final UserEntity demoStudent = UserEntity(
    id: 'student_sarah_01',
    email: 'sarah.rivera@edumeet.com',
    displayName: 'Sarah Rivera',
    role: UserRole.student,
    studentId: 'SID-88492',
    gradeLevel: 'Grade 12 • STEM',
    gpa: 3.85,
    avatarUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuCQjI1qXCNdDbmzsagtIRxOQYp16Sjp95PitdfQFaA7TZUOmy87OZIvDlcfBibox5B37p5hJnncpDZZdJ9hrpSqxBJXCEHo2lLZSL7VC9wXU3bVgHDi9y4jJO6EiRB9_YeLgeCaD15wpWkgH5KB0lKFIywQublF4BeJ-3eQTIILbN_W3UuSXCC5TSyRNvkAL3H-tpC75aUv4-EF1K-bKpjq_xjxXAeMdw2gVvVs2Ms',
    bio: 'Passionate STEM student specializing in Advanced Calculus & Quantum Physics.',
    createdAt: DateTime(2023, 9, 1),
  );

  static final UserEntity demoTeacher = UserEntity(
    id: 'teacher_eleanor_01',
    email: 'eleanor.vance@edumeet.com',
    displayName: 'Dr. Eleanor Vance',
    role: UserRole.teacher,
    title: 'Lead Principal Designer & Researcher',
    rating: 4.9,
    avatarUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuAafNEOnP614DaRx4Vp9vaYrnOIYML2WLlRRO-LoYhaS-ZkIj96IpuLx61Uo5BdHdEqPD8mEkHx84qZXhMl8L9_c61NT0vsfFdezIoCtiNyo7DpEMARZhpCD35RqJpaOOOvqLfGTF52s8zSwNW7o85iJKVRX5xpuM_wObA6TGCx-KbDwBh8mxPsyNJW-rF_Qoby5KZhPmhiI0m_rY1TofB-FNVkXSUVdgw_4NWAQfc',
    bio: '15+ years in Physics and Design Systems. Passionate about interactive remote learning.',
    createdAt: DateTime(2022, 1, 15),
  );

  MockAuthRepository({UserEntity? initialUser}) {
    _currentUser = initialUser ?? demoStudent;
    _controller.add(_currentUser);
  }

  @override
  Stream<UserEntity?> authStateChanges() async* {
    yield _currentUser;
    yield* _controller.stream;
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    return _currentUser;
  }

  @override
  Future<UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final trimmed = email.trim().toLowerCase();
    if (trimmed.contains('teacher') || trimmed.contains('eleanor')) {
      _currentUser = demoTeacher;
    } else {
      _currentUser = demoStudent;
    }
    _controller.add(_currentUser);
    return _currentUser!;
  }

  @override
  Future<UserEntity> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
    required UserRole role,
    String? studentId,
    String? title,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _currentUser = UserEntity(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      email: email.trim(),
      displayName: displayName.trim(),
      role: role,
      studentId: studentId ?? (role.isStudent ? 'SID-77291' : null),
      title: title ?? (role.isTeacher ? 'Professor' : null),
      avatarUrl: role.isTeacher ? demoTeacher.avatarUrl : demoStudent.avatarUrl,
      gpa: role.isStudent ? 3.85 : null,
      gradeLevel: role.isStudent ? 'Grade 12 • STEM' : null,
      rating: role.isTeacher ? 5.0 : null,
      createdAt: DateTime.now(),
    );
    _controller.add(_currentUser);
    return _currentUser!;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _currentUser = null;
    _controller.add(null);
  }

  @override
  Future<UserEntity> switchRole(UserRole newRole) async {
    if (_currentUser == null) throw const AuthFailure('Not logged in');
    _currentUser = newRole.isTeacher ? demoTeacher : demoStudent;
    _controller.add(_currentUser);
    return _currentUser!;
  }

  void dispose() {
    _controller.close();
  }
}

