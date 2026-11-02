import '../entities/class_entity.dart';

abstract class ClassroomRepository {
  Stream<List<ClassEntity>> getClasses();
  Future<ClassEntity?> getClassById(String id);
  Future<ClassEntity> createClass(ClassEntity newClass);
  Future<void> updateClass(ClassEntity updatedClass);
  Future<ClassEntity> joinClassByCode(String code, String studentId);
  Future<void> startLiveSession(String classId, String sessionId);
  Future<void> endLiveSession(String classId);
}

