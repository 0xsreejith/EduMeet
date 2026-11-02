import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:edumeet/app/router/route_constants.dart';
import 'package:edumeet/app/theme/app_colors.dart';
import 'package:edumeet/app/theme/app_typography.dart';
import 'package:edumeet/core/widgets/avatar_group.dart';
import 'package:edumeet/core/widgets/edumeet_app_bar.dart';
import 'package:edumeet/core/widgets/edumeet_badge.dart';
import 'package:edumeet/core/widgets/edumeet_button.dart';
import 'package:edumeet/core/widgets/edumeet_card.dart';
import 'package:edumeet/core/widgets/responsive_layout.dart';
import 'package:edumeet/features/auth/domain/entities/user_entity.dart';
import 'package:edumeet/features/auth/presentation/providers/auth_provider.dart';
import 'package:edumeet/features/classroom/domain/entities/class_entity.dart';
import 'package:edumeet/features/classroom/presentation/providers/classroom_provider.dart';
import 'package:edumeet/features/live_classroom/presentation/dialogs/dev_rtc_launcher_sheet.dart';

class HomeDashboardScreen extends ConsumerWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).user;
    final isTeacher = user?.role.isTeacher ?? false;
    final classesAsync = ref.watch(classesStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: EduMeetAppBar(
        showLogo: true,
        avatarUrl: user?.avatarUrl,
        onAvatarTap: () => context.go(RouteConstants.profile),
        actions: [
          // Role switch chip for rapid pair-testing
          GestureDetector(
            onTap: () async {
              final newRole = isTeacher ? UserRole.student : UserRole.teacher;
              await ref.read(authNotifierProvider.notifier).switchRole(newRole);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Switched view to ${newRole.displayName} mode'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isTeacher
                    ? AppColors.secondaryFixed
                    : AppColors.primaryFixed.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Row(
                children: [
                  Icon(
                    isTeacher ? Icons.school : Icons.person,
                    size: 14,
                    color: isTeacher ? AppColors.onSecondaryFixed : AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isTeacher ? 'Teacher' : 'Student',
                    style: AppTypography.labelSm(
                      color: isTeacher ? AppColors.onSecondaryFixed : AppColors.primary,
                    ).copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(classesStreamProvider);
          },
          child: ResponsiveContainer(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Personalized Greeting
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back,',
                              style: AppTypography.bodySm(color: AppColors.onSurfaceVariant),
                            ),
                            Text(
                              isTeacher
                                  ? 'Good morning, ${user?.displayName ?? 'Dr. Vance'}!'
                                  : 'Good morning, ${user?.displayName ?? 'Sarah'}!',
                              style: AppTypography.headlineLg(color: AppColors.onSurface),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primaryFixed,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [AppColors.softShadow],
                        ),
                        child: const Center(
                          child: Text('👋', style: TextStyle(fontSize: 22)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // [DEV RTC TESTING MODE] Quick Launcher Card
                  _buildDevRtcTestingCard(context),
                  const SizedBox(height: 14),

                  // Dynamic Role-Aware Hero Card
                  _buildLiveHeroCard(context, user, isTeacher, classesAsync),
                  const SizedBox(height: 16),

                  // Role-Specific Action / Progress Card
                  if (isTeacher) ...[
                    _buildTeacherQuickActions(context),
                    const SizedBox(height: 16),
                  ] else ...[
                    _buildLearningProgressCard(context),
                    const SizedBox(height: 16),
                  ],

                  // Recent Announcements Banner
                  _buildAnnouncementsBanner(context, isTeacher),
                  const SizedBox(height: 20),

                  // Today's Dynamic Schedule List
                  _buildScheduleSection(context, user, isTeacher, classesAsync),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // [DEV RTC TESTING MODE]
  // Temporary developer card for multi-device RTC testing without Firebase.
  Widget _buildDevRtcTestingCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primaryFixed.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primaryFixed,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.devices_rounded, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        '2-Device RTC Test',
                        style: AppTypography.labelMd(color: AppColors.onSurface)
                            .copyWith(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'DEV',
                        style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                Text(
                  'Select Role & join with custom Room ID',
                  style: AppTypography.bodySm(color: AppColors.onSurfaceVariant).copyWith(fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => DevRtcLauncherSheet.show(context),
            child: const Text('Test RTC', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveHeroCard(
    BuildContext context,
    UserEntity? user,
    bool isTeacher,
    AsyncValue<List<ClassEntity>> classesAsync,
  ) {
    // Find active or top class dynamically for user role
    final targetClass = classesAsync.maybeWhen(
      data: (classes) {
        if (isTeacher) {
          return classes.where((c) => c.teacherId == user?.id).firstOrNull ??
              classes.where((c) => c.isLive).firstOrNull ??
              classes.firstOrNull;
        } else {
          return classes.where((c) => c.enrolledStudentIds.contains(user?.id)).firstOrNull ??
              classes.where((c) => c.isLive).firstOrNull ??
              classes.firstOrNull;
        }
      },
      orElse: () => null,
    );

    final title = targetClass?.title ?? 'Advanced Mathematics';
    final subtitle = isTeacher
        ? 'Room: ${targetClass?.roomNumber ?? 'Hall 4B'} • Code: ${targetClass?.roomCode ?? 'MATH402'}'
        : '${targetClass?.teacherName ?? 'Dr. Eleanor Vance'} • ${targetClass?.subject ?? 'Calculus'}';
    final statusText = targetClass?.isLive == true ? 'Live Session Active' : 'Starting in 15 mins';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative background glow
          Positioned(
            right: -20,
            bottom: -20,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondaryContainer.withValues(alpha: 0.25),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.onPrimaryContainer.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.secondaryContainer,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                statusText,
                                style: AppTypography.labelMd(color: AppColors.onPrimaryContainer),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isTeacher ? 'Host Classroom' : 'Live Classroom',
                      style: AppTypography.labelMd(
                        color: AppColors.onPrimaryContainer.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  style: AppTypography.headlineMd(color: AppColors.onPrimaryContainer),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTypography.bodyMd(
                    color: AppColors.onPrimaryContainer.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  runSpacing: 10,
                  children: [
                    AvatarGroup(
                      imageUrls: targetClass?.studentAvatars.isNotEmpty == true
                          ? targetClass!.studentAvatars
                          : const [
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuBYktLnkLWwy_rCQySLTZ3XzeGRSEomgyAC8rU2uV4Kd1OZfhu60QnUuW07l9V2RHuqLMVcS73VKCNUpwsweqZIPmEf2aYuWySytpbUoeJISEyQxBw033MrXjf1bb4JoXVvTULD-Pgodlr_clv8hMT-WbmZR2f1WBXKQlosTOcl_9psE_sZg-WIMi7UK4ErNLbhk7DWKm8rsn3neeYXuONNsnVI07P9_wbpqF4QzF8',
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuDXAWLE5Zq9IxEWr1UMXUTb3JRkoan1lNi24Yom4fjVwVn4iurU6X8wP0KMF73KZ2wSmg9G8oLy_qGJT-w1xyh5XAdbfoYJ4pg21Ktmw-prTLrPs-XQ1toCmmKBBbjUXK7AoDjAWtsOYmCXo__HH_9auY2vYuKaEA2wt05rMQMCF2O4AkTpgqRI_mqrUkYMa514Uqx6LZLfoIxYv7yL0IcSjvw-NglFrvOnPoeH0aA',
                            ],
                      totalCount: targetClass?.studentCount ?? 24,
                      size: 34,
                      borderColor: AppColors.primaryContainer,
                    ),
                    EduMeetButton(
                      label: isTeacher ? 'Start Teaching Live' : 'Join Live Classroom',
                      variant: EduMeetButtonVariant.secondary,
                      icon: Icons.videocam,
                      height: 42,
                      onPressed: () {
                        context.push(
                          RouteConstants.liveClassroom.replaceFirst(
                            ':roomId',
                            targetClass?.activeSessionId ?? 'room_math_live',
                          ),
                          extra: {
                            'classTitle': title,
                            'teacherName': targetClass?.teacherName ?? 'Dr. Eleanor Vance',
                            'isHost': isTeacher,
                          },
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLearningProgressCard(BuildContext context) {
    return EduMeetCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.tertiaryFixed.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.insights_rounded,
                        size: 18,
                        color: AppColors.tertiary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Overall Progress',
                        style: AppTypography.headlineSm(color: AppColors.onSurface),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => context.go(RouteConstants.progress),
                child: Text(
                  'View details',
                  style: AppTypography.labelMd(color: AppColors.primary).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Custom Ring Visual
              SizedBox(
                width: 76,
                height: 76,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: 0.78,
                      strokeWidth: 8,
                      backgroundColor: AppColors.surfaceContainer,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                      strokeCap: StrokeCap.round,
                    ),
                    Center(
                      child: Text(
                        '78%',
                        style: AppTypography.headlineSm(color: AppColors.onSurface),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            'Semester Goal',
                            style: AppTypography.bodySm(color: AppColors.onSurfaceVariant),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '14 / 18 Courses',
                          style: AppTypography.bodySm(color: AppColors.onSurface).copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "You're on a 5-day learning streak! Keep up the great work.",
                      style: AppTypography.labelSm(color: AppColors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 8),
                    const Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        EduMeetBadge(
                          label: 'Top 10% in Class',
                          variant: EduMeetBadgeVariant.primary,
                        ),
                        EduMeetBadge(
                          label: '4 Badges earned',
                          variant: EduMeetBadgeVariant.live,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTeacherQuickActions(BuildContext context) {
    return EduMeetCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.dashboard_customize_rounded, size: 20, color: AppColors.secondary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Teacher Quick Controls',
                  style: AppTypography.headlineSm(color: AppColors.onSurface),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: EduMeetButton(
                  label: '+ Create Class',
                  variant: EduMeetButtonVariant.primary,
                  onPressed: () => context.push(RouteConstants.createClass),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: EduMeetButton(
                  label: 'Mark Attendance',
                  variant: EduMeetButtonVariant.secondary,
                  icon: Icons.fact_check_rounded,
                  onPressed: () => context.go(RouteConstants.progress),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementsBanner(BuildContext context, bool isTeacher) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.secondaryFixed.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.secondary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.campaign_rounded,
              size: 22,
              color: AppColors.onSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        isTeacher
                            ? 'Class Announcement Broadcast'
                            : 'Midterm Project Submissions',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.labelLg(color: AppColors.onSurface).copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      '2h ago',
                      style: AppTypography.labelSm(color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  isTeacher
                      ? 'Reminder: Submit finalized midterm grades before Friday.'
                      : 'Deadline extended to Friday, Nov 17th at 11:59 PM.',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySm(color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleSection(
    BuildContext context,
    UserEntity? user,
    bool isTeacher,
    AsyncValue<List<ClassEntity>> classesAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                isTeacher ? "Today's Teaching Schedule" : "Today's Learning Schedule",
                style: AppTypography.headlineSm(color: AppColors.onSurface),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => context.go(RouteConstants.classes),
              child: Text(
                'View All',
                style: AppTypography.labelMd(color: AppColors.primary).copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        classesAsync.when(
          data: (allClasses) {
            final list = isTeacher
                ? allClasses.where((c) => c.teacherId == user?.id).toList()
                : allClasses.where((c) => c.enrolledStudentIds.contains(user?.id)).toList();
            final displayList = list.isNotEmpty ? list : allClasses.take(3).toList();

            return Column(
              children: displayList.map((cls) {
                final timeParts = cls.scheduleTime.split(' ');
                final timeTop = timeParts.isNotEmpty ? timeParts[0] : '10:00';
                final timeBottom = timeParts.length > 1 ? timeParts[1] : 'AM';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _ScheduleTile(
                    timeTop: timeTop,
                    timeBottom: timeBottom,
                    title: cls.title,
                    subtitle: isTeacher
                        ? '${cls.roomNumber} • ${cls.studentCount} Students • Code: ${cls.roomCode}'
                        : '${cls.teacherName} • ${cls.roomNumber}',
                    tagLabel: cls.isLive ? 'Live Now' : 'Upcoming',
                    tagVariant: cls.isLive ? EduMeetBadgeVariant.live : EduMeetBadgeVariant.upcoming,
                    onTap: () {
                      context.push(
                        RouteConstants.liveClassroom.replaceFirst(
                          ':roomId',
                          cls.activeSessionId ?? 'room_${cls.id}',
                        ),
                        extra: {
                          'classTitle': cls.title,
                          'teacherName': cls.teacherName,
                          'isHost': isTeacher,
                        },
                      );
                    },
                  ),
                );
              }).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Text('Error loading schedule: $err'),
        ),
      ],
    );
  }
}

class _ScheduleTile extends StatelessWidget {
  final String timeTop;
  final String timeBottom;
  final String title;
  final String subtitle;
  final String tagLabel;
  final EduMeetBadgeVariant tagVariant;
  final VoidCallback? onTap;

  const _ScheduleTile({
    required this.timeTop,
    required this.timeBottom,
    required this.title,
    required this.subtitle,
    required this.tagLabel,
    required this.tagVariant,
    this.onTap,
  });

  bool get isPrimaryTime => tagVariant == EduMeetBadgeVariant.live;

  @override
  Widget build(BuildContext context) {
    return EduMeetCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: isPrimaryTime ? AppColors.primaryFixed : AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  timeTop,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    height: 1.1,
                    color: isPrimaryTime ? AppColors.primary : AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  timeBottom,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                    color: isPrimaryTime ? AppColors.primary : AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyLg(color: AppColors.onSurface).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.bodySm(color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          EduMeetBadge(label: tagLabel, variant: tagVariant),
        ],
      ),
    );
  }
}
