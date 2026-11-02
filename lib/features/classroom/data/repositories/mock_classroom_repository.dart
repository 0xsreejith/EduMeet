import 'dart:async';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/class_entity.dart';
import '../../domain/repositories/classroom_repository.dart';

class MockClassroomRepository implements ClassroomRepository {
  final _classesController = StreamController<List<ClassEntity>>.broadcast();

  final List<ClassEntity> _classes = [
    ClassEntity(
      id: 'class_math_01',
      title: 'Advanced Mathematics',
      subject: 'Calculus & Series Convergence',
      teacherId: 'teacher_eleanor_01',
      teacherName: 'Dr. Eleanor Vance',
      teacherTitle: 'Lead Principal Designer & Researcher',
      teacherAvatar:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBCQi9jkOdzUWuHrvVnvSeL2wGk1pl0U4Qjs2NSvat40OL5fY6Ptk6LrIpUOTWk-m7WgSMGuf6C8-F-bHCqmpS8HOuytnmc_vz2Cbo-kAmlarWcxmO2rxxyy--8fAbO3PM9mMKe6XWP7YQl9RQ9j80rmIvHeChUpKirOwznvkSCqjrr9H3Usvas9rFnnIXv5oqJu-fvsAAM5egaop3b86-7zgZ9lZR88hHRhoVO8Mk',
      roomCode: 'MATH402',
      scheduleTime: '10:00 AM - 11:30 AM',
      roomNumber: 'Hall 4B',
      studentCount: 24,
      enrolledStudentIds: ['student_sarah_01', 'student_alex_02'],
      studentAvatars: [
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBYktLnkLWwy_rCQySLTZ3XzeGRSEomgyAC8rU2uV4Kd1OZfhu60QnUuW07l9V2RHuqLMVcS73VKCNUpwsweqZIPmEf2aYuWySytpbUoeJISEyQxBw033MrXjf1bb4JoXVvTULD-Pgodlr_clv8hMT-WbmZR2f1WBXKQlosTOcl_9psE_sZg-WIMi7UK4ErNLbhk7DWKm8rsn3neeYXuONNsnVI07P9_wbpqF4QzF8',
        'https://lh3.googleusercontent.com/aida-public/AB6AXuDXAWLE5Zq9IxEWr1UMXUTb3JRkoan1lNi24Yom4fjVwVn4iurU6X8wP0KMF73KZ2wSmg9G8oLy_qGJT-w1xyh5XAdbfoYJ4pg21Ktmw-prTLrPs-XQ1toCmmKBBbjUXK7AoDjAWtsOYmCXo__HH_9auY2vYuKaEA2wt05rMQMCF2O4AkTpgqRI_mqrUkYMa514Uqx6LZLfoIxYv7yL0IcSjvw-NglFrvOnPoeH0aA',
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBoFnisNytme7srnBRwZm5pld2Fed1_gCNmid2Uu5MIUawrq2nMD_RrzpbrBaf2fQCv6sQJPd9Q4VtfINuXtzTrOC2KoKlJSaxiOfHwjHLyB2eRC7HaCgl5YCoZ83nFQQSmWNzGop03W5JJZzdKAo1_ZNHWr4q-0nnMUIVHlx2dIavi26PPfvzPgQJTjOaWO7V5PfJrjXZDpT624x0xSIaaNM418_601XlSiB1L8_M',
      ],
      isLive: true,
      activeSessionId: 'room_math_live',
      description:
          'Deep dive into real-world UX failure cases and breakthrough redesign strategies. We will analyze complex data structures, user feedback loops, and multi-platform scaling considerations.',
      rating: 4.9,
      createdAt: DateTime(2023, 9, 10),
    ),
    ClassEntity(
      id: 'class_react_02',
      title: 'React & Modern Hooks Architecture',
      subject: 'Computer Science',
      teacherId: 'teacher_marcus_02',
      teacherName: 'Marcus Chen',
      teacherTitle: 'Senior Systems Architect',
      teacherAvatar:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDkuYA25yBS8dNZ1zYQsJ9SPzn8CqkRCT15RI-JnVCN041dm-4LmD-xHo8ghQeNl4cCcWKAXrg21VHwzYA3Cy41_fayrNAxNWyThZKC0zCLedDhUUVoPsme2GBsxhyLwqjpsG3Xpx2eayvXxVMn56rU9GLVnTMas3nfZTClElQV2WJrS5VUYuV3VmDiDM_nMRNJ4rvGfuzXB9koIIYlGJ8mUJdRO_tTuj1R1uEkIEI',
      roomCode: 'REACT20',
      scheduleTime: '02:00 PM - 03:30 PM',
      roomNumber: 'Lab B',
      studentCount: 18,
      enrolledStudentIds: ['student_sarah_01'],
      studentAvatars: [
        'https://lh3.googleusercontent.com/aida-public/AB6AXuAaipJbAwOCd2XcVWmt9rLadhtCQf8gN1l6fNEspfk7tt6An3SjIiFLSV21yvnQw3E4Uvqossna5CEWSA6v3UXr-7laJQSrEh4wOT3E0MDkIEnuiifkj8ekb5SSG4tdrN7T57twJ9seHUcqiNxr5nz3NlTatdi8tm5piI166RpB-FKTSkRXvgeaezdgW0AhUb0Jfy8bwR2NShV00NfbKrZnNChNfFqIuQLdR45DiPo',
        'https://lh3.googleusercontent.com/aida-public/AB6AXuCDlshp6GQgbIqIbflq4Ohd7lZ7eSvFEh9meyQ2V8cDawLW_631kQIiX-P-oatViHEWwLNNNlIC-pDZ0H_TKmC_axZdyBuGOU4xuDGfPbd-U7jamKo-p_-0LM7RwAVHvGiz8EH9Y9kRmWTBkcHkvklYiW1aRt_s1i17N2gMcG5AxxZr-GoWF8hnyoktx5fAzJt6q23MIj3D76Llq-46xUUnb9pbk5B3-UbS9OgXwwo',
      ],
      isLive: false,
      description: 'Master advanced React state hooks, concurrent features, and performance profiling.',
      rating: 4.8,
      createdAt: DateTime(2023, 9, 15),
    ),
    ClassEntity(
      id: 'class_chem_03',
      title: 'Organic Chemistry Lab',
      subject: 'Chemistry & Molecular Biology',
      teacherId: 'teacher_martinez_03',
      teacherName: 'Dr. Sarah Chen',
      teacherTitle: 'Professor of Biochemistry',
      teacherAvatar:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCLMiLHURG7rLEZkK9TRhrETFhVCnrIY0gmd6hHY4mCf-NON6UBHRgvo75fDoFEf6dFHFwn1eePPjZr47poN42POH5PMs8xtlpKHkDWr9QTbpaRv0TtK_3vHQShOdJ5FsYJqnsOyBuISKsQ1GR_RL7ajMTXf7WGmz4D_Z6915w7I6cLkTnpIUdbBK__290WgcwWZl6mCekr1i-HdwKJXjKT9_EDCK715FFLPj-yOmw',
      roomCode: 'CHEM101',
      scheduleTime: '01:30 PM - 03:00 PM',
      roomNumber: 'Science Wing',
      studentCount: 22,
      enrolledStudentIds: ['student_sarah_01'],
      studentAvatars: [],
      isLive: false,
      description: 'Hands-on molecular synthesis and thermodynamic analysis.',
      rating: 4.7,
      createdAt: DateTime(2023, 9, 20),
    ),
    ClassEntity(
      id: 'class_mentorship_04',
      title: 'Design System Mentorship 1-on-1',
      subject: 'UI/UX Design',
      teacherId: 'teacher_jenkins_04',
      teacherName: 'Prof. Sarah Jenkins',
      teacherTitle: 'Lead Design Educator',
      roomCode: 'MENTOR01',
      scheduleTime: '04:30 PM - 05:15 PM',
      roomNumber: 'Virtual Room',
      studentCount: 1,
      enrolledStudentIds: ['student_sarah_01'],
      studentAvatars: [],
      isLive: false,
      description: 'Personalized 1-on-1 review of design systems, token architecture, and portfolios.',
      rating: 5.0,
      createdAt: DateTime(2023, 10, 1),
    ),
    ClassEntity(
      id: 'class_linear_05',
      title: 'Linear Algebra & Vectors',
      subject: 'Mathematics & Computing',
      teacherId: 'teacher_eleanor_01',
      teacherName: 'Dr. Eleanor Vance',
      teacherTitle: 'Lead Principal Designer & Researcher',
      teacherAvatar:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBCQi9jkOdzUWuHrvVnvSeL2wGk1pl0U4Qjs2NSvat40OL5fY6Ptk6LrIpUOTWk-m7WgSMGuf6C8-F-bHCqmpS8HOuytnmc_vz2Cbo-kAmlarWcxmO2rxxyy--8fAbO3PM9mMKe6XWP7YQl9RQ9j80rmIvHeChUpKirOwznvkSCqjrr9H3Usvas9rFnnIXv5oqJu-fvsAAM5egaop3b86-7zgZ9lZR88hHRhoVO8Mk',
      roomCode: 'LIN301',
      scheduleTime: '04:00 PM - 05:30 PM',
      roomNumber: 'Hall 2A',
      studentCount: 20,
      enrolledStudentIds: ['student_sarah_01', 'student_alex_02'],
      studentAvatars: [
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBYktLnkLWwy_rCQySLTZ3XzeGRSEomgyAC8rU2uV4Kd1OZfhu60QnUuW07l9V2RHuqLMVcS73VKCNUpwsweqZIPmEf2aYuWySytpbUoeJISEyQxBw033MrXjf1bb4JoXVvTULD-Pgodlr_clv8hMT-WbmZR2f1WBXKQlosTOcl_9psE_sZg-WIMi7UK4ErNLbhk7DWKm8rsn3neeYXuONNsnVI07P9_wbpqF4QzF8',
        'https://lh3.googleusercontent.com/aida-public/AB6AXuDXAWLE5Zq9IxEWr1UMXUTb3JRkoan1lNi24Yom4fjVwVn4iurU6X8wP0KMF73KZ2wSmg9G8oLy_qGJT-w1xyh5XAdbfoYJ4pg21Ktmw-prTLrPs-XQ1toCmmKBBbjUXK7AoDjAWtsOYmCXo__HH_9auY2vYuKaEA2wt05rMQMCF2O4AkTpgqRI_mqrUkYMa514Uqx6LZLfoIxYv7yL0IcSjvw-NglFrvOnPoeH0aA',
      ],
      isLive: false,
      activeSessionId: 'room_linear_live',
      description: 'Matrix decomposition, eigenvalues, and computational geometry foundations.',
      rating: 4.9,
      createdAt: DateTime(2023, 9, 25),
    ),
  ];

