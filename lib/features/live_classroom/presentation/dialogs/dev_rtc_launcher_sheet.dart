import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_constants.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/services/zego_service.dart';
import '../../../../core/widgets/edumeet_button.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

// =============================================================================
// [DEV RTC TESTING MODE]
// Temporary two-device RTC testing launcher.
// Cleanly isolated for developer testing without Firebase authentication.
// Remove or disable before production release.
// =============================================================================

class DevRtcLauncherSheet extends ConsumerStatefulWidget {
  const DevRtcLauncherSheet({super.key});

  /// Opens the Dev RTC Launcher Bottom Sheet
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const DevRtcLauncherSheet(),
    );
  }

  @override
  ConsumerState<DevRtcLauncherSheet> createState() => _DevRtcLauncherSheetState();
}

class _DevRtcLauncherSheetState extends ConsumerState<DevRtcLauncherSheet> {
  late final TextEditingController _roomIdController;
  late final TextEditingController _nameController;
  late UserRole _selectedRole;
  late String _participantIdSuffix;
  String? _errorMessage;

  static const List<String> _presetRooms = [
    'edumeet_demo_room',
    'physics_101',
    'math_live',
  ];

  @override
  void initState() {
    super.initState();
    final currentUser = ref.read(authNotifierProvider).user;
    _selectedRole = currentUser?.role ?? UserRole.teacher;
    _participantIdSuffix = (Random().nextInt(9000) + 1000).toString();

    _roomIdController = TextEditingController(text: 'edumeet_demo_room');
    _nameController = TextEditingController(
      text: currentUser?.displayName ??
          (_selectedRole.isTeacher ? 'Dr. Eleanor Vance' : 'Sarah Rivera'),
    );
  }

