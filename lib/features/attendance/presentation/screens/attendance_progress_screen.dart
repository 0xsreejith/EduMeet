import 'package:flutter/material.dart';
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
import 'package:edumeet/features/auth/presentation/providers/auth_provider.dart';
import 'package:edumeet/features/attendance/domain/entities/attendance_entity.dart';
import 'package:edumeet/features/classroom/presentation/providers/classroom_provider.dart';
import '../providers/attendance_provider.dart';

class AttendanceProgressScreen extends ConsumerStatefulWidget {
  const AttendanceProgressScreen({super.key});

  @override
  ConsumerState<AttendanceProgressScreen> createState() => _AttendanceProgressScreenState();
}

class _AttendanceProgressScreenState extends ConsumerState<AttendanceProgressScreen> {
  String _selectedClassId = 'class_math_01';

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authNotifierProvider).user;
    final isTeacher = user?.role.isTeacher ?? false;
    final classesAsync = ref.watch(classesStreamProvider);
    final recordsAsync = ref.watch(attendanceRecordsProvider(user?.id ?? 'student_sarah_01'));
    final rosterAsync = ref.watch(classRosterStreamProvider(_selectedClassId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: EduMeetAppBar(
        showLogo: true,
        avatarUrl: user?.avatarUrl,
        onAvatarTap: () => context.go(RouteConstants.profile),
      ),
      body: SafeArea(
        child: ResponsiveContainer(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (isTeacher) ...[
                  // TEACHER FLOW:
                  // 1. Teacher Class Attendance Overview
                  _buildTeacherSummaryCard(rosterAsync),
                  const SizedBox(height: 16),

                  // 2. Class Selector Chips
                  _buildTeacherClassSelector(classesAsync),
                  const SizedBox(height: 16),

                  // 3. Interactive Student Attendance Register
                  _buildTeacherStudentRosterCard(rosterAsync),
                  const SizedBox(height: 16),

                  // 4. Past Class Sessions History
                  _buildTeacherSessionHistoryCard(),
                  const SizedBox(height: 24),
                ] else ...[
                  // STUDENT FLOW:
                  // 1. Top Standing Summary Card
                  _buildStandingSummaryCard(),
                  const SizedBox(height: 16),

                  // 2. Monthly Calendar Overview
                  _buildMonthlyCalendarCard(),
                  const SizedBox(height: 16),

                  // 3. Subject-wise Breakdown
                  _buildSubjectBreakdownCard(),
                  const SizedBox(height: 16),

                  // 4. Milestone Badges
                  _buildMilestoneBadgesCard(),
                  const SizedBox(height: 16),

                  // 5. Attendance History Log
                  _buildHistoryLogCard(recordsAsync),
                  const SizedBox(height: 24),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TEACHER FLOW WIDGETS
  // ---------------------------------------------------------------------------

  Widget _buildTeacherSummaryCard(AsyncValue<List<AttendanceRecordEntity>> rosterAsync) {
    final total = rosterAsync.maybeWhen(
      data: (roster) => roster.length,
      orElse: () => 6,
    );
    final present = rosterAsync.maybeWhen(
      data: (roster) => roster.where((r) => r.status == AttendanceStatus.present).length,
      orElse: () => 5,
    );
    final lateCount = rosterAsync.maybeWhen(
      data: (roster) => roster.where((r) => r.status == AttendanceStatus.late).length,
      orElse: () => 1,
    );
    final absent = rosterAsync.maybeWhen(
      data: (roster) => roster.where((r) => r.status == AttendanceStatus.absent).length,
      orElse: () => 0,
    );
    final rate = total > 0 ? ((present + (lateCount * 0.5)) / total * 100).round() : 94;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryFixed.withValues(alpha: 0.3),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'FACULTY ATTENDANCE DESK',
                            style: AppTypography.labelSm(color: AppColors.onSurfaceVariant).copyWith(
                              letterSpacing: 0.8,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Class Register & Analytics',
                            style: AppTypography.headlineSm(color: AppColors.onSurface),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [AppColors.softShadow],
                      ),
                      child: const Icon(
                        Icons.fact_check_rounded,
                        size: 24,
                        color: AppColors.onPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    SizedBox(
                      width: 84,
                      height: 84,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CircularProgressIndicator(
                            value: rate / 100,
                            strokeWidth: 9,
                            backgroundColor: AppColors.surfaceContainerHigh,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                            strokeCap: StrokeCap.round,
                          ),
                          Center(
                            child: Text(
                              '$rate%',
                              style: AppTypography.headlineSm(color: AppColors.onSurface),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _StatRow(
                            color: AppColors.tertiary,
                            label: '$present Students Present',
                          ),
                          const SizedBox(height: 6),
                          _StatRow(
                            color: AppColors.secondary,
                            label: '$lateCount Student Late',
                          ),
                          const SizedBox(height: 6),
                          _StatRow(
                            color: AppColors.error,
                            label: '$absent Student Absent',
                          ),
                        ],
                      ),
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

  Widget _buildTeacherClassSelector(AsyncValue classesAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Class to Take Attendance',
          style: AppTypography.headlineSm(color: AppColors.onSurface),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildClassChip(
                id: 'class_math_01',
                title: 'Advanced Mathematics (MATH402)',
              ),
              const SizedBox(width: 8),
              _buildClassChip(
                id: 'class_linear_05',
                title: 'Linear Algebra & Vectors (LIN301)',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClassChip({required String id, required String title}) {
    final isSelected = _selectedClassId == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedClassId = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: AppTypography.labelMd(
              color: isSelected ? AppColors.onPrimary : AppColors.onSurface,
            ).copyWith(fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500),
          ),
        ),
      ),
    );
  }

  Widget _buildTeacherStudentRosterCard(
    AsyncValue<List<AttendanceRecordEntity>> rosterAsync,
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
                  "Today's Student Roster",
                  style: AppTypography.headlineSm(color: AppColors.onSurface),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                icon: const Icon(Icons.done_all_rounded, size: 16),
                label: const Text('All Present', style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.tertiary,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: const Size(0, 32),
                ),
                onPressed: () {
                  ref.read(attendanceRepositoryProvider).markAllRosterPresent(_selectedClassId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Marked all students as Present!'),
                      duration: Duration(seconds: 2),
                      backgroundColor: AppColors.tertiary,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),

          rosterAsync.when(
            data: (roster) => Column(
              children: [
                for (final record in roster)
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(10),
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
                          backgroundImage: record.studentAvatar != null
                              ? NetworkImage(record.studentAvatar!)
                              : null,
                          child: record.studentAvatar == null
                              ? const Icon(Icons.person, size: 20)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                record.studentName,
                                style: AppTypography.labelLg(color: AppColors.onSurface).copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                record.studentId,
                                style: AppTypography.labelSm(color: AppColors.outline),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Toggle status chips: P, L, A
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildStatusToggleButton(
                              record: record,
                              status: AttendanceStatus.present,
                              label: 'P',
                              activeBg: AppColors.tertiaryFixed,
                              activeFg: AppColors.tertiary,
                            ),
                            const SizedBox(width: 4),
                            _buildStatusToggleButton(
                              record: record,
                              status: AttendanceStatus.late,
                              label: 'L',
                              activeBg: AppColors.secondaryFixed,
                              activeFg: AppColors.onSecondaryFixed,
                            ),
                            const SizedBox(width: 4),
                            _buildStatusToggleButton(
                              record: record,
                              status: AttendanceStatus.absent,
                              label: 'A',
                              activeBg: AppColors.errorContainer,
                              activeFg: AppColors.error,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
                EduMeetButton(
                  label: 'Save & Submit Register',
                  variant: EduMeetButtonVariant.primary,
                  icon: Icons.check_circle_outline,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Attendance register successfully saved!'),
                        duration: Duration(seconds: 2),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  },
                ),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Text('Error: $err'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusToggleButton({
    required AttendanceRecordEntity record,
    required AttendanceStatus status,
    required String label,
    required Color activeBg,
    required Color activeFg,
  }) {
    final isSelected = record.status == status;
    return GestureDetector(
      onTap: () {
        ref.read(attendanceRepositoryProvider).updateRosterStatus(record.id, status);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isSelected ? activeBg : AppColors.surfaceContainerHigh.withValues(alpha: 0.5),
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: activeFg, width: 1.5) : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isSelected ? activeFg : AppColors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTeacherSessionHistoryCard() {
    return EduMeetCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Previous Session Reports',
            style: AppTypography.headlineSm(color: AppColors.onSurface),
          ),
          const SizedBox(height: 12),
          _buildSessionHistoryRow(
            date: 'Oct 20, 2023',
            topic: 'Integration by Parts & Taylor Series',
            rate: '96%',
            present: '23 / 24 Present',
            color: AppColors.tertiary,
          ),
          const Divider(height: 16, color: AppColors.surfaceContainerHigh),
          _buildSessionHistoryRow(
            date: 'Oct 17, 2023',
            topic: 'Convergence Theorems & Ratio Tests',
            rate: '92%',
            present: '22 / 24 Present',
            color: AppColors.tertiary,
          ),
          const Divider(height: 16, color: AppColors.surfaceContainerHigh),
          _buildSessionHistoryRow(
            date: 'Oct 14, 2023',
            topic: 'Limits of Multivariable Functions',
            rate: '88%',
            present: '21 / 24 Present',
            color: AppColors.secondary,
          ),
        ],
      ),
    );
  }

  Widget _buildSessionHistoryRow({
    required String date,
    required String topic,
    required String rate,
    required String present,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              rate,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                topic,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.labelLg(color: AppColors.onSurface).copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$date • $present',
                style: AppTypography.labelSm(color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // STUDENT FLOW WIDGETS
  // ---------------------------------------------------------------------------

  Widget _buildStandingSummaryCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryFixed.withValues(alpha: 0.3),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ATTENDANCE OVERVIEW',
                            style: AppTypography.labelSm(color: AppColors.onSurfaceVariant).copyWith(
                              letterSpacing: 0.8,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Your Standing',
                            style: AppTypography.headlineSm(color: AppColors.onSurface),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [AppColors.softShadow],
                      ),
                      child: const Icon(
                        Icons.verified_rounded,
                        size: 24,
                        color: AppColors.onPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    SizedBox(
                      width: 84,
                      height: 84,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CircularProgressIndicator(
                            value: 0.94,
                            strokeWidth: 9,
                            backgroundColor: AppColors.surfaceContainerHigh,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                            strokeCap: StrokeCap.round,
                          ),
                          Center(
                            child: Text(
                              '94%',
                              style: AppTypography.headlineSm(color: AppColors.onSurface),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _StatRow(
                            color: AppColors.tertiary,
                            label: '48 Sessions Attended',
                          ),
                          const SizedBox(height: 6),
                          _StatRow(
                            color: AppColors.secondaryContainer,
                            label: '3 Sessions Missed',
                          ),
                          const SizedBox(height: 6),
                          _StatRow(
                            color: AppColors.outlineVariant,
                            label: '2 Excused Absences',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                const Divider(color: AppColors.surfaceContainerHigh),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Status: ',
                            style: AppTypography.bodySm(color: AppColors.onSurfaceVariant),
                          ),
                          Flexible(
                            child: Text(
                              'Excellent Standing',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.bodySm(color: AppColors.tertiary).copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Goal: 90% min.',
                      style: AppTypography.labelSm(color: AppColors.outline),
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

  Widget _buildMonthlyCalendarCard() {
    return EduMeetCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'October 2023',
                  style: AppTypography.headlineSm(color: AppColors.onSurface),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Days of week header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              Text('M', style: TextStyle(fontSize: 12, color: AppColors.outline)),
              Text('T', style: TextStyle(fontSize: 12, color: AppColors.outline)),
              Text('W', style: TextStyle(fontSize: 12, color: AppColors.outline)),
              Text('T', style: TextStyle(fontSize: 12, color: AppColors.outline)),
              Text('F', style: TextStyle(fontSize: 12, color: AppColors.outline)),
              Text('S', style: TextStyle(fontSize: 12, color: AppColors.outline)),
              Text('S', style: TextStyle(fontSize: 12, color: AppColors.outline)),
            ],
          ),
          const SizedBox(height: 10),

          _CalendarMatrixRow(
            days: [
              _MatrixDay(day: 25, isFaded: true),
              _MatrixDay(day: 26, isFaded: true),
              _MatrixDay(day: 27, isFaded: true),
              _MatrixDay(day: 28, isFaded: true),
              _MatrixDay(day: 29, isFaded: true),
              _MatrixDay(day: 30, isFaded: true),
              _MatrixDay(day: 1, dotColor: AppColors.tertiary),
            ],
          ),
          const SizedBox(height: 8),
          _CalendarMatrixRow(
            days: [
              _MatrixDay(day: 2, dotColor: AppColors.tertiary),
              _MatrixDay(day: 3, dotColor: AppColors.tertiary),
              _MatrixDay(day: 4, dotColor: AppColors.tertiary),
              _MatrixDay(day: 5, dotColor: AppColors.tertiary),
              _MatrixDay(day: 6, dotColor: AppColors.secondary),
              _MatrixDay(day: 7),
              _MatrixDay(day: 8),
            ],
          ),
          const SizedBox(height: 8),
          _CalendarMatrixRow(
            days: [
              _MatrixDay(day: 9, dotColor: AppColors.tertiary),
              _MatrixDay(day: 10, dotColor: AppColors.tertiary),
              _MatrixDay(day: 11, dotColor: AppColors.tertiary),
              _MatrixDay(day: 12, dotColor: AppColors.error),
              _MatrixDay(day: 13, dotColor: AppColors.tertiary),
              _MatrixDay(day: 14),
              _MatrixDay(day: 15),
            ],
          ),
          const SizedBox(height: 8),
          _CalendarMatrixRow(
            days: [
              _MatrixDay(day: 16, dotColor: AppColors.tertiary),
              _MatrixDay(day: 17, dotColor: AppColors.tertiary),
              _MatrixDay(day: 18, dotColor: AppColors.tertiary, isToday: true),
              _MatrixDay(day: 19, dotColor: AppColors.tertiary),
              _MatrixDay(day: 20, dotColor: AppColors.tertiary),
              _MatrixDay(day: 21),
              _MatrixDay(day: 22),
            ],
          ),
          const SizedBox(height: 16),

          // Legend
          const Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              _LegendItem(color: AppColors.tertiary, label: 'Present'),
              _LegendItem(color: AppColors.secondary, label: 'Late'),
              _LegendItem(color: AppColors.error, label: 'Absent'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectBreakdownCard() {
    return EduMeetCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Subject Breakdown', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 14),
          _SubjectProgressRow(
            title: 'Advanced Mathematics',
            percentage: 98,
            color: AppColors.primary,
          ),
          SizedBox(height: 12),
          _SubjectProgressRow(
            title: 'Physics & Mechanics',
            percentage: 92,
            color: AppColors.tertiary,
          ),
          SizedBox(height: 12),
          _SubjectProgressRow(
            title: 'Organic Chemistry',
            percentage: 88,
            color: AppColors.secondary,
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneBadgesCard() {
    return EduMeetCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Attendance Streaks',
                  style: AppTypography.headlineSm(color: AppColors.onSurface),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text('3 Badges', style: AppTypography.labelSm(color: AppColors.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: const [
              EduMeetBadge(
                label: '🔥 20-Day Streak',
                variant: EduMeetBadgeVariant.live,
              ),
              EduMeetBadge(
                label: '⚡ Early Bird',
                variant: EduMeetBadgeVariant.primary,
              ),
              EduMeetBadge(
                label: '🌟 100% Oct',
                variant: EduMeetBadgeVariant.upcoming,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryLogCard(AsyncValue<List<AttendanceRecordEntity>> recordsAsync) {
    return EduMeetCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Recent Sessions Log',
                  style: AppTypography.headlineSm(color: AppColors.onSurface),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text('Last 10 Days', style: AppTypography.labelSm(color: AppColors.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 12),
          recordsAsync.when(
            data: (records) => Column(
              children: records.take(6).map((r) {
                Color iconBg;
                Color iconFg;
                IconData icon;
                Color badgeBg;
                Color badgeFg;

                switch (r.status) {
                  case AttendanceStatus.present:
                    iconBg = AppColors.tertiaryFixed.withValues(alpha: 0.3);
                    iconFg = AppColors.tertiary;
                    icon = Icons.check_circle_rounded;
                    badgeBg = AppColors.tertiaryFixed.withValues(alpha: 0.25);
                    badgeFg = AppColors.tertiary;
                    break;
                  case AttendanceStatus.late:
                    iconBg = AppColors.primaryFixed.withValues(alpha: 0.3);
                    iconFg = AppColors.primary;
                    icon = Icons.schedule_rounded;
                    badgeBg = AppColors.secondaryFixed;
                    badgeFg = AppColors.onSecondaryFixed;
                    break;
                  case AttendanceStatus.absent:
                    iconBg = AppColors.errorContainer;
                    iconFg = AppColors.error;
                    icon = Icons.cancel_rounded;
                    badgeBg = AppColors.errorContainer;
                    badgeFg = AppColors.onErrorContainer;
                    break;
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
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
                                r.className,
                                style: AppTypography.labelLg(color: AppColors.onSurface).copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Oct ${r.date.day}, 2023 • ${r.date.hour}:${r.date.minute.toString().padLeft(2, '0')} AM',
                                style: AppTypography.labelSm(color: AppColors.outline),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: badgeBg,
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          child: Text(
                            r.status.displayName,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: badgeFg,
                            ),
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
}

class _StatRow extends StatelessWidget {
  final Color color;
  final String label;

  const _StatRow({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: AppTypography.bodySm(color: AppColors.onSurfaceVariant),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _CalendarMatrixRow extends StatelessWidget {
  final List<_MatrixDay> days;

  const _CalendarMatrixRow({required this.days});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: days.map((d) {
        return SizedBox(
          width: 32,
          child: Column(
            children: [
              if (d.isToday)
                Container(
                  width: 26,
                  height: 26,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${d.day}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              else
                Text(
                  '${d.day}',
                  style: TextStyle(
                    fontSize: 13,
                    color: d.isFaded ? AppColors.outline.withValues(alpha: 0.4) : AppColors.onSurface,
                  ),
                ),
              const SizedBox(height: 2),
              if (d.dotColor != null)
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: d.dotColor,
                    shape: BoxShape.circle,
                  ),
                )
              else
                const SizedBox(height: 5),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _MatrixDay {
  final int day;
  final bool isFaded;
  final bool isToday;
  final Color? dotColor;

  _MatrixDay({
    required this.day,
    this.isFaded = false,
    this.isToday = false,
    this.dotColor,
  });
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: AppTypography.labelSm(color: AppColors.onSurfaceVariant)),
      ],
    );
  }
}

class _SubjectProgressRow extends StatelessWidget {
  final String title;
  final int percentage;
  final Color color;

  const _SubjectProgressRow({
    required this.title,
    required this.percentage,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: AppTypography.bodySm(color: AppColors.onSurface).copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$percentage%',
              style: AppTypography.bodySm(color: color).copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(9999),
          child: LinearProgressIndicator(
            value: percentage / 100,
            minHeight: 8,
            backgroundColor: AppColors.surfaceContainerHigh,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
