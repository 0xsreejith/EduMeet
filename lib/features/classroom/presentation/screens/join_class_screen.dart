import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:edumeet/app/theme/app_colors.dart';
import 'package:edumeet/app/theme/app_typography.dart';
import 'package:edumeet/core/widgets/edumeet_button.dart';
import 'package:edumeet/core/widgets/edumeet_text_field.dart';
import 'package:edumeet/core/widgets/responsive_layout.dart';
import 'package:edumeet/features/auth/presentation/providers/auth_provider.dart';
import 'package:edumeet/features/classroom/presentation/providers/classroom_provider.dart';
import 'package:edumeet/features/live_classroom/presentation/dialogs/dev_rtc_launcher_sheet.dart';

class JoinClassScreen extends ConsumerStatefulWidget {
  const JoinClassScreen({super.key});

  @override
  ConsumerState<JoinClassScreen> createState() => _JoinClassScreenState();
}

class _JoinClassScreenState extends ConsumerState<JoinClassScreen> {
  final _codeController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _join() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      setState(() => _errorMessage = 'Please enter an invite code.');
      return;
    }

    setState(() => _errorMessage = null);
    final user = ref.read(authNotifierProvider).user;
    final success = await ref.read(classroomNotifierProvider.notifier).joinClass(
          code,
          user?.id ?? 'student_01',
        );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Successfully enrolled in class!'),
          backgroundColor: AppColors.tertiary,
        ),
      );
      context.pop();
    } else if (mounted) {
      final err = ref.read(classroomNotifierProvider).errorMessage;
      setState(() => _errorMessage = err ?? 'Invalid class code. Try MATH402 or REACT20');
    }
  }

  @override
  Widget build(BuildContext context) {
    final classroomState = ref.watch(classroomNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Join a Classroom',
          style: AppTypography.headlineSm(color: AppColors.onSurface),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: ResponsiveContainer(
          maxWidth: 520,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primaryFixed,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.group_add_rounded,
                  size: 36,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Enter Class Code',
                style: AppTypography.headlineSm(color: AppColors.onSurface),
              ),
              const SizedBox(height: 6),
              Text(
                'Ask your teacher for the 6-character class code to join the live session and materials.',
                style: AppTypography.bodySm(color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 24),

              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: AppTypography.labelSm(color: AppColors.onErrorContainer),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              EduMeetTextField(
                label: 'Class Code',
                hintText: 'e.g. MATH402 or REACT20',
                controller: _codeController,
                prefixIcon: Icons.vpn_key_outlined,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _join(),
              ),
              const SizedBox(height: 12),

              // Available sample codes helper
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sample Active Class Codes for Testing:',
                      style: AppTypography.labelSm(color: AppColors.outline),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _CodeChip(
                          code: 'MATH402',
                          onTap: () => _codeController.text = 'MATH402',
                        ),
                        const SizedBox(width: 8),
                        _CodeChip(
                          code: 'REACT20',
                          onTap: () => _codeController.text = 'REACT20',
                        ),
                        const SizedBox(width: 8),
                        _CodeChip(
                          code: 'CHEM101',
                          onTap: () => _codeController.text = 'CHEM101',
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              EduMeetButton(
                label: 'Join Classroom',
                variant: EduMeetButtonVariant.primary,
                isLoading: classroomState.isLoading,
                icon: Icons.login_rounded,
                onPressed: _join,
              ),
              const SizedBox(height: 12),

              // [DEV RTC TESTING MODE]
              OutlinedButton.icon(
                icon: const Icon(Icons.hub_outlined, size: 18),
                label: const Text('Testing RTC? Join with custom Room ID'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () => DevRtcLauncherSheet.show(context),
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

class _CodeChip extends StatelessWidget {
  final String code;
  final VoidCallback onTap;

  const _CodeChip({required this.code, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Text(
          code,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
