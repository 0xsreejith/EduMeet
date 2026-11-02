import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edumeet/features/auth/domain/entities/user_entity.dart';
import 'package:edumeet/features/auth/presentation/providers/auth_provider.dart';

void main() {
  group('AuthNotifier Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('Initial auth state loads mock student Sarah Rivera', () async {
      final authState = container.read(authNotifierProvider);

      expect(authState.isLoading, false);
      expect(authState.user, isNotNull);
      expect(authState.user?.displayName, 'Sarah Rivera');
      expect(authState.user?.role, UserRole.student);
      expect(authState.isAuthenticated, true);
    });

    test('Login with teacher credentials authenticates Dr. Eleanor Vance', () async {
      final notifier = container.read(authNotifierProvider.notifier);

      final success = await notifier.signIn(
        'eleanor.vance@edumeet.edu',
        'password123',
      );

      expect(success, true);
      final state = container.read(authNotifierProvider);
      expect(state.user?.displayName, 'Dr. Eleanor Vance');
      expect(state.user?.role, UserRole.teacher);
      expect(state.user?.title, 'Lead Principal Designer & Researcher');
    });

    test('Role switch switches between student and teacher personas', () async {
      final notifier = container.read(authNotifierProvider.notifier);

      // Start as student
      expect(container.read(authNotifierProvider).user?.role, UserRole.student);

      // Switch to teacher
      await notifier.switchRole(UserRole.teacher);
      expect(container.read(authNotifierProvider).user?.role, UserRole.teacher);
      expect(container.read(authNotifierProvider).user?.displayName, 'Dr. Eleanor Vance');

      // Switch back to student
      await notifier.switchRole(UserRole.student);
      expect(container.read(authNotifierProvider).user?.role, UserRole.student);
      expect(container.read(authNotifierProvider).user?.displayName, 'Sarah Rivera');
    });

    test('Sign out clears user and marks state unauthenticated', () async {
      final notifier = container.read(authNotifierProvider.notifier);

      await notifier.signOut();
      final state = container.read(authNotifierProvider);
      expect(state.isAuthenticated, false);
      expect(state.user, isNull);
    });
  });
}
