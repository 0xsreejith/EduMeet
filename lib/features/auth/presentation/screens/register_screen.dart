import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:edumeet/app/router/route_constants.dart';
import 'package:edumeet/app/theme/app_colors.dart';
import 'package:edumeet/app/theme/app_typography.dart';
import 'package:edumeet/core/widgets/edumeet_button.dart';
import 'package:edumeet/core/widgets/edumeet_text_field.dart';
import 'package:edumeet/core/widgets/responsive_layout.dart';
import 'package:edumeet/features/auth/domain/entities/user_entity.dart';
import 'package:edumeet/features/auth/presentation/providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  final String? initialRole;

  const RegisterScreen({super.key, this.initialRole});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _extraController = TextEditingController(); // Student ID or Teacher Title

  late UserRole _selectedRole;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.initialRole == 'teacher' ? UserRole.teacher : UserRole.student;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _extraController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authNotifierProvider.notifier).register(
          email: _emailController.text,
          password: _passwordController.text,
          displayName: _nameController.text,
          role: _selectedRole,
          studentId: _selectedRole.isStudent ? _extraController.text : null,
          title: _selectedRole.isTeacher ? _extraController.text : null,
        );

    if (success && mounted) {
      context.go(RouteConstants.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: ResponsiveContainer(
          maxWidth: 520,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                Text(
                  'Create Account',
                  style: AppTypography.headlineLg(color: AppColors.onSurface),
                ),
                const SizedBox(height: 6),
                Text(
                  'Join EduMeet to collaborate in real-time interactive classrooms.',
                  style: AppTypography.bodyMd(color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: 20),

                // Role selector
                Text(
                  'Select Role:',
                  style: AppTypography.labelLg(color: AppColors.onSurface).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person, size: 16),
                            SizedBox(width: 6),
                            Text('Student'),
                          ],
                        ),
                        selected: _selectedRole == UserRole.student,
                        selectedColor: AppColors.primaryFixed,
                        onSelected: (val) {
                          if (val) setState(() => _selectedRole = UserRole.student);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ChoiceChip(
                        label: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.school, size: 16),
                            SizedBox(width: 6),
                            Text('Teacher'),
                          ],
                        ),
                        selected: _selectedRole == UserRole.teacher,
                        selectedColor: AppColors.secondaryFixed,
                        onSelected: (val) {
                          if (val) setState(() => _selectedRole = UserRole.teacher);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                if (authState.errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.errorContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      authState.errorMessage!,
                      style: AppTypography.labelSm(color: AppColors.onErrorContainer),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                EduMeetTextField(
                  label: 'Full Name',
                  hintText: _selectedRole.isTeacher ? 'e.g. Dr. Eleanor Vance' : 'e.g. Sarah Rivera',
                  controller: _nameController,
                  prefixIcon: Icons.badge_outlined,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Please enter your name';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                EduMeetTextField(
                  label: 'Email Address',
                  hintText: 'e.g. name@edumeet.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Please enter your email';
                    if (!val.contains('@')) return 'Please enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                EduMeetTextField(
                  label: _selectedRole.isTeacher ? 'Academic Title / Subject' : 'Student ID (Optional)',
                  hintText: _selectedRole.isTeacher
                      ? 'e.g. Lead Principal Designer & Researcher'
                      : 'e.g. SID-88492',
                  controller: _extraController,
                  prefixIcon: _selectedRole.isTeacher ? Icons.work_outline : Icons.tag,
                ),
                const SizedBox(height: 16),

                EduMeetTextField(
                  label: 'Password',
                  hintText: 'Create a password (min 6 characters)',
                  controller: _passwordController,
                  isPassword: true,
                  prefixIcon: Icons.lock_outline,
                  textInputAction: TextInputAction.done,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Please enter your password';
                    if (val.length < 6) return 'Password must be at least 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                EduMeetButton(
                  label: 'Create Account',
                  variant: EduMeetButtonVariant.primary,
                  isLoading: authState.isLoading,
                  onPressed: _handleRegister,
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: AppTypography.bodySm(color: AppColors.onSurfaceVariant),
                    ),
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Text(
                        'Sign In',
                        style: AppTypography.labelLg(color: AppColors.primary).copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  }
}