  @override
  void dispose() {
    _roomIdController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _regenerateId() {
    setState(() {
      _participantIdSuffix = (Random().nextInt(9000) + 1000).toString();
    });
  }

  String get _computedUserId {
    final prefix = _selectedRole.isTeacher ? 'teacher_vance' : 'student_sarah';
    return '${prefix}_$_participantIdSuffix';
  }

  Future<void> _handleRoleChange(UserRole role) async {
    setState(() {
      _selectedRole = role;
      _nameController.text =
          role.isTeacher ? 'Dr. Eleanor Vance' : 'Sarah Rivera';
    });
    await ref.read(authNotifierProvider.notifier).switchRole(role);
  }

  Future<void> _launchClassroom() async {
    final roomId = _roomIdController.text.trim();
    if (roomId.isEmpty) {
      setState(() => _errorMessage = 'Please enter a valid Room ID.');
      return;
    }

    final displayName = _nameController.text.trim().isNotEmpty
        ? _nameController.text.trim()
        : (_selectedRole.isTeacher ? 'Dr. Eleanor Vance' : 'Sarah Rivera');

    // Ensure Riverpod role state matches selected role
    await ref.read(authNotifierProvider.notifier).switchRole(_selectedRole);

    if (!mounted) return;
    Navigator.pop(context);

    // Navigate to LiveClassroomScreen with explicit Room ID and unique test participant ID
    context.push(
      RouteConstants.liveClassroom.replaceFirst(':roomId', roomId),
      extra: {
        'classTitle': _selectedRole.isTeacher
            ? 'Live Lecture: Quantum Systems'
            : 'AP Physics: Quantum Systems',
        'teacherName': _selectedRole.isTeacher ? displayName : 'Dr. Eleanor Vance',
        'isHost': _selectedRole.isTeacher,
        'customUserId': _computedUserId,
        'customUserName': displayName,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasCredentials = ZegoService.hasValidCredentials;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: 20 + bottomInset,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryFixed,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'DEV RTC TEST',
                            style: AppTypography.labelSm(color: AppColors.primary)
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Two-Device Session',
                            style: AppTypography.headlineSm(
                                color: AppColors.onSurface),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Join the same Room ID on two physical devices or simulators to test real-time video, audio, mute-all, and host termination.',
                style: AppTypography.bodySm(color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 12),

              // ZEGOCLOUD Credential Status Banner
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: hasCredentials
                      ? AppColors.tertiaryContainer.withValues(alpha: 0.4)
                      : AppColors.errorContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: hasCredentials
                        ? AppColors.tertiary.withValues(alpha: 0.4)
                        : AppColors.error.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      hasCredentials
                          ? Icons.check_circle_rounded
                          : Icons.info_outline_rounded,
                      size: 16,
                      color: hasCredentials
                          ? AppColors.onTertiaryContainer
                          : AppColors.error,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        hasCredentials
                            ? 'ZEGOCLOUD RTC Active (AppID: ${ZegoService.appId})'
                            : 'Mock RTC Mode (No --dart-define credentials detected)',
                        style: AppTypography.labelSm(
                          color: hasCredentials
                              ? AppColors.onTertiaryContainer
                              : AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 1. Role Selector (Teacher vs Student)
              Text(
                '1. Select Role for this Device',
                style: AppTypography.labelLg(color: AppColors.onSurface)
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _RoleCard(
                      title: 'Teacher (Host)',
                      subtitle: 'Host controls & Mute All',
                      icon: Icons.school_rounded,
                      isSelected: _selectedRole.isTeacher,
                      color: AppColors.primary,
                      onTap: () => _handleRoleChange(UserRole.teacher),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _RoleCard(
                      title: 'Student',
                      subtitle: 'Attendee & Raise Hand',
                      icon: Icons.person_rounded,
                      isSelected: _selectedRole.isStudent,
                      color: AppColors.secondary,
                      onTap: () => _handleRoleChange(UserRole.student),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 2. Room ID Entry
              Text(
                '2. Manual Room ID Entry',
                style: AppTypography.labelLg(color: AppColors.onSurface)
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _roomIdController,
                decoration: InputDecoration(
                  hintText: 'e.g. edumeet_demo_room',
                  prefixIcon:
                      const Icon(Icons.meeting_room_outlined, size: 20),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () => _roomIdController.clear(),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 6),

              // Quick Preset Room Chips
              Wrap(
                spacing: 8,
                children: _presetRooms.map((preset) {
                  return ActionChip(
                    label: Text(preset, style: const TextStyle(fontSize: 11)),
                    backgroundColor: AppColors.surfaceContainerLow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    onPressed: () {
                      setState(() {
                        _roomIdController.text = preset;
                        _errorMessage = null;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // 3. Unique Participant Identity
              Text(
                '3. Generated Test Identity',
                style: AppTypography.labelLg(color: AppColors.onSurface)
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: _selectedRole.isTeacher
                          ? AppColors.primaryFixed
                          : AppColors.secondaryFixed,
                      child: Icon(
                        _selectedRole.isTeacher
                            ? Icons.school
                            : Icons.person,
                        size: 18,
                        color: _selectedRole.isTeacher
                            ? AppColors.primary
                            : AppColors.secondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _nameController.text,
                            style: AppTypography.labelLg(
                                color: AppColors.onSurface),
                          ),
                          Text(
                            'User ID: $_computedUserId',
                            style: AppTypography.bodySm(
                                color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded, size: 20),
                      tooltip: 'Regenerate Unique User ID',
                      onPressed: _regenerateId,
                    ),
                  ],
                ),
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 10),
                Text(
                  _errorMessage!,
                  style: const TextStyle(
                      color: AppColors.error, fontSize: 13),
                ),
              ],
              const SizedBox(height: 20),

              // Launch Button
              EduMeetButton(
                label: _selectedRole.isTeacher
                    ? 'Start Live Class as Teacher (Host)'
                    : 'Join Live Class as Student',
                icon: Icons.videocam_rounded,
                variant: _selectedRole.isTeacher
                    ? EduMeetButtonVariant.primary
                    : EduMeetButtonVariant.secondary,
                height: 48,
                onPressed: _launchClassroom,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.1)
              : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? color : AppColors.outlineVariant.withValues(alpha: 0.4),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: isSelected ? color : AppColors.onSurfaceVariant, size: 22),
                if (isSelected)
                  Icon(Icons.check_circle_rounded, color: color, size: 16),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTypography.labelMd(color: AppColors.onSurface).copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: AppTypography.bodySm(color: AppColors.onSurfaceVariant).copyWith(fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
