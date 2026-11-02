import '../entities/user_entity.dart';

abstract class AuthRepository {
  Stream<UserEntity?> authStateChanges();
  Future<UserEntity?> getCurrentUser();
  Future<UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  });
  Future<UserEntity> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
    required UserRole role,
    String? studentId,
    String? title,
  });
  Future<void> sendPasswordResetEmail(String email);
  Future<void> signOut();
  Future<UserEntity> switchRole(UserRole newRole);
}

