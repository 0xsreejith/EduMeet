import 'dart:async';
import '../../domain/entities/attendance_entity.dart';

abstract class AttendanceRepository {
  Stream<List<AttendanceRecordEntity>> getAttendanceRecords(String studentId);
  Future<void> markAttendance(AttendanceRecordEntity record);
  Stream<List<AttendanceRecordEntity>> getClassRoster(String classId);
  Future<void> updateRosterStatus(String recordId, AttendanceStatus newStatus);
  Future<void> markAllRosterPresent(String classId);
}

class MockAttendanceRepository implements AttendanceRepository {
  final _controller = StreamController<List<AttendanceRecordEntity>>.broadcast();
  final _rosterController = StreamController<List<AttendanceRecordEntity>>.broadcast();

  final List<AttendanceRecordEntity> _classRoster = [
    AttendanceRecordEntity(
      id: 'roster_01',
      classId: 'class_math_01',
      className: 'Advanced Mathematics',
      studentId: 'student_sarah_01',
      studentName: 'Sarah Rivera',
      studentAvatar:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCQjI1qXCNdDbmzsagtIRxOQYp16Sjp95PitdfQFaA7TZUOmy87OZIvDlcfBibox5B37p5hJnncpDZZdJ9hrpSqxBJXCEHo2lLZSL7VC9wXU3bVgHDi9y4jJO6EiRB9_YeLgeCaD15wpWkgH5KB0lKFIywQublF4BeJ-3eQTIILbN_W3UuSXCC5TSyRNvkAL3H-tpC75aUv4-EF1K-bKpjq_xjxXAeMdw2gVvVs2Ms',
      status: AttendanceStatus.present,
      date: DateTime.now(),
    ),
    AttendanceRecordEntity(
      id: 'roster_02',
      classId: 'class_math_01',
      className: 'Advanced Mathematics',
      studentId: 'student_alex_02',
      studentName: 'Alex Chen',
      studentAvatar:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBYktLnkLWwy_rCQySLTZ3XzeGRSEomgyAC8rU2uV4Kd1OZfhu60QnUuW07l9V2RHuqLMVcS73VKCNUpwsweqZIPmEf2aYuWySytpbUoeJISEyQxBw033MrXjf1bb4JoXVvTULD-Pgodlr_clv8hMT-WbmZR2f1WBXKQlosTOcl_9psE_sZg-WIMi7UK4ErNLbhk7DWKm8rsn3neeYXuONNsnVI07P9_wbpqF4QzF8',
      status: AttendanceStatus.present,
      date: DateTime.now(),
    ),
    AttendanceRecordEntity(
      id: 'roster_03',
      classId: 'class_math_01',
      className: 'Advanced Mathematics',
      studentId: 'student_maya_03',
      studentName: 'Maya Patel',
      studentAvatar:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDXAWLE5Zq9IxEWr1UMXUTb3JRkoan1lNi24Yom4fjVwVn4iurU6X8wP0KMF73KZ2wSmg9G8oLy_qGJT-w1xyh5XAdbfoYJ4pg21Ktmw-prTLrPs-XQ1toCmmKBBbjUXK7AoDjAWtsOYmCXo__HH_9auY2vYuKaEA2wt05rMQMCF2O4AkTpgqRI_mqrUkYMa514Uqx6LZLfoIxYv7yL0IcSjvw-NglFrvOnPoeH0aA',
      status: AttendanceStatus.late,
      date: DateTime.now(),
    ),
    AttendanceRecordEntity(
      id: 'roster_04',
      classId: 'class_math_01',
      className: 'Advanced Mathematics',
      studentId: 'student_liam_04',
      studentName: 'Liam Johnson',
      studentAvatar:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAaipJbAwOCd2XcVWmt9rLadhtCQf8gN1l6fNEspfk7tt6An3SjIiFLSV21yvnQw3E4Uvqossna5CEWSA6v3UXr-7laJQSrEh4wOT3E0MDkIEnuiifkj8ekb5SSG4tdrN7T57twJ9seHUcqiNxr5nz3NlTatdi8tm5piI166RpB-FKTSkRXvgeaezdgW0AhUb0Jfy8bwR2NShV00NfbKrZnNChNfFqIuQLdR45DiPo',
      status: AttendanceStatus.absent,
      date: DateTime.now(),
    ),
    AttendanceRecordEntity(
      id: 'roster_05',
      classId: 'class_math_01',
      className: 'Advanced Mathematics',
      studentId: 'student_jordan_05',
      studentName: 'Jordan Taylor',
      studentAvatar:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCDlshp6GQgbIqIbflq4Ohd7lZ7eSvFEh9meyQ2V8cDawLW_631kQIiX-P-oatViHEWwLNNNlIC-pDZ0H_TKmC_axZdyBuGOU4xuDGfPbd-U7jamKo-p_-0LM7RwAVHvGiz8EH9Y9kRmWTBkcHkvklYiW1aRt_s1i17N2gMcG5AxxZr-GoWF8hnyoktx5fAzJt6q23MIj3D76Llq-46xUUnb9pbk5B3-UbS9OgXwwo',
      status: AttendanceStatus.present,
      date: DateTime.now(),
    ),
    AttendanceRecordEntity(
      id: 'roster_06',
      classId: 'class_math_01',
      className: 'Advanced Mathematics',
      studentId: 'student_emma_06',
      studentName: 'Emma Watson',
      studentAvatar:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBoFnisNytme7srnBRwZm5pld2Fed1_gCNmid2Uu5MIUawrq2nMD_RrzpbrBaf2fQCv6sQJPd9Q4VtfINuXtzTrOC2KoKlJSaxiOfHwjHLyB2eRC7HaCgl5YCoZ83nFQQSmWNzGop03W5JJZzdKAo1_ZNHWr4q-0nnMUIVHlx2dIavi26PPfvzPgQJTjOaWO7V5PfJrjXZDpT624x0xSIaaNM418_601XlSiB1L8_M',
      status: AttendanceStatus.present,
      date: DateTime.now(),
    ),
  ];