  MockClassroomRepository() {
    _classesController.add(_classes);
  }

  @override
  Stream<List<ClassEntity>> getClasses() async* {
    yield _classes;
    yield* _classesController.stream;
  }

  @override
  Future<ClassEntity?> getClassById(String id) async {
    try {
      return _classes.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<ClassEntity> createClass(ClassEntity newClass) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _classes.insert(0, newClass);
    _classesController.add(List.from(_classes));
    return newClass;
  }

  @override
  Future<void> updateClass(ClassEntity updatedClass) async {
    final index = _classes.indexWhere((c) => c.id == updatedClass.id);
    if (index != -1) {
      _classes[index] = updatedClass;
      _classesController.add(List.from(_classes));
    }
  }

  @override
  Future<ClassEntity> joinClassByCode(String code, String studentId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final index = _classes.indexWhere(
      (c) => c.roomCode.toLowerCase() == code.trim().toLowerCase(),
    );
    if (index == -1) {
      throw const NotFoundFailure('No class found with that invite code.');
    }
    final existing = _classes[index];
    if (!existing.enrolledStudentIds.contains(studentId)) {
      final updatedList = List<String>.from(existing.enrolledStudentIds)..add(studentId);
      final updated = existing.copyWith(
        studentCount: existing.studentCount + 1,
        enrolledStudentIds: updatedList,
      );
      _classes[index] = updated;
      _classesController.add(List.from(_classes));
      return updated;
    }
    return existing;
  }

  @override
  Future<void> startLiveSession(String classId, String sessionId) async {
    final index = _classes.indexWhere((c) => c.id == classId);
    if (index != -1) {
      _classes[index] = _classes[index].copyWith(
        isLive: true,
        activeSessionId: sessionId,
      );
      _classesController.add(List.from(_classes));
    }
  }

  @override
  Future<void> endLiveSession(String classId) async {
    final index = _classes.indexWhere((c) => c.id == classId);
    if (index != -1) {
      _classes[index] = _classes[index].copyWith(
        isLive: false,
        activeSessionId: null,
      );
      _classesController.add(List.from(_classes));
    }
  }

  void dispose() {
    _classesController.close();
  }
}

