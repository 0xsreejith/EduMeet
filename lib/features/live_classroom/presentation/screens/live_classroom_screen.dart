import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zego_uikit/zego_uikit.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/services/zego_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/live_classroom_provider.dart';

class LiveClassroomScreen extends ConsumerStatefulWidget {
  final String roomId;
  final String? classTitle;
  final String? teacherName;
  final String? customUserId;
  final String? customUserName;

  const LiveClassroomScreen({
    super.key,
    required this.roomId,
    this.classTitle,
    this.teacherName,
    this.customUserId,
    this.customUserName,
  });

  @override
  ConsumerState<LiveClassroomScreen> createState() => _LiveClassroomScreenState();
}

class _LiveClassroomScreenState extends ConsumerState<LiveClassroomScreen>
    with WidgetsBindingObserver {
  bool _localMicFallback = true;
  bool _localCameraFallback = true;
  bool _showChatDrawer = false;
  bool _showParticipantsDrawer = false;
  bool _showRaiseHandBanner = false;
  String _raiseHandBannerText = 'You raised hand';
  bool _isFullscreen = false;
  bool _dismissedPermissionBanner = false;

  final TextEditingController _chatController = TextEditingController();
  StreamSubscription? _commandSubscription;
  Timer? _handBannerTimer;

  late final String _activeUserId;
  late final String _activeUserName;

  // Local fallback messages when running without live credentials
  final List<_InRoomMessage> _fallbackMessages = [
    _InRoomMessage(
      sender: 'Dr. Eleanor Vance',
      text: 'Please check page 42 for the wave-particle duality theorem summary.',
      time: '10:42 AM',
      isTeacher: true,
    ),
    _InRoomMessage(
      sender: 'Alex M.',
      text: 'Thank you! That makes total sense now.',
      time: '10:44 AM',
      isTeacher: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final user = ref.read(authNotifierProvider).user;
    final baseId = user?.id ?? 'user';
    _activeUserId = widget.customUserId ??
        (ZegoService.hasValidCredentials
            ? ZegoService.generateUniqueUserId(baseId)
            : baseId);
    _activeUserName = widget.customUserName ?? (user?.displayName ?? 'Participant');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkDevicePermissions(request: true);
      _initializeClassroom();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkDevicePermissions();
    }
  }

  Future<void> _checkDevicePermissions({bool request = false}) async {
    if (!ZegoService.hasValidCredentials) return;

    try {
      var cameraStatus = await Permission.camera.status;
      var micStatus = await Permission.microphone.status;

      // Avoid repeatedly requesting permissions when permanently denied
      if (request && !cameraStatus.isPermanentlyDenied && !micStatus.isPermanentlyDenied) {
        if (cameraStatus.isDenied || micStatus.isDenied) {
          final statuses = await [Permission.camera, Permission.microphone].request();
          cameraStatus = statuses[Permission.camera] ?? cameraStatus;
          micStatus = statuses[Permission.microphone] ?? micStatus;
        }
      }

      final isPermanentlyDenied = cameraStatus.isPermanentlyDenied || micStatus.isPermanentlyDenied;
      final isDenied = cameraStatus.isDenied || micStatus.isDenied;

      if (mounted) {
        ref.read(liveClassroomProvider.notifier).setPermissionDenied(isPermanentlyDenied || isDenied);
      }
    } catch (e) {
      debugPrint('[LiveClassroom] Permission check error: $e');
    }
  }

  Future<void> _handleOpenSettings() async {
    final cameraStatus = await Permission.camera.status;
    final micStatus = await Permission.microphone.status;

    // If permissions are not permanently denied, try requesting them directly first
    if (!cameraStatus.isPermanentlyDenied && !micStatus.isPermanentlyDenied &&
        (cameraStatus.isDenied || micStatus.isDenied)) {
      final statuses = await [Permission.camera, Permission.microphone].request();
      await _checkDevicePermissions(request: false);
      if ((statuses[Permission.camera]?.isGranted ?? false) ||
          (statuses[Permission.microphone]?.isGranted ?? false)) {
        return;
      }
    }

    // Attempt to open device App Settings
    final bool opened = await openAppSettings();
    if (!opened && mounted) {
      // On iOS Simulator or when openAppSettings returns false, display feedback dialog
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.settings, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Device Permissions'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Unable to open EduMeet App Settings directly.\n\n'
                '• iOS Simulator does not support direct deep-linking to app settings.\n'
                '• Run this command in terminal to grant permissions on simulator:\n'
                '  xcrun simctl privacy booted grant all com.edumeet.edumeet\n\n'
                '• On physical devices: open Settings > EduMeet to enable Camera & Microphone.',
                style: AppTypography.bodySm(color: AppColors.onSurface),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Dismiss'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
              ),
              onPressed: () async {
                Navigator.pop(ctx);
                await [Permission.camera, Permission.microphone].request();
                await _checkDevicePermissions(request: false);
              },
              child: const Text('Request Again'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _initializeClassroom() async {
    final user = ref.read(authNotifierProvider).user;
    if (user == null) return;

    final isTeacher = user.role.isTeacher;
    await ref.read(liveClassroomProvider.notifier).joinRoom(
          roomId: widget.roomId,
          userId: _activeUserId,
          userName: _activeUserName,
          isTeacher: isTeacher,
        );

    // Listen to ZEGOCLOUD in-room commands (Raise Hand, End Classroom, Mute All)
    if (ZegoService.hasValidCredentials) {
      _commandSubscription = ZegoUIKit().getInRoomCommandReceivedStream().listen((data) {
        if (data.command.startsWith('HAND_RAISE')) {
          if (mounted) {
            setState(() {
              _raiseHandBannerText = '${data.fromUser.name} raised hand ✋';
              _showRaiseHandBanner = true;
            });
            _handBannerTimer?.cancel();
            _handBannerTimer = Timer(const Duration(seconds: 4), () {
              if (mounted) {
                setState(() => _showRaiseHandBanner = false);
              }
            });
          }
        } else if (data.command.startsWith('HAND_LOWER')) {
          if (mounted) {
            setState(() => _showRaiseHandBanner = false);
          }
        } else if (data.command == 'CLASSROOM_ENDED_BY_TEACHER') {
          // Teacher ended the session for all participants
          if (mounted) {
            ref.read(liveClassroomProvider.notifier).onClassroomEndedByTeacher();
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => AlertDialog(
                title: const Text('Classroom Concluded'),
                content: const Text(
                  'The teacher has ended this classroom session for all participants.',
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _safePop();
                    },
                    child: const Text('Leave'),
                  ),
                ],
              ),
            );
          }
        } else if (data.command == 'MUTE_MICROPHONE_ALL' ||
            data.command == 'MUTE_MICROPHONE_USER:$_activeUserId') {
          // Remotely mute microphone at hardware source
          final isMicOn = ZegoUIKit().getMicrophoneStateNotifier(_activeUserId).value;
          if (isMicOn) {
            ZegoUIKit().turnMicrophoneOn(false, userID: _activeUserId);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Your microphone was muted by the teacher.'),
                  duration: Duration(seconds: 3),
                ),
              );
            }
          }
        }
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _handBannerTimer?.cancel();
    _commandSubscription?.cancel();
    _chatController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;

    final currentUser = ref.read(authNotifierProvider).user;
    _chatController.clear();

    if (ZegoService.hasValidCredentials) {
      await ZegoUIKit().sendInRoomMessage(text);
    } else {
      setState(() {
        _fallbackMessages.add(
          _InRoomMessage(
            sender: currentUser?.displayName ?? 'You',
            text: text,
            time: 'Just now',
            isTeacher: currentUser?.role.isTeacher ?? false,
            isSelf: true,
          ),
        );
      });
    }
  }

  Future<void> _toggleHand() async {
    final user = ref.read(authNotifierProvider).user;
    if (user == null) return;

    await ref.read(liveClassroomProvider.notifier).toggleHandRaise(
          userId: _activeUserId,
          userName: _activeUserName,
        );

    final isRaised = ref.read(liveClassroomProvider).isHandRaised;
    setState(() {
      _raiseHandBannerText = isRaised ? 'You raised hand ✋' : '';
      _showRaiseHandBanner = isRaised;
    });

    _handBannerTimer?.cancel();
    if (isRaised) {
      _handBannerTimer = Timer(const Duration(seconds: 4), () {
        if (mounted) {
          setState(() => _showRaiseHandBanner = false);
        }
      });
    }
  }

  void _safePop() {
    if (!mounted) return;
    try {
      context.pop();
    } catch (_) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }
  }

  void _handleLeaveOrEndClass(bool isTeacher) {
    if (isTeacher) {
      // Teacher Host Options
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (ctx) => Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'End Live Classroom',
                      style: AppTypography.headlineSm(color: AppColors.onSurface),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Choose whether to conclude the session for all participants or leave temporarily.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySm(color: AppColors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 16),
                    Material(
                      color: AppColors.errorContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                      child: ListTile(
                        leading: const Icon(Icons.call_end, color: AppColors.error),
                        title: const Text('End Classroom for All', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
                        subtitle: const Text('Broadcasts termination signal and disconnects all students'),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        onTap: () async {
                          Navigator.pop(ctx);
                          await ref.read(liveClassroomProvider.notifier).endClassroomForAll();
                          if (mounted) {
                            _safePop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Classroom ended for all students.')),
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Material(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      child: ListTile(
                        leading: const Icon(Icons.exit_to_app, color: AppColors.onSurface),
                        title: const Text('Leave Class Alone', style: TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: const Text('Keep room open for students while you step out'),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        onTap: () async {
                          Navigator.pop(ctx);
                          await ref.read(liveClassroomProvider.notifier).leaveRoom();
                          if (mounted) {
                            _safePop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('You left the classroom.')),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      // Student Attendee Confirmation
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Leave Classroom?'),
          content: const Text('Are you sure you want to leave this live session?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.onError,
              ),
              onPressed: () async {
                Navigator.pop(ctx);
                await ref.read(liveClassroomProvider.notifier).leaveRoom();
                if (mounted) {
                  _safePop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Left classroom session.')),
                  );
                }
              },
              child: const Text('Leave'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.classTitle ?? 'AP Physics: Quantum Mechanics';
    final teacher = widget.teacherName ?? 'Dr. Eleanor Vance';
    final currentUser = ref.watch(authNotifierProvider).user;
    final isTeacher = currentUser?.role.isTeacher ?? false;
    final roomState = ref.watch(liveClassroomProvider);
    final hasCredentials = ZegoService.hasValidCredentials;

    return ZegoScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.surface,
          appBar: AppBar(
            backgroundColor: AppColors.surface.withValues(alpha: 0.9),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              onPressed: () => _handleLeaveOrEndClass(isTeacher),
            ),
            title: Text(
              'Classroom Detail',
              style: AppTypography.headlineSm(color: AppColors.onSurface),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Connection Error / Diagnostic Banner
                  if (roomState.status == LiveClassroomStatus.error && roomState.errorMessage != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.errorContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: AppColors.onErrorContainer),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              roomState.errorMessage!,
                              style: AppTypography.bodySm(color: AppColors.onErrorContainer),
                            ),
                          ),
                        ],
                      ),
                    ),

              // Permission Denial Alert Banner
              if (roomState.hasPermissionDenied && !_dismissedPermissionBanner)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryFixed,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.secondary.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.videocam_off, color: AppColors.onSecondaryFixed),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Camera & Mic Access Required',
                              style: AppTypography.labelLg(color: AppColors.onSecondaryFixed).copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Please enable permissions to transmit video and audio.',
                              style: AppTypography.bodySm(color: AppColors.onSecondaryFixedVariant),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: AppColors.onSecondary,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: _handleOpenSettings,
                        child: const Text('Settings', style: TextStyle(fontSize: 12)),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18, color: AppColors.onSecondaryFixedVariant),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => setState(() => _dismissedPermissionBanner = true),
                      ),
                    ],
                  ),
                ),

              // Top Status Bar & Lesson Context
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: roomState.status == LiveClassroomStatus.reconnecting
                                  ? AppColors.secondary
                                  : AppColors.error,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              roomState.status == LiveClassroomStatus.reconnecting
                                  ? 'Reconnecting • $title'
                                  : 'Live • $title',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.labelLg(color: AppColors.onSurface).copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.group, size: 16, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            hasCredentials
                                ? '${roomState.participantCount}'
                                : '24',
                            style: AppTypography.labelMd(color: AppColors.onSurface),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Main Immersive Video Stream View
              Container(
                height: _isFullscreen ? 450 : 230,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.black87,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      // Video Stream View
                      if (hasCredentials && currentUser != null)
                        _buildLiveZegoVideoCanvas(currentUser, isTeacher)
                      else
                        _buildPrototypeVideoFallback(),

                      // Gradient overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.45),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.65),
                            ],
                          ),
                        ),
                      ),

                      // Top badges inside video
                      Positioned(
                        top: 12,
                        left: 12,
                        right: 12,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.surface.withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(9999),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.mic, size: 16, color: AppColors.primary),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        isTeacher ? 'Host (You)' : '$teacher (Teacher)',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTypography.labelMd(color: AppColors.onSurface),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.secondaryContainer.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(9999),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.videocam,
                                    size: 16,
                                    color: AppColors.onSecondaryContainer,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    hasCredentials ? 'RTC Live' : 'Demo Stream',
                                    style: AppTypography.labelMd(
                                      color: AppColors.onSecondaryContainer,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Animated Floating Raised Hand Banner
                      if (_showRaiseHandBanner)
                        Positioned(
                          right: 12,
                          bottom: 48,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.surface.withValues(alpha: 0.95),
                              borderRadius: BorderRadius.circular(9999),
                              boxShadow: const [AppColors.softShadow],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('✋ ', style: TextStyle(fontSize: 14)),
                                Text(
                                  _raiseHandBannerText,
                                  style: AppTypography.labelSm(color: AppColors.onSurface),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Bottom info & Fullscreen toggle inside video
                      Positioned(
                        bottom: 12,
                        left: 12,
                        right: 12,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                hasCredentials
                                    ? 'HD • ${widget.roomId} • Live'
                                    : 'HD • 60fps • 12ms',
                                style: AppTypography.labelSm(color: Colors.white),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => setState(() => _isFullscreen = !_isFullscreen),
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Participant Thumbnails Strip
              SizedBox(
                height: 84,
                child: hasCredentials
                    ? _buildDynamicZegoParticipantStrip(currentUser)
                    : _buildPrototypeParticipantStrip(roomState.isHandRaised),
              ),
              const SizedBox(height: 12),

              // Floating Controls Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [AppColors.softShadow],
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Mic toggle: Uses ZEGOCLOUD RTC state as source of truth
                      if (hasCredentials && currentUser != null)
                        ValueListenableBuilder<bool>(
                          valueListenable: ZegoUIKit().getMicrophoneStateNotifier(_activeUserId),
                          builder: (context, isMicOn, _) {
                            return _CircleButton(
                              icon: isMicOn ? Icons.mic : Icons.mic_off,
                              isActive: isMicOn,
                              activeBgColor: AppColors.surfaceContainer,
                              inactiveBgColor: AppColors.errorContainer,
                              activeFgColor: AppColors.onSurface,
                              inactiveFgColor: AppColors.onErrorContainer,
                              onPressed: () => ZegoService.toggleMicrophone(
                                userId: _activeUserId,
                                currentState: isMicOn,
                              ),
                            );
                          },
                        )
                      else
                        _CircleButton(
                          icon: _localMicFallback ? Icons.mic : Icons.mic_off,
                          isActive: _localMicFallback,
                          activeBgColor: AppColors.surfaceContainer,
                          inactiveBgColor: AppColors.errorContainer,
                          activeFgColor: AppColors.onSurface,
                          inactiveFgColor: AppColors.onErrorContainer,
                          onPressed: () => setState(() => _localMicFallback = !_localMicFallback),
                        ),
                      const SizedBox(width: 8),

                      // Camera toggle: Uses ZEGOCLOUD RTC state as source of truth
                      if (hasCredentials && currentUser != null)
                        ValueListenableBuilder<bool>(
                          valueListenable: ZegoUIKit().getCameraStateNotifier(_activeUserId),
                          builder: (context, isCameraOn, _) {
                            return _CircleButton(
                              icon: isCameraOn ? Icons.videocam : Icons.videocam_off,
                              isActive: isCameraOn,
                              activeBgColor: AppColors.surfaceContainer,
                              inactiveBgColor: AppColors.errorContainer,
                              activeFgColor: AppColors.onSurface,
                              inactiveFgColor: AppColors.onErrorContainer,
                              onPressed: () => ZegoService.toggleCamera(
                                userId: _activeUserId,
                                currentState: isCameraOn,
                              ),
                            );
                          },
                        )
                      else
                        _CircleButton(
                          icon: _localCameraFallback ? Icons.videocam : Icons.videocam_off,
                          isActive: _localCameraFallback,
                          activeBgColor: AppColors.surfaceContainer,
                          inactiveBgColor: AppColors.errorContainer,
                          activeFgColor: AppColors.onSurface,
                          inactiveFgColor: AppColors.onErrorContainer,
                          onPressed: () => setState(() => _localCameraFallback = !_localCameraFallback),
                        ),
                      const SizedBox(width: 8),

                      // Raise Hand (Student) or Mute All (Teacher)
                      if (!isTeacher)
                        _CircleButton(
                          icon: Icons.front_hand_rounded,
                          isActive: roomState.isHandRaised,
                          activeBgColor: AppColors.secondaryContainer,
                          inactiveBgColor: AppColors.surfaceContainer,
                          activeFgColor: AppColors.onSecondaryContainer,
                          inactiveFgColor: AppColors.onSurface,
                          onPressed: _toggleHand,
                        )
                      else
                        _CircleButton(
                          icon: Icons.volume_off_rounded,
                          isActive: false,
                          activeBgColor: AppColors.surfaceContainer,
                          inactiveBgColor: AppColors.surfaceContainer,
                          activeFgColor: AppColors.onSurface,
                          inactiveFgColor: AppColors.onSurface,
                          onPressed: () async {
                            await ref.read(liveClassroomProvider.notifier).muteAllStudents();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Muted all student microphones.')),
                              );
                            }
                          },
                        ),
                      const SizedBox(width: 8),

                      // Chat toggle
                      _CircleButton(
                        icon: Icons.chat_bubble_rounded,
                        isActive: _showChatDrawer,
                        activeBgColor: AppColors.primaryFixed,
                        inactiveBgColor: AppColors.surfaceContainer,
                        activeFgColor: AppColors.primary,
                        inactiveFgColor: AppColors.onSurface,
                        badgeCount: _fallbackMessages.length,
                        onPressed: () {
                          setState(() {
                            _showChatDrawer = !_showChatDrawer;
                            if (_showChatDrawer) _showParticipantsDrawer = false;
                          });
                        },
                      ),
                      const SizedBox(width: 8),

                      // Participants list toggle
                      _CircleButton(
                        icon: Icons.group_rounded,
                        isActive: _showParticipantsDrawer,
                        activeBgColor: AppColors.primaryFixed,
                        inactiveBgColor: AppColors.surfaceContainer,
                        activeFgColor: AppColors.primary,
                        inactiveFgColor: AppColors.onSurface,
                        onPressed: () {
                          setState(() {
                            _showParticipantsDrawer = !_showParticipantsDrawer;
                            if (_showParticipantsDrawer) _showChatDrawer = false;
                          });
                        },
                      ),
                      const SizedBox(width: 12),

                      // Leave / End classroom action
                      GestureDetector(
                        onTap: () => _handleLeaveOrEndClass(isTeacher),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.call_end, size: 18, color: AppColors.onError),
                              const SizedBox(width: 4),
                              Text(
                                isTeacher ? 'End Class' : 'Leave',
                                style: const TextStyle(
                                  color: AppColors.onError,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Collapsible Classroom Chat Drawer
              if (_showChatDrawer) ...[
                const SizedBox(height: 12),
                _buildChatDrawer(hasCredentials),
              ],

              // Collapsible Participants Drawer
              if (_showParticipantsDrawer) ...[
                const SizedBox(height: 12),
                _buildParticipantsDrawer(hasCredentials, isTeacher),
              ],
            ],
          ),
        ),
      ),
    );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // VIDEO STREAM VIEW IMPLEMENTATIONS
  // ---------------------------------------------------------------------------

  Widget _buildLiveZegoVideoCanvas(dynamic currentUser, bool isTeacher) {
    final localUser = ZegoUIKit().getLocalUser();
    final effectiveLocalUser = localUser.id.isNotEmpty
        ? localUser
        : ZegoUIKitUser(
            id: _activeUserId,
            name: _activeUserName,
          );

    final targetUser = isTeacher
        ? effectiveLocalUser
        : (ZegoUIKit().getRemoteUsers().isNotEmpty
            ? ZegoUIKit().getRemoteUsers().first
            : effectiveLocalUser);

    return ZegoAudioVideoView(
      user: targetUser,
      avatarConfig: const ZegoAvatarConfig(
        showInAudioMode: false,
        showSoundWavesInAudioMode: false,
      ),
      backgroundBuilder: (context, size, user, extraInfo) {
        final displayName = user?.name.isNotEmpty == true
            ? user!.name
            : (isTeacher ? 'Teacher (Host)' : 'Student');
        return Container(
          width: size.width,
          height: size.height,
          color: const Color(0xFF1E222A),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primaryContainer,
                child: Text(
                  displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.headlineSm(color: Colors.white),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isTeacher ? 'Host • Camera Off' : 'Participant • Audio Only',
                  style: AppTypography.labelMd(color: Colors.white70),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPrototypeVideoFallback() {
    return Image.network(
      'https://lh3.googleusercontent.com/aida-public/AB6AXuBCQi9jkOdzUWuHrvVnvSeL2wGk1pl0U4Qjs2NSvat40OL5fY6Ptk6LrIpUOTWk-m7WgSMGuf6C8-F-bHCqmpS8HOuytnmc_vz2Cbo-kAmlarWcxmO2rxxyy--8fAbO3PM9mMKe6XWP7YQl9RQ9j80rmIvHeChUpKirOwznvkSCqjrr9H3Usvas9rFnnIXv5oqJu-fvsAAM5egaop3b86-7zgZ9lZR88hHRhoVO8Mk',
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    );
  }

  // ---------------------------------------------------------------------------
  // PARTICIPANT STRIP IMPLEMENTATIONS
  // ---------------------------------------------------------------------------

  Widget _buildDynamicZegoParticipantStrip(dynamic currentUser) {
    return StreamBuilder<List<ZegoUIKitUser>>(
      stream: ZegoUIKit().getUserListStream(),
      builder: (context, snapshot) {
        final users = snapshot.data ?? [];
        if (users.isEmpty) {
          return Center(
            child: Text(
              'No other participants connected yet.',
              style: AppTypography.bodySm(color: AppColors.onSurfaceVariant),
            ),
          );
        }

        return ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: users.length,
          separatorBuilder: (_, index) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final u = users[index];
            return ValueListenableBuilder<bool>(
              valueListenable: ZegoUIKit().getMicrophoneStateNotifier(u.id),
              builder: (context, isMicOn, _) {
                return _ParticipantTile(
                  name: u.name,
                  imageUrl: null,
                  isMicMuted: !isMicOn,
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildPrototypeParticipantStrip(bool isHandRaised) {
    return ListView(
      scrollDirection: Axis.horizontal,
      children: [
        const _ParticipantTile(
          name: 'Alex M.',
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuATo0XIXW5uHRv_Sj7m3UutIvpsInc6p5hwzFd8csUg0mq52e_nEtxPjTNKJDqvuP_cbLsedN3XZKZ7isi0k_JLsKLGR2c5JCft9xMmb6MNDkKZYWxZT48NZ1WxexavOx4Ywx_1Dkf0YcuKll2ardBcgfJUBpVstUKco1HniIbTP4K20qbY6MUkW3z0eOKcScoUVfkYiQ9EyDmqdJvMCOsST7xyvIhvKxQ9xzNB1Mg',
          isMicMuted: true,
        ),
        const SizedBox(width: 8),
        _ParticipantTile(
          name: 'You (Hand Raised)',
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuDosMNmxdWum27RRCVGylVtGQGIhSiLBc2PyGPD55FoP31DBpkpJwUxiwuiK4OlUKM6Lce335iN3nKjLeofiBl5e5WGzqc-CZTZQlz5zsTIUfwz6I4IE6eCrEgalIWB5xkH0dcvECzfK1EMDqrlCQRvs_rK8Zs-v46YOL01vvdIiWY1Gv6i7iUZW49ES9uaLADpWmw-QVz_EK6S-RjqKdndZNdkQumruDxgi7z7Uz0',
          isHighlighted: isHandRaised,
          hasHandRaised: isHandRaised,
        ),
        const SizedBox(width: 8),
        const _ParticipantTile(
          name: 'Jordan K.',
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuCAEuElthGSeyJwuwbfQ0jpL1cC72u8vI_T2vTP7s1k9fY3vS6Lp1Pz1H_e31OQiptrKEAcv-2pfEWYL9SCPSAnxwbd7XTDthIy3yOWekoHjY_KkWVjLdCYnppckqiFOzdTle6MewG0Gg7Ub0720yLZVhjcppIWm0LYbZBTg0C5bnj109oLl8M-_tlf6UkflO5r5cwcfoCsEk0cYTkbblgzt_En9bDbH27PwOV8zzo',
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // IN-ROOM CHAT DRAWER
  // ---------------------------------------------------------------------------

  Widget _buildChatDrawer(bool hasCredentials) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [AppColors.softShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Classroom Chat',
                style: AppTypography.headlineSm(color: AppColors.onSurface),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: () => setState(() => _showChatDrawer = false),
              ),
            ],
          ),
          const Divider(),
          SizedBox(
            height: 180,
            child: hasCredentials
                ? StreamBuilder<List<ZegoInRoomMessage>>(
                    stream: ZegoUIKit().getInRoomMessageListStream(),
                    builder: (context, snapshot) {
                      final msgs = snapshot.data ?? [];
                      if (msgs.isEmpty) {
                        return Center(
                          child: Text(
                            'No messages yet. Send a question below!',
                            style: AppTypography.bodySm(color: AppColors.outline),
                          ),
                        );
                      }
                      return ListView.separated(
                        itemCount: msgs.length,
                        separatorBuilder: (_, index) => const SizedBox(height: 8),
                        itemBuilder: (context, idx) {
                          final m = msgs[idx];
                          return _MessageBubble(
                            sender: m.user.name,
                            text: m.message,
                            time: 'Live',
                            isSelf: m.user.id == ZegoUIKit().getLocalUser().id,
                            isTeacher: false,
                          );
                        },
                      );
                    },
                  )
                : ListView.separated(
                    itemCount: _fallbackMessages.length,
                    separatorBuilder: (_, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final msg = _fallbackMessages[index];
                      return _MessageBubble(
                        sender: msg.sender,
                        text: msg.text,
                        time: msg.time,
                        isTeacher: msg.isTeacher,
                        isSelf: msg.isSelf,
                      );
                    },
                  ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextField(
                    controller: _chatController,
                    onSubmitted: (_) => _sendMessage(),
                    style: AppTypography.bodySm(color: AppColors.onSurface),
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      hintStyle: AppTypography.bodySm(color: AppColors.outline),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send_rounded, color: AppColors.primary),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // IN-ROOM PARTICIPANTS DRAWER
  // ---------------------------------------------------------------------------

  Widget _buildParticipantsDrawer(bool hasCredentials, bool isTeacher) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [AppColors.softShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Class Participants',
                style: AppTypography.headlineSm(color: AppColors.onSurface),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: () => setState(() => _showParticipantsDrawer = false),
              ),
            ],
          ),
          const Divider(),
          if (hasCredentials)
            StreamBuilder<List<ZegoUIKitUser>>(
              stream: ZegoUIKit().getUserListStream(),
              builder: (context, snapshot) {
                final users = snapshot.data ?? [];
                return Column(
                  children: users.map((u) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primaryFixed,
                        child: Text(u.name.isNotEmpty ? u.name[0] : 'U'),
                      ),
                      title: Text(u.name, style: AppTypography.labelMd(color: AppColors.onSurface)),
                      trailing: isTeacher
                          ? TextButton(
                              onPressed: () async {
                                await ZegoService.broadcastMuteUser(u.id);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Mute signal sent to ${u.name}.')),
                                  );
                                }
                              },
                              child: const Text('Mute', style: TextStyle(color: AppColors.error)),
                            )
                          : null,
                    );
                  }).toList(),
                );
              },
            )
          else
            const Center(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Text('Participants active in classroom session.'),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SUB-WIDGETS & MODELS
// ---------------------------------------------------------------------------

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final Color activeBgColor;
  final Color inactiveBgColor;
  final Color activeFgColor;
  final Color inactiveFgColor;
  final VoidCallback onPressed;
  final int badgeCount;

  const _CircleButton({
    required this.icon,
    required this.isActive,
    required this.activeBgColor,
    required this.inactiveBgColor,
    required this.activeFgColor,
    required this.inactiveFgColor,
    required this.onPressed,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(9999),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isActive ? activeBgColor : inactiveBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 20,
              color: isActive ? activeFgColor : inactiveFgColor,
            ),
          ),
        ),
        if (badgeCount > 0)
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$badgeCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ParticipantTile extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final bool isHighlighted;
  final bool isMicMuted;
  final bool hasHandRaised;

  const _ParticipantTile({
    required this.name,
    this.imageUrl,
    this.isHighlighted = false,
    this.isMicMuted = false,
    this.hasHandRaised = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: isHighlighted ? Border.all(color: AppColors.secondary, width: 2) : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            if (imageUrl != null)
              Image.network(
                imageUrl!,
                width: 100,
                height: 84,
                fit: BoxFit.cover,
              )
            else
              Container(
                width: 100,
                height: 84,
                color: AppColors.surfaceContainerHigh,
                child: Center(
                  child: Text(
                    name.isNotEmpty ? name[0] : '?',
                    style: AppTypography.headlineSm(color: AppColors.onSurfaceVariant),
                  ),
                ),
              ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
                ),
              ),
            ),
            Positioned(
              left: 6,
              bottom: 6,
              right: 6,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.labelSm(color: Colors.white),
                    ),
                  ),
                  if (hasHandRaised)
                    const Text('✋', style: TextStyle(fontSize: 10))
                  else if (isMicMuted)
                    const Icon(Icons.mic_off, size: 12, color: AppColors.error),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InRoomMessage {
  final String sender;
  final String text;
  final String time;
  final bool isTeacher;
  final bool isSelf;

  _InRoomMessage({
    required this.sender,
    required this.text,
    required this.time,
    this.isTeacher = false,
    this.isSelf = false,
  });
}

class _MessageBubble extends StatelessWidget {
  final String sender;
  final String text;
  final String time;
  final bool isTeacher;
  final bool isSelf;

  const _MessageBubble({
    required this.sender,
    required this.text,
    required this.time,
    this.isTeacher = false,
    this.isSelf = false,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isSelf ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 260),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelf
              ? AppColors.primary
              : isTeacher
                  ? AppColors.secondaryFixed
                  : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isSelf)
              Text(
                sender,
                style: AppTypography.labelSm(
                  color: isTeacher ? AppColors.onSecondaryFixed : AppColors.primary,
                ).copyWith(fontWeight: FontWeight.bold),
              ),
            Text(
              text,
              style: AppTypography.bodySm(
                color: isSelf ? AppColors.onPrimary : AppColors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
