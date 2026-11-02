import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:edumeet/app/router/route_constants.dart';
import 'package:edumeet/app/theme/app_colors.dart';
import 'package:edumeet/app/theme/app_typography.dart';
import 'package:edumeet/core/widgets/edumeet_button.dart';
import 'package:edumeet/core/widgets/responsive_layout.dart';
import 'package:edumeet/features/auth/domain/entities/user_entity.dart';
import 'package:edumeet/features/auth/presentation/providers/auth_provider.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  UserRole _selectedRole = UserRole.student;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ResponsiveContainer(
          maxWidth: 520,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                // App Logo & Brand Header
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    size: 40,
                    color: AppColors.onPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'EduMeet',
                textAlign: TextAlign.center,
                style: AppTypography.headlineXl(color: AppColors.onSurface),
              ),
              const SizedBox(height: 8),
              Text(
                'Next-generation collaborative virtual classrooms for modern education.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMd(color: AppColors.onSurfaceVariant),
              ),
              const Spacer(flex: 2),

              // Interactive Role Picker
              Text(
                'I am joining as a:',
                style: AppTypography.labelLg(color: AppColors.onSurface).copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _RoleCard(
                      title: 'Student',
                      icon: Icons.person_rounded,
                      description: 'Join classes, attend live lectures, track progress',
                      isSelected: _selectedRole == UserRole.student,
                      onTap: () => setState(() => _selectedRole = UserRole.student),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _RoleCard(
                      title: 'Teacher',
                      icon: Icons.record_voice_over_rounded,
                      description: 'Host sessions, manage courses, track attendance',
                      isSelected: _selectedRole == UserRole.teacher,
                      onTap: () => setState(() => _selectedRole = UserRole.teacher),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Quick Fast-Track Demo Buttons for instant exploration
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                ),
                child: Column(
                  children: [
                    Text(
                      '⚡ Quick Instant Demo Access',
                      style: AppTypography.labelSm(color: AppColors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: EduMeetButton(
                            label: 'Enter as Student',
                            variant: EduMeetButtonVariant.primary,
                            height: 40,
                            onPressed: () async {
                              await ref.read(authNotifierProvider.notifier).switchRole(UserRole.student);
                              if (context.mounted) {
                                context.go(RouteConstants.home);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: EduMeetButton(
                            label: 'Enter as Teacher',
                            variant: EduMeetButtonVariant.secondary,
                            height: 40,
                            onPressed: () async {
                              await ref.read(authNotifierProvider.notifier).switchRole(UserRole.teacher);
                              if (context.mounted) {
                                context.go(RouteConstants.home);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Sign in / Sign up standard buttons
              EduMeetButton(
                label: 'Sign In with Email',
                variant: EduMeetButtonVariant.primary,
                onPressed: () => context.push(RouteConstants.login),
              ),
              const SizedBox(height: 10),
              EduMeetButton(
                label: 'Create an Account',
                variant: EduMeetButtonVariant.outlined,
                onPressed: () => context.push(
                  '${RouteConstants.register}?role=${_selectedRole.name}',
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    ),
  );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.icon,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryFixed.withValues(alpha: 0.35) : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outlineVariant.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? const [AppColors.cardShadow] : const [AppColors.softShadow],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  icon,
                  size: 26,
                  color: isSelected ? AppColors.primary : AppColors.outline,
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 20,
                    color: AppColors.primary,
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: AppTypography.headlineSm(color: AppColors.onSurface).copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.labelSm(color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
