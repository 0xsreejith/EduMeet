import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edumeet/features/classroom/presentation/providers/classroom_provider.dart';

void main() {
  group('ClassroomNotifier & ClassesStream Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('classesStreamProvider returns seeded Stitch mock classes', () async {
      // Listen to the provider so it activates
      final sub = container.listen(classesStreamProvider, (prev, next) {});
      
      // Wait for stream to emit first value
      final classes = await container.read(classroomRepositoryProvider).getClasses().first;

      expect(classes.isNotEmpty, true);
      expect(classes.any((c) => c.title.contains('Advanced Mathematics')), true);
      expect(classes.any((c) => c.isLive), true);

      sub.close();
    });

    test('createClass successfully creates a new class and sets room code', () async {
      final notifier = container.read(classroomNotifierProvider.notifier);

      final created = await notifier.createClass(
        title: 'Cloud Architecture & DevOps',
        subject: 'Computer Science',
        scheduleTime: '02:00 PM - 03:30 PM',
        roomNumber: 'Lab 101',
        teacherId: 'teacher_001',
        teacherName: 'Dr. Eleanor Vance',
        description: 'Microservices and Kubernetes fundamentals',
      );

      expect(created, isNotNull);
      expect(created?.title, 'Cloud Architecture & DevOps');
      expect(created?.roomCode.startsWith('EDUM'), true);

      final state = container.read(classroomNotifierProvider);
      expect(state.isLoading, false);
      expect(state.successMessage, contains('created successfully'));
    });

    test('joinClass with valid class code succeeds', () async {
      final notifier = container.read(classroomNotifierProvider.notifier);

      // 'MATH402' is the room code of Advanced Mathematics in mock repository
      final success = await notifier.joinClass('MATH402', 'student_123');

      expect(success, true);
      final state = container.read(classroomNotifierProvider);
      expect(state.isLoading, false);
      expect(state.successMessage, contains('Successfully enrolled'));
    });

    test('joinClass with invalid code fails gracefully with error message', () async {
      final notifier = container.read(classroomNotifierProvider.notifier);

      final success = await notifier.joinClass('INVALID_CODE_999', 'student_123');

      expect(success, false);
      final state = container.read(classroomNotifierProvider);
      expect(state.isLoading, false);
      expect(state.errorMessage, isNotNull);
    });
  });
}
