import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:edumeet/features/auth/presentation/providers/auth_provider.dart';
import 'package:edumeet/features/classroom/domain/entities/class_entity.dart';
import 'package:edumeet/features/classroom/presentation/providers/classroom_provider.dart';

class ClassesScheduleScreen extends ConsumerStatefulWidget {
  const ClassesScheduleScreen({super.key});

  @override
  ConsumerState<ClassesScheduleScreen> createState() => _ClassesScheduleScreenState();
}

class _ClassesScheduleScreenState extends ConsumerState<ClassesScheduleScreen> {
  int _selectedDay = 18; // Wednesday 18th
  String _selectedFilter = 'All Classes';

  final List<String> _filters = ['All Classes', 'Live Now', 'Upcoming', 'Completed'];

  void _showClassDetailsModal({
    required ClassEntity cls,
    required bool isTeacher,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [AppColors.floatingShadow],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top drag indicator
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        EduMeetBadge(
                          label: cls.isLive ? 'Live Now' : 'Upcoming Session',
                          variant: cls.isLive ? EduMeetBadgeVariant.live : EduMeetBadgeVariant.upcoming,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          cls.title,
                          style: AppTypography.headlineSm(color: AppColors.onSurface),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${cls.scheduleTime} • ${cls.roomNumber}',
                          style: AppTypography.labelSm(color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Class Code Display for quick sharing
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.secondaryFixed.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Class Invite Code', style: AppTypography.labelSm(color: AppColors.onSurfaceVariant)),
                        Text(
                          cls.roomCode,
                          style: AppTypography.headlineSm(color: AppColors.onSurface).copyWith(
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.copy_rounded, size: 16),
                      label: const Text('Copy Code', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: cls.roomCode));
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Class code ${cls.roomCode} copied to clipboard!'),
                            duration: const Duration(seconds: 2),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Instructor / Host Info Card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundImage: cls.teacherAvatar != null
                          ? NetworkImage(cls.teacherAvatar!)
                          : null,
                      child: cls.teacherAvatar == null
                          ? const Icon(Icons.person, color: AppColors.primary)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cls.teacherName,
                            style: AppTypography.labelLg(color: AppColors.onSurface).copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            cls.teacherTitle ?? cls.subject,
                            style: AppTypography.labelSm(color: AppColors.onSurfaceVariant),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, size: 16, color: AppColors.secondary),
                              const SizedBox(width: 4),
                              Text(
                                '${cls.rating} Rating • ${cls.studentCount} Students',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.tertiary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Description
              Text(
                'About This Session',
                style: AppTypography.labelLg(color: AppColors.onSurface).copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                cls.description ?? 'Interactive virtual lecture and hands-on problem solving session.',
                style: AppTypography.bodySm(color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 20),

              // Action button to start or join
              EduMeetButton(
                label: isTeacher ? 'Start Teaching Live' : 'Join Live Classroom',
                variant: EduMeetButtonVariant.secondary,
                icon: Icons.videocam,
                onPressed: () {
                  Navigator.pop(ctx);
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
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authNotifierProvider).user;
    final isTeacher = user?.role.isTeacher ?? false;
    final classesAsync = ref.watch(classesStreamProvider);

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
                // Top Header Greeting & Action
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isTeacher ? 'My Teaching Classes' : 'Enrolled Classes',
                            style: AppTypography.headlineLg(color: AppColors.onSurface),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            isTeacher
                                ? 'Manage live rooms, schedule sessions & class codes'
                                : 'View your classes and join live learning sessions',
                            style: AppTypography.bodySm(color: AppColors.onSurfaceVariant),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    EduMeetButton(
                      label: isTeacher ? '+ Create Class' : '+ Join Class',
                      variant: EduMeetButtonVariant.primary,
                      icon: Icons.add,
                      height: 38,
                      onPressed: () {
                        if (isTeacher) {
                          context.push(RouteConstants.createClass);
                        } else {
                          context.push(RouteConstants.joinClass);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Interactive Weekly Calendar Strip
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
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
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _CalendarDay(dayLabel: 'M', dayNumber: 16, isSelected: _selectedDay == 16, onTap: () => setState(() => _selectedDay = 16))),
                          Expanded(child: _CalendarDay(dayLabel: 'T', dayNumber: 17, isSelected: _selectedDay == 17, onTap: () => setState(() => _selectedDay = 17))),
                          Expanded(child: _CalendarDay(dayLabel: 'W', dayNumber: 18, isSelected: _selectedDay == 18, onTap: () => setState(() => _selectedDay = 18))),
                          Expanded(child: _CalendarDay(dayLabel: 'T', dayNumber: 19, isSelected: _selectedDay == 19, onTap: () => setState(() => _selectedDay = 19))),
                          Expanded(child: _CalendarDay(dayLabel: 'F', dayNumber: 20, isSelected: _selectedDay == 20, hasDot: true, onTap: () => setState(() => _selectedDay = 20))),
                          Expanded(child: _CalendarDay(dayLabel: 'S', dayNumber: 21, isSelected: _selectedDay == 21, onTap: () => setState(() => _selectedDay = 21))),
                          Expanded(child: _CalendarDay(dayLabel: 'S', dayNumber: 22, isSelected: _selectedDay == 22, onTap: () => setState(() => _selectedDay = 22))),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Filter Chips
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _filters.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final f = _filters[index];
                      final isSelected = f == _selectedFilter;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedFilter = f),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : AppColors.surfaceContainer,
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          child: Center(
                            child: Text(
                              f,
                              style: AppTypography.labelMd(
                                color: isSelected ? AppColors.onPrimary : AppColors.onSurface,
                              ).copyWith(fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Dynamic Stream-driven Class List
                classesAsync.when(
                  data: (allClasses) {
                    var filtered = isTeacher
                        ? allClasses.where((c) => c.teacherId == user?.id).toList()
                        : allClasses.where((c) => c.enrolledStudentIds.contains(user?.id)).toList();

                    // If filtered list is empty, fallback to showing all classes so screen isn't empty
                    if (filtered.isEmpty) {
                      filtered = allClasses;
                    }

                    // Apply tab filter
                    if (_selectedFilter == 'Live Now') {
                      filtered = filtered.where((c) => c.isLive).toList();
                    } else if (_selectedFilter == 'Upcoming') {
                      filtered = filtered.where((c) => !c.isLive).toList();
                    }

                    if (filtered.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(32),
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            const Icon(Icons.event_busy_rounded, size: 48, color: AppColors.outline),
                            const SizedBox(height: 12),
                            Text(
                              'No classes found for "$_selectedFilter"',
                              style: AppTypography.bodyLg(color: AppColors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      );
                    }

                    return Column(
                      children: filtered.map((cls) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _DynamicClassCard(
                            cls: cls,
                            isTeacher: isTeacher,
                            onTap: () => _showClassDetailsModal(cls: cls, isTeacher: isTeacher),
                            onAction: () {
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
                  error: (err, _) => Center(child: Text('Error loading classes: $err')),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CalendarDay extends StatelessWidget {
  final String dayLabel;
  final int dayNumber;
  final bool isSelected;
  final bool hasDot;
  final VoidCallback onTap;

  const _CalendarDay({
    required this.dayLabel,
    required this.dayNumber,
    required this.isSelected,
    this.hasDot = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          boxShadow: isSelected ? const [AppColors.softShadow] : null,
        ),
        child: Column(
          children: [
            Text(
              dayLabel,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? AppColors.onPrimary.withValues(alpha: 0.8) : AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$dayNumber',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isSelected ? AppColors.onPrimary : AppColors.onSurface,
              ),
            ),
            if (hasDot) ...[
              const SizedBox(height: 2),
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DynamicClassCard extends StatelessWidget {
  final ClassEntity cls;
  final bool isTeacher;
  final VoidCallback onTap;
  final VoidCallback onAction;

  const _DynamicClassCard({
    required this.cls,
    required this.isTeacher,
    required this.onTap,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return EduMeetCard(
      onTap: onTap,
      child: Stack(
        children: [
          if (cls.isLive)
            Positioned(
              top: 0,
              right: 0,
              bottom: 0,
              child: Container(
                width: 5,
                decoration: const BoxDecoration(
                  color: AppColors.tertiary,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.only(right: cls.isLive ? 8 : 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          EduMeetBadge(
                            label: cls.isLive ? 'LIVE' : 'UPCOMING',
                            variant: cls.isLive ? EduMeetBadgeVariant.live : EduMeetBadgeVariant.upcoming,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              cls.scheduleTime,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (isTeacher)
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: cls.roomCode));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Class Code ${cls.roomCode} copied!'),
                              duration: const Duration(seconds: 2),
                              backgroundColor: AppColors.primary,
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primaryFixed,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              Text(
                                'Code: ${cls.roomCode}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.copy, size: 12, color: AppColors.primary),
                            ],
                          ),
                        ),
                      )
                    else
                      const Icon(Icons.chevron_right, size: 20, color: AppColors.outline),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isTeacher ? Icons.school : Icons.design_services_rounded,
                        size: 24,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cls.title,
                            style: AppTypography.headlineSm(color: AppColors.onSurface).copyWith(
                              fontSize: 17,
                            ),
                          ),
                          Text(
                            isTeacher
                                ? '${cls.subject} • ${cls.roomNumber}'
                                : '${cls.teacherName} • ${cls.roomNumber}',
                            style: AppTypography.bodySm(color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AvatarGroup(
                      imageUrls: cls.studentAvatars.isNotEmpty
                          ? cls.studentAvatars
                          : const [
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuAaipJbAwOCd2XcVWmt9rLadhtCQf8gN1l6fNEspfk7tt6An3SjIiFLSV21yvnQw3E4Uvqossna5CEWSA6v3UXr-7laJQSrEh4wOT3E0MDkIEnuiifkj8ekb5SSG4tdrN7T57twJ9seHUcqiNxr5nz3NlTatdi8tm5piI166RpB-FKTSkRXvgeaezdgW0AhUb0Jfy8bwR2NShV00NfbKrZnNChNfFqIuQLdR45DiPo',
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuCDlshp6GQgbIqIbflq4Ohd7lZ7eSvFEh9meyQ2V8cDawLW_631kQIiX-P-oatViHEWwLNNNlIC-pDZ0H_TKmC_axZdyBuGOU4xuDGfPbd-U7jamKo-p_-0LM7RwAVHvGiz8EH9Y9kRmWTBkcHkvklYiW1aRt_s1i17N2gMcG5AxxZr-GoWF8hnyoktx5fAzJt6q23MIj3D76Llq-46xUUnb9pbk5B3-UbS9OgXwwo',
                            ],
                      totalCount: cls.studentCount,
                      size: 28,
                    ),
                    EduMeetButton(
                      label: isTeacher
                          ? (cls.isLive ? 'Host Live' : 'Start Live')
                          : (cls.isLive ? 'Join Live' : 'View Class'),
                      variant: cls.isLive
                          ? EduMeetButtonVariant.tertiary
                          : EduMeetButtonVariant.secondary,
                      icon: cls.isLive ? Icons.videocam : Icons.info_outline,
                      height: 36,
                      onPressed: onAction,
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
}
