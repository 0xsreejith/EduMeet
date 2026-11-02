import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/edumeet_bottom_nav.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

class AppShellScreen extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const AppShellScreen({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTeacher = ref.watch(authNotifierProvider).user?.role.isTeacher ?? false;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: EduMeetBottomNav(
        currentIndex: navigationShell.currentIndex,
        isTeacher: isTeacher,
        onTap: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}
