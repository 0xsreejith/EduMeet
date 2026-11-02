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

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await ref.read(authNotifierProvider.notifier).signIn(
          _emailController.text,
          _passwordController.text,
        );
    if (success && mounted) {
      context.go(RouteConstants.home);
    }
  }

  Future<void> _loginAsDemo(UserRole role) async {
    if (role == UserRole.teacher) {
      _emailController.text = 'eleanor.vance@edumeet.com';
      _passwordController.text = 'teacher123';
    } else {
      _emailController.text = 'sarah.rivera@edumeet.com';
      _passwordController.text = 'student123';
    }
    await _handleLogin();
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
                  'Welcome Back',
                  style: AppTypography.headlineLg(color: AppColors.onSurface),
                ),
                const SizedBox(height: 6),
                Text(
                  'Sign in to access your classes, schedule and live sessions.',
                  style: AppTypography.bodyMd(color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: 24),

                // Demo Quick Fill Pills
                Text(
                  'Quick Fill Demo Credentials:',
                  style: AppTypography.labelSm(color: AppColors.outline),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                          side: const BorderSide(color: AppColors.primary),
                        ),
                        onPressed: () => _loginAsDemo(UserRole.student),
                        icon: const Icon(Icons.person, size: 16),
                        label: const Text('Student Demo', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                          side: const BorderSide(color: AppColors.secondary),
                        ),
                        onPressed: () => _loginAsDemo(UserRole.teacher),
                        icon: const Icon(Icons.school, size: 16, color: AppColors.secondary),
                        label: const Text(
                          'Teacher Demo',
                          style: TextStyle(fontSize: 12, color: AppColors.secondary),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

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
                  label: 'Email Address',
                  hintText: 'e.g. sarah@example.com',
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
                  label: 'Password',
                  hintText: 'Enter your password',
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
                const SizedBox(height: 8),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Password reset instructions sent to your email.'),
                        ),
                      );
                    },
                    child: Text(
                      'Forgot Password?',
                      style: AppTypography.labelMd(color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                EduMeetButton(
                  label: 'Sign In',
                  variant: EduMeetButtonVariant.primary,
                  isLoading: authState.isLoading,
                  onPressed: _handleLogin,
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: AppTypography.bodySm(color: AppColors.onSurfaceVariant),
                    ),
                    GestureDetector(
                      onTap: () => context.push(RouteConstants.register),
                      child: Text(
                        'Register',
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
