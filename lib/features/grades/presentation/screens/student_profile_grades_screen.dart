import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:edumeet/app/router/route_constants.dart';
import 'package:edumeet/app/theme/app_colors.dart';
import 'package:edumeet/app/theme/app_typography.dart';
import 'package:edumeet/core/widgets/edumeet_app_bar.dart';
import 'package:edumeet/core/widgets/edumeet_badge.dart';
import 'package:edumeet/core/widgets/edumeet_button.dart';
import 'package:edumeet/core/widgets/edumeet_card.dart';
import 'package:edumeet/core/widgets/responsive_layout.dart';
import 'package:edumeet/features/auth/domain/entities/user_entity.dart';
import 'package:edumeet/features/auth/presentation/providers/auth_provider.dart';
import 'package:edumeet/features/classroom/domain/entities/class_entity.dart';
import 'package:edumeet/features/classroom/presentation/providers/classroom_provider.dart';
import 'package:edumeet/features/grades/domain/entities/grade_entity.dart';
import '../providers/grade_provider.dart';

class StudentProfileGradesScreen extends ConsumerWidget {
  const StudentProfileGradesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).user;
    final isTeacher = user?.role.isTeacher ?? false;
    final classesAsync = ref.watch(classesStreamProvider);

    final gradesAsync = ref.watch(subjectGradesProvider(user?.id ?? 'student_sarah_01'));
    final assignmentsAsync = ref.watch(recentAssignmentsProvider(user?.id ?? 'student_sarah_01'));
    final badgesAsync = ref.watch(academicBadgesProvider(user?.id ?? 'student_sarah_01'));
    final teacherSubmissionsAsync =
        ref.watch(teacherSubmissionsProvider(user?.id ?? 'teacher_eleanor_01'));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: EduMeetAppBar(
        showLogo: true,
        avatarUrl: user?.avatarUrl,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.error),
            tooltip: 'Sign Out',
            onPressed: () async {
              await ref.read(authNotifierProvider.notifier).signOut();
              if (context.mounted) {
                context.go(RouteConstants.welcome);
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ResponsiveContainer(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Profile Header Card
                _buildProfileHeaderCard(context, user, isTeacher, classesAsync),
                const SizedBox(height: 16),

                if (isTeacher) ...[
                  // TEACHER FLOW:
                  // 2. Managed Classes & Live Launchers
                  _buildTeacherClassesCard(context, ref, user?.id, classesAsync),
                  const SizedBox(height: 16),

                  // 3. Pending Student Submissions & Grading
                  _buildTeacherGradingCard(context, ref, teacherSubmissionsAsync),
                  const SizedBox(height: 16),

                  // 4. Teaching Performance & Analytics
                  _buildTeacherAnalyticsCard(),
                  const SizedBox(height: 20),
                ] else ...[
                  // STUDENT FLOW:
                  // 2. Subject Grades Section
                  _buildSubjectGradesCard(gradesAsync),
                  const SizedBox(height: 16),

                  // 3. Recent Assignments Section
                  _buildRecentAssignmentsCard(assignmentsAsync),
                  const SizedBox(height: 16),

                  // 4. Academic Badges
                  _buildAcademicBadgesCard(badgesAsync),
                  const SizedBox(height: 20),
                ],

                // Sign Out Action
                EduMeetButton(
                  label: 'Sign Out',
                  variant: EduMeetButtonVariant.error,
                  icon: Icons.logout,
                  onPressed: () async {
                    await ref.read(authNotifierProvider.notifier).signOut();
                    if (context.mounted) {
                      context.go(RouteConstants.welcome);
                    }
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeaderCard(
    BuildContext context,
    UserEntity? user,
    bool isTeacher,
    AsyncValue<List<ClassEntity>> classesAsync,
  ) {
    final name = user?.displayName ?? (isTeacher ? 'Dr. Eleanor Vance' : 'Sarah Rivera');
    final idText = user?.studentId ?? (isTeacher ? 'FACULTY-01' : 'SID-88492');
    final subText = isTeacher
        ? (user?.title ?? 'Lead Principal Designer & Researcher')
        : (user?.gradeLevel ?? 'Grade 12 • STEM');

    // Calculate teacher active classes count dynamically
    final activeClassesCount = classesAsync.maybeWhen(
      data: (classes) => classes.where((c) => c.teacherId == user?.id).length,
      orElse: () => 2,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryFixed.withValues(alpha: 0.25),
            Colors.transparent,
            AppColors.tertiaryFixedDim.withValues(alpha: 0.2),
          ],
        ),
      ),
      child: Column(
        children: [
          // Avatar with verified badge
          Stack(
            children: [
              Container(
                width: 90,
                height: 90,
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  shape: BoxShape.circle,
                  boxShadow: [AppColors.softShadow],
                ),
                child: ClipOval(
                  child: Image.network(
                    user?.avatarUrl ??
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuCQjI1qXCNdDbmzsagtIRxOQYp16Sjp95PitdfQFaA7TZUOmy87OZIvDlcfBibox5B37p5hJnncpDZZdJ9hrpSqxBJXCEHo2lLZSL7VC9wXU3bVgHDi9y4jJO6EiRB9_YeLgeCaD15wpWkgH5KB0lKFIywQublF4BeJ-3eQTIILbN_W3UuSXCC5TSyRNvkAL3H-tpC75aUv4-EF1K-bKpjq_xjxXAeMdw2gVvVs2Ms',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: AppColors.tertiary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified_rounded,
                    size: 15,
                    color: AppColors.onTertiary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Text(
            name,
            style: AppTypography.headlineMd(color: AppColors.onSurface),
          ),
          const SizedBox(height: 8),

          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryFixed.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  idText,
                  style: AppTypography.labelSm(color: AppColors.onPrimaryFixedVariant)
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.sizeOf(context).width - 96,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  subText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelSm(color: AppColors.onSurfaceVariant)
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Quick Stats Grid
          Row(
            children: [
              Expanded(
                child: _QuickStatCard(
                  label: isTeacher ? 'Rating' : 'Overall GPA',
                  value: isTeacher ? '${user?.rating ?? 4.9} ★' : '${user?.gpa ?? 3.85}',
                  valueColor: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _QuickStatCard(
                  label: isTeacher ? 'Classes' : 'Enrolled',
                  value: isTeacher ? '$activeClassesCount Active' : '6 Courses',
                  valueColor: AppColors.onSurface,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _QuickStatCard(
                  label: isTeacher ? 'Students' : 'Badges',
                  value: isTeacher ? '44 Total' : '12 Earned',
                  valueColor: AppColors.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TEACHER FLOW COMPONENTS
  // ---------------------------------------------------------------------------

  Widget _buildTeacherClassesCard(
    BuildContext context,
    WidgetRef ref,
    String? teacherId,
    AsyncValue<List<ClassEntity>> classesAsync,
  ) {
    return EduMeetCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'My Taught Classes',
                  style: AppTypography.headlineSm(color: AppColors.onSurface),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => context.push(RouteConstants.createClass),
                child: Text(
                  '+ Create Class',
                  style: AppTypography.labelMd(color: AppColors.primary).copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          classesAsync.when(
            data: (allClasses) {
              final myClasses = allClasses.where((c) => c.teacherId == teacherId).toList();
              final displayClasses = myClasses.isNotEmpty ? myClasses : allClasses.take(2).toList();

              return Column(
                children: [
                  for (final cls in displayClasses)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.outlineVariant.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryFixed,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.school, color: AppColors.primary, size: 22),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      cls.title,
                                      style: AppTypography.headlineSm(color: AppColors.onSurface)
                                          .copyWith(fontSize: 16),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      cls.subject,
                                      style: AppTypography.labelSm(color: AppColors.onSurfaceVariant),
                                    ),
                                  ],
                                ),
                              ),
                              // Class Code Chip with one-tap copy
                              GestureDetector(
                                onTap: () {
                                  Clipboard.setData(ClipboardData(text: cls.roomCode));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Class Code ${cls.roomCode} copied to clipboard!'),
                                      duration: const Duration(seconds: 2),
                                      backgroundColor: AppColors.primary,
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondaryFixed,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        cls.roomCode,
                                        style: AppTypography.labelSm(color: AppColors.onSecondaryFixed)
                                            .copyWith(fontWeight: FontWeight.w800),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(
                                        Icons.copy_rounded,
                                        size: 14,
                                        color: AppColors.onSecondaryFixed,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(height: 1, color: AppColors.surfaceContainerHigh),
                          const SizedBox(height: 10),
                          Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.sizeOf(context).width - 96,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.group_outlined,
                                      size: 16,
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        '${cls.studentCount} Students • ${cls.roomNumber}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTypography.labelSm(color: AppColors.onSurfaceVariant),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              EduMeetButton(
                                label: 'Start Live',
                                variant: EduMeetButtonVariant.secondary,
                                icon: Icons.videocam,
                                height: 34,
                                onPressed: () {
                                  context.push(
                                    RouteConstants.liveClassroom.replaceFirst(
                                      ':roomId',
                                      cls.activeSessionId ?? 'room_${cls.id}',
                                    ),
                                    extra: {
                                      'classTitle': cls.title,
                                      'teacherName': cls.teacherName,
                                      'isHost': true,
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
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Text('Error loading classes: $err'),
          ),
        ],
      ),
    );
  }

  Widget _buildTeacherGradingCard(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<TeacherSubmissionEntity>> submissionsAsync,
  ) {
    return EduMeetCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Pending Student Submissions',
                  style: AppTypography.headlineSm(color: AppColors.onSurface),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              const EduMeetBadge(
                label: 'To Grade',
                variant: EduMeetBadgeVariant.primary,
              ),
            ],
          ),
          const SizedBox(height: 12),

          submissionsAsync.when(
            data: (submissions) => Column(
              children: submissions.map((sub) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.outlineVariant.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(sub.studentAvatar),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sub.studentName,
                              style: AppTypography.labelLg(color: AppColors.onSurface)
                                  .copyWith(fontWeight: FontWeight.w700),
                            ),
                            Text(
                              sub.assignmentTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.labelSm(color: AppColors.onSurfaceVariant),
                            ),
                            Text(
                              '${sub.className} • ${sub.submittedTime}',
                              style: AppTypography.labelSm(color: AppColors.outline),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (sub.isGraded)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.tertiaryFixed.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${sub.currentGrade} (${sub.currentScore}%)',
                            style: AppTypography.labelSm(color: AppColors.tertiary)
                                .copyWith(fontWeight: FontWeight.w700),
                          ),
                        )
                      else
                        ElevatedButton(
                          onPressed: () {
                            _showGradingDialog(context, ref, sub);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.onPrimary,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            minimumSize: const Size(0, 34),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Grade', style: TextStyle(fontSize: 12)),
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Text('Error: $err'),
          ),
        ],
      ),
    );
  }

  void _showGradingDialog(
    BuildContext context,
    WidgetRef ref,
    TeacherSubmissionEntity sub,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Grade Submission',
                  style: AppTypography.headlineSm(color: AppColors.onSurface),
                ),
                const SizedBox(height: 4),
                Text(
                  '${sub.studentName} — ${sub.assignmentTitle}',
                  style: AppTypography.bodySm(color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                Text(
                  'Select Grade:',
                  style: AppTypography.labelMd(color: AppColors.onSurface),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  children: [
                    _buildGradeOption(ctx, ref, sub, 'A+ (98%)', 'A+', 98),
                    _buildGradeOption(ctx, ref, sub, 'A (94%)', 'A', 94),
                    _buildGradeOption(ctx, ref, sub, 'B+ (88%)', 'B+', 88),
                    _buildGradeOption(ctx, ref, sub, 'B (82%)', 'B', 82),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGradeOption(
    BuildContext context,
    WidgetRef ref,
    TeacherSubmissionEntity sub,
    String label,
    String grade,
    int score,
  ) {
    return ActionChip(
      label: Text(label),
      backgroundColor: AppColors.surfaceContainerHigh,
      onPressed: () {
        ref.read(gradeRepositoryProvider).gradeSubmission(sub.id, grade, score);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Graded ${sub.studentName} with $grade ($score%)'),
            duration: const Duration(seconds: 2),
            backgroundColor: AppColors.tertiary,
          ),
        );
      },
    );
  }

  Widget _buildTeacherAnalyticsCard() {
    return EduMeetCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Teaching Performance & Insights',
                  style: AppTypography.headlineSm(color: AppColors.onSurface),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.analytics_outlined, color: AppColors.primary, size: 20),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  title: 'Attendance Rate',
                  value: '94%',
                  subtitle: '+2% vs last term',
                  color: AppColors.tertiary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricTile(
                  title: 'Assignments',
                  value: '98%',
                  subtitle: 'Turn-in rate',
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  title: 'Satisfaction',
                  value: '4.9 ★',
                  subtitle: 'Student rating',
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricTile(
                  title: 'Hours Taught',
                  value: '124 hrs',
                  subtitle: 'This semester',
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.labelSm(color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 10, color: AppColors.outline),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // STUDENT FLOW COMPONENTS
  // ---------------------------------------------------------------------------

  Widget _buildSubjectGradesCard(AsyncValue<List<SubjectGradeEntity>> gradesAsync) {
    return EduMeetCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Subject Grades',
                  style: AppTypography.headlineSm(color: AppColors.onSurface),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text('View Transcript', style: AppTypography.labelMd(color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 14),
          gradesAsync.when(
            data: (grades) => Column(
              children: grades.map((g) {
                Color iconBg;
                Color iconFg;
                IconData icon;

                switch (g.iconType) {
                  case 'math':
                    iconBg = AppColors.primaryFixed;
                    iconFg = AppColors.primary;
                    icon = Icons.functions_rounded;
                    break;
                  case 'physics':
                    iconBg = AppColors.tertiaryFixed.withValues(alpha: 0.35);
                    iconFg = AppColors.tertiary;
                    icon = Icons.bolt_rounded;
                    break;
                  case 'chemistry':
                  default:
                    iconBg = AppColors.secondaryFixed;
                    iconFg = AppColors.secondary;
                    icon = Icons.science_rounded;
                    break;
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.25)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: iconBg,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(icon, size: 20, color: iconFg),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    g.subjectName,
                                    style: AppTypography.labelLg(color: AppColors.onSurface)
                                        .copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  Text(
                                    g.teacherName,
                                    style: AppTypography.labelSm(color: AppColors.onSurfaceVariant),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  g.gradeLetter,
                                  style: AppTypography.headlineSm(color: iconFg),
                                ),
                                Text(
                                  '${g.percentage}%',
                                  style: AppTypography.labelSm(color: AppColors.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(9999),
                          child: LinearProgressIndicator(
                            value: g.percentage / 100,
                            minHeight: 6,
                            backgroundColor: AppColors.surfaceContainerHigh,
                            valueColor: AlwaysStoppedAnimation<Color>(iconFg),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Text('Error: $err'),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentAssignmentsCard(AsyncValue<List<AssignmentEntity>> assignmentsAsync) {
    return EduMeetCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent Assignments', style: AppTypography.headlineSm(color: AppColors.onSurface)),
          const SizedBox(height: 12),
          assignmentsAsync.when(
            data: (assignments) => Column(
              children: assignments.map((a) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: a.isCompleted
                              ? AppColors.tertiaryFixed.withValues(alpha: 0.35)
                              : AppColors.secondaryFixed,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          a.isCompleted ? Icons.check_rounded : Icons.pending_rounded,
                          size: 18,
                          color: a.isCompleted ? AppColors.tertiary : AppColors.secondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              a.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.bodySm(color: AppColors.onSurface).copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              a.subjectName,
                              style: AppTypography.labelSm(color: AppColors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        a.scoreText,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: a.isCompleted ? AppColors.tertiary : AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Text('Error: $err'),
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicBadgesCard(AsyncValue<List<AcademicBadgeEntity>> badgesAsync) {
    return EduMeetCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Earned Badges',
                  style: AppTypography.headlineSm(color: AppColors.onSurface),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '12 of 20 Unlocked',
                style: AppTypography.labelSm(color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 12),
          badgesAsync.when(
            data: (badges) => Row(
              children: badges.map((b) {
                Color bg;
                Color fg;
                IconData icon;

                switch (b.iconName) {
                  case 'military_tech':
                    bg = AppColors.primaryFixed;
                    fg = AppColors.primary;
                    icon = Icons.military_tech_rounded;
                    break;
                  case 'local_fire_department':
                    bg = AppColors.tertiaryFixed.withValues(alpha: 0.35);
                    fg = AppColors.tertiary;
                    icon = Icons.local_fire_department_rounded;
                    break;
                  case 'psychology':
                  default:
                    bg = AppColors.secondaryFixed;
                    fg = AppColors.secondary;
                    icon = Icons.psychology_rounded;
                    break;
                }

                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
                          child: Icon(icon, size: 24, color: fg),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          b.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.labelMd(color: AppColors.onSurface)
                              .copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          b.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: AppTypography.labelSm(color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Text('Error: $err'),
          ),
        ],
      ),
    );
  }
}

class _QuickStatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _QuickStatCard({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [AppColors.softShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
