import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'app_shell.dart';
import 'route_constants.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/home/presentation/screens/home_dashboard_screen.dart';
import '../../features/schedule/presentation/screens/classes_schedule_screen.dart';
import '../../features/chat/presentation/screens/chat_messages_screen.dart';
import '../../features/attendance/presentation/screens/attendance_progress_screen.dart';
import '../../features/grades/presentation/screens/student_profile_grades_screen.dart';
import '../../features/live_classroom/presentation/screens/live_classroom_screen.dart';
import '../../features/classroom/presentation/screens/create_class_screen.dart';
import '../../features/classroom/presentation/screens/join_class_screen.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorHomeKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final _shellNavigatorClassesKey = GlobalKey<NavigatorState>(debugLabel: 'classes');
final _shellNavigatorChatKey = GlobalKey<NavigatorState>(debugLabel: 'chat');
final _shellNavigatorProgressKey = GlobalKey<NavigatorState>(debugLabel: 'progress');
final _shellNavigatorProfileKey = GlobalKey<NavigatorState>(debugLabel: 'profile');

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen<AuthState>(
      authNotifierProvider,
      (previous, next) => notifyListeners(),
    );
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: RouteConstants.home,
    refreshListenable: notifier,
    redirect: (context, state) {
      final authState = ref.read(authNotifierProvider);
      final isLoggedIn = authState.user != null;
      final isAuthRoute = state.matchedLocation == RouteConstants.welcome ||
          state.matchedLocation == RouteConstants.login ||
          state.matchedLocation == RouteConstants.register;

      if (!isLoggedIn && !isAuthRoute) {
        return RouteConstants.welcome;
      }
      if (isLoggedIn && isAuthRoute) {
        return RouteConstants.home;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: RouteConstants.welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: RouteConstants.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteConstants.register,
        builder: (context, state) {
          final role = state.uri.queryParameters['role'];
          return RegisterScreen(initialRole: role);
        },
      ),
      GoRoute(
        path: RouteConstants.liveClassroom,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final roomId = state.pathParameters['roomId'] ?? 'default_room';
          final extra = state.extra as Map<String, dynamic>?;
          return LiveClassroomScreen(
            roomId: roomId,
            classTitle: extra?['classTitle'] as String?,
            teacherName: extra?['teacherName'] as String?,
            customUserId: extra?['customUserId'] as String?,
            customUserName: extra?['customUserName'] as String?,
          );
        },
      ),
      GoRoute(
        path: RouteConstants.createClass,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const CreateClassScreen(),
      ),
      GoRoute(
        path: RouteConstants.joinClass,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const JoinClassScreen(),
      ),

      // Stateful Bottom Navigation Shell
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShellScreen(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Home
          StatefulShellBranch(
            navigatorKey: _shellNavigatorHomeKey,
            routes: [
              GoRoute(
                path: RouteConstants.home,
                builder: (context, state) => const HomeDashboardScreen(),
              ),
            ],
          ),
          // Branch 1: Classes & Schedule
          StatefulShellBranch(
            navigatorKey: _shellNavigatorClassesKey,
            routes: [
              GoRoute(
                path: RouteConstants.classes,
                builder: (context, state) => const ClassesScheduleScreen(),
              ),
            ],
          ),
          // Branch 2: Chat & Messages
          StatefulShellBranch(
            navigatorKey: _shellNavigatorChatKey,
            routes: [
              GoRoute(
                path: RouteConstants.chat,
                builder: (context, state) => const ChatMessagesScreen(),
              ),
            ],
          ),
          // Branch 3: Progress & Attendance
          StatefulShellBranch(
            navigatorKey: _shellNavigatorProgressKey,
            routes: [
              GoRoute(
                path: RouteConstants.progress,
                builder: (context, state) => const AttendanceProgressScreen(),
              ),
            ],
          ),
          // Branch 4: Profile & Grades
          StatefulShellBranch(
            navigatorKey: _shellNavigatorProfileKey,
            routes: [
              GoRoute(
                path: RouteConstants.profile,
                builder: (context, state) => const StudentProfileGradesScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
