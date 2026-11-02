import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edumeet/features/classroom/domain/entities/class_entity.dart';
import 'package:edumeet/features/classroom/domain/repositories/classroom_repository.dart';
import 'package:edumeet/features/classroom/data/repositories/mock_classroom_repository.dart';

final classroomRepositoryProvider = Provider<ClassroomRepository>((ref) {
  return MockClassroomRepository();
});

final classesStreamProvider = StreamProvider<List<ClassEntity>>((ref) {
  final repository = ref.watch(classroomRepositoryProvider);
  return repository.getClasses();
});

class ClassroomState {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const ClassroomState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  ClassroomState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  }) {
    return ClassroomState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

class ClassroomNotifier extends Notifier<ClassroomState> {
  @override
  ClassroomState build() => const ClassroomState();

  Future<ClassEntity?> createClass({
    required String title,
    required String subject,
    required String scheduleTime,
    required String roomNumber,
    required String teacherId,
    required String teacherName,
    String? teacherTitle,
    String? teacherAvatar,
    String? description,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null, successMessage: null);
    try {
      final repo = ref.read(classroomRepositoryProvider);
      final code = 'EDUM${100 + DateTime.now().millisecond}';
      final newClass = ClassEntity(
        id: 'class_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        subject: subject,
        teacherId: teacherId,
        teacherName: teacherName,
        teacherTitle: teacherTitle,
        teacherAvatar: teacherAvatar,
        roomCode: code,
        scheduleTime: scheduleTime,
        roomNumber: roomNumber,
        studentCount: 1,
        isLive: false,
        description: description,
        createdAt: DateTime.now(),
      );
      final created = await repo.createClass(newClass);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Class "${created.title}" created successfully! Code: $code',
      );
      return created;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return null;
    }
  }

  Future<bool> joinClass(String code, String studentId) async {
    state = state.copyWith(isLoading: true, errorMessage: null, successMessage: null);
    try {
      final repo = ref.read(classroomRepositoryProvider);
      final joined = await repo.joinClassByCode(code, studentId);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Successfully enrolled in ${joined.title}!',
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<void> toggleLiveClass(String classId, bool startLive, String sessionId) async {
    final repo = ref.read(classroomRepositoryProvider);
    if (startLive) {
      await repo.startLiveSession(classId, sessionId);
    } else {
      await repo.endLiveSession(classId);
    }
  }

  void clearStatus() {
    state = const ClassroomState();
  }
}

final classroomNotifierProvider =
    NotifierProvider<ClassroomNotifier, ClassroomState>(ClassroomNotifier.new);
