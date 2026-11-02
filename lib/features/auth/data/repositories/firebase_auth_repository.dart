import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  FirebaseAuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<UserEntity?> authStateChanges() {
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      return await _fetchUserProfile(firebaseUser.uid);
    });
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return await _fetchUserProfile(user.uid);
  }

  Future<UserEntity?> _fetchUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists || doc.data() == null) return null;
      return UserEntity.fromMap(doc.data()!, uid);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final uid = credential.user!.uid;
      final profile = await _fetchUserProfile(uid);
      if (profile == null) {
        throw const AuthFailure('User profile not found in database.');
      }
      return profile;
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(e.message ?? 'Authentication failed.');
    } catch (e) {
      throw AuthFailure(e.toString());
    }
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
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final uid = credential.user!.uid;
      await credential.user!.updateDisplayName(displayName);

      final newUser = UserEntity(
        id: uid,
        email: email.trim(),
        displayName: displayName,
        role: role,
        studentId: studentId ?? (role.isStudent ? 'SID-${10000 + DateTime.now().millisecond}' : null),
        title: title ?? (role.isTeacher ? 'Instructor' : null),
        avatarUrl: role.isTeacher
            ? 'https://lh3.googleusercontent.com/aida-public/AB6AXuBCQi9jkOdzUWuHrvVnvSeL2wGk1pl0U4Qjs2NSvat40OL5fY6Ptk6LrIpUOTWk-m7WgSMGuf6C8-F-bHCqmpS8HOuytnmc_vz2Cbo-kAmlarWcxmO2rxxyy--8fAbO3PM9mMKe6XWP7YQl9RQ9j80rmIvHeChUpKirOwznvkSCqjrr9H3Usvas9rFnnIXv5oqJu-fvsAAM5egaop3b86-7zgZ9lZR88hHRhoVO8Mk'
            : 'https://lh3.googleusercontent.com/aida-public/AB6AXuCQjI1qXCNdDbmzsagtIRxOQYp16Sjp95PitdfQFaA7TZUOmy87OZIvDlcfBibox5B37p5hJnncpDZZdJ9hrpSqxBJXCEHo2lLZSL7VC9wXU3bVgHDi9y4jJO6EiRB9_YeLgeCaD15wpWkgH5KB0lKFIywQublF4BeJ-3eQTIILbN_W3UuSXCC5TSyRNvkAL3H-tpC75aUv4-EF1K-bKpjq_xjxXAeMdw2gVvVs2Ms',
        gpa: role.isStudent ? 3.85 : null,
        gradeLevel: role.isStudent ? 'Grade 12 • STEM' : null,
        rating: role.isTeacher ? 4.9 : null,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(uid).set(newUser.toMap());
      return newUser;
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(e.message ?? 'Registration failed.');
    } catch (e) {
      throw AuthFailure(e.toString());
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(e.message ?? 'Failed to send reset email.');
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  Future<UserEntity> switchRole(UserRole newRole) async {
    final user = await getCurrentUser();
    if (user == null) throw const AuthFailure('No user currently logged in.');
    final updated = user.copyWith(role: newRole);
    await _firestore.collection('users').doc(user.id).update({'role': newRole.name});
    return updated;
  }
}