  final List<AttendanceRecordEntity> _records = [
    AttendanceRecordEntity(
      id: 'att_01',
      classId: 'class_math_01',
      className: 'Advanced Mathematics',
      studentId: 'student_sarah_01',
      studentName: 'Sarah Rivera',
      status: AttendanceStatus.present,
      date: DateTime(2023, 10, 20, 9, 0),
    ),
    AttendanceRecordEntity(
      id: 'att_02',
      classId: 'class_react_02',
      className: 'Physics & Mechanics',
      studentId: 'student_sarah_01',
      studentName: 'Sarah Rivera',
      status: AttendanceStatus.present,
      date: DateTime(2023, 10, 19, 11, 30),
    ),
    AttendanceRecordEntity(
      id: 'att_03',
      classId: 'class_chem_03',
      className: 'Organic Chemistry',
      studentId: 'student_sarah_01',
      studentName: 'Sarah Rivera',
      status: AttendanceStatus.late,
      date: DateTime(2023, 10, 18, 14, 0),
    ),
    AttendanceRecordEntity(
      id: 'att_04',
      classId: 'class_math_01',
      className: 'Advanced Mathematics',
      studentId: 'student_sarah_01',
      studentName: 'Sarah Rivera',
      status: AttendanceStatus.present,
      date: DateTime(2023, 10, 17, 10, 0),
    ),
    AttendanceRecordEntity(
      id: 'att_05',
      classId: 'class_react_02',
      className: 'Physics & Mechanics',
      studentId: 'student_sarah_01',
      studentName: 'Sarah Rivera',
      status: AttendanceStatus.present,
      date: DateTime(2023, 10, 16, 11, 30),
    ),
    AttendanceRecordEntity(
      id: 'att_06',
      classId: 'class_chem_03',
      className: 'Organic Chemistry',
      studentId: 'student_sarah_01',
      studentName: 'Sarah Rivera',
      status: AttendanceStatus.present,
      date: DateTime(2023, 10, 15, 14, 0),
    ),
    AttendanceRecordEntity(
      id: 'att_07',
      classId: 'class_math_01',
      className: 'Advanced Mathematics',
      studentId: 'student_sarah_01',
      studentName: 'Sarah Rivera',
      status: AttendanceStatus.present,
      date: DateTime(2023, 10, 14, 10, 0),
    ),
    AttendanceRecordEntity(
      id: 'att_08',
      classId: 'class_react_02',
      className: 'Physics & Mechanics',
      studentId: 'student_sarah_01',
      studentName: 'Sarah Rivera',
      status: AttendanceStatus.present,
      date: DateTime(2023, 10, 13, 11, 30),
    ),
    AttendanceRecordEntity(
      id: 'att_09',
      classId: 'class_chem_03',
      className: 'Organic Chemistry',
      studentId: 'student_sarah_01',
      studentName: 'Sarah Rivera',
      status: AttendanceStatus.absent,
      date: DateTime(2023, 10, 12, 14, 0),
    ),
    AttendanceRecordEntity(
      id: 'att_10',
      classId: 'class_math_01',
      className: 'Advanced Mathematics',
      studentId: 'student_sarah_01',
      studentName: 'Sarah Rivera',
      status: AttendanceStatus.present,
      date: DateTime(2023, 10, 11, 10, 0),
    ),
  ];

  MockAttendanceRepository() {
    _controller.add(_records);
  }

  @override
  Stream<List<AttendanceRecordEntity>> getAttendanceRecords(String studentId) async* {
    yield _records;
    yield* _controller.stream;
  }

  @override
  Future<void> markAttendance(AttendanceRecordEntity record) async {
    _records.insert(0, record);
    _controller.add(List.from(_records));
  }

  @override
  Stream<List<AttendanceRecordEntity>> getClassRoster(String classId) async* {
    yield _classRoster;
    yield* _rosterController.stream;
  }

  @override
  Future<void> updateRosterStatus(String recordId, AttendanceStatus newStatus) async {
    final index = _classRoster.indexWhere((r) => r.id == recordId);
    if (index != -1) {
      _classRoster[index] = _classRoster[index].copyWith(status: newStatus);
      _rosterController.add(List.from(_classRoster));
    }
  }

  @override
  Future<void> markAllRosterPresent(String classId) async {
    for (int i = 0; i < _classRoster.length; i++) {
      _classRoster[i] = _classRoster[i].copyWith(status: AttendanceStatus.present);
    }
    _rosterController.add(List.from(_classRoster));
  }
}

