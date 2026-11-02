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

class CreateClassScreen extends ConsumerStatefulWidget {
  const CreateClassScreen({super.key});

  @override
  ConsumerState<CreateClassScreen> createState() => _CreateClassScreenState();
}

class _CreateClassScreenState extends ConsumerState<CreateClassScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _subjectController = TextEditingController();
  final _timeController = TextEditingController(text: '10:00 AM - 11:30 AM');
  final _roomController = TextEditingController(text: 'Room 402');
  final _descController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _subjectController.dispose();
    _timeController.dispose();
    _roomController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(authNotifierProvider).user;
    final created = await ref.read(classroomNotifierProvider.notifier).createClass(
          title: _titleController.text,
          subject: _subjectController.text,
          scheduleTime: _timeController.text,
          roomNumber: _roomController.text,
          teacherId: user?.id ?? 'teacher_01',
          teacherName: user?.displayName ?? 'Dr. Eleanor Vance',
          teacherTitle: user?.title ?? 'Instructor',
          teacherAvatar: user?.avatarUrl,
          description: _descController.text,
        );

    if (created != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Class "${created.title}" created! Code: ${created.roomCode}'),
          backgroundColor: AppColors.tertiary,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final classroomState = ref.watch(classroomNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Create New Class',
          style: AppTypography.headlineSm(color: AppColors.onSurface),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: ResponsiveContainer(
          maxWidth: 600,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                Text(
                  'Class Information',
                  style: AppTypography.headlineSm(color: AppColors.onSurface),
                ),
                const SizedBox(height: 4),
                Text(
                  'Set up your classroom details. A unique enrollment code will be generated.',
                  style: AppTypography.bodySm(color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: 20),

                EduMeetTextField(
                  label: 'Class Title',
                  hintText: 'e.g. Advanced UX Case Studies',
                  controller: _titleController,
                  prefixIcon: Icons.class_outlined,
                  validator: (val) => val == null || val.trim().isEmpty ? 'Please enter a title' : null,
                ),
                const SizedBox(height: 16),

                EduMeetTextField(
                  label: 'Subject / Focus Area',
                  hintText: 'e.g. Calculus & Series Convergence',
                  controller: _subjectController,
                  prefixIcon: Icons.menu_book_outlined,
                  validator: (val) => val == null || val.trim().isEmpty ? 'Please enter a subject' : null,
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: EduMeetTextField(
                        label: 'Schedule Time',
                        hintText: 'e.g. 10:00 AM - 11:30 AM',
                        controller: _timeController,
                        prefixIcon: Icons.schedule,
                        validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: EduMeetTextField(
                        label: 'Room / Hall',
                        hintText: 'e.g. Room 402',
                        controller: _roomController,
                        prefixIcon: Icons.room_outlined,
                        validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                EduMeetTextField(
                  label: 'Description & Syllabi',
                  hintText: 'Provide students with an overview of what they will learn...',
                  controller: _descController,
                  maxLines: 4,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 24),

                EduMeetButton(
                  label: 'Publish Class',
                  variant: EduMeetButtonVariant.primary,
                  isLoading: classroomState.isLoading,
                  icon: Icons.check,
                  onPressed: _submit,
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
