import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zego_uikit/zego_uikit.dart';
import '../../../../core/services/zego_service.dart';

enum LiveClassroomStatus {
  idle,
  connecting,
  connected,
  reconnecting,
  disconnected,
  error,
}

class LiveClassroomState {
  final LiveClassroomStatus status;
  final String? errorMessage;
  final bool isHandRaised;
  final int participantCount;
  final bool hasCredentials;
  final bool isEndedByTeacher;
  final bool hasPermissionDenied;

  const LiveClassroomState({
    this.status = LiveClassroomStatus.idle,
    this.errorMessage,
    this.isHandRaised = false,
    this.participantCount = 1,
    this.hasCredentials = false,
    this.isEndedByTeacher = false,
    this.hasPermissionDenied = false,
  });

  LiveClassroomState copyWith({
    LiveClassroomStatus? status,
    String? errorMessage,
    bool? isHandRaised,
    int? participantCount,
    bool? hasCredentials,
    bool? isEndedByTeacher,
    bool? hasPermissionDenied,
  }) {
    return LiveClassroomState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      isHandRaised: isHandRaised ?? this.isHandRaised,
      participantCount: participantCount ?? this.participantCount,
      hasCredentials: hasCredentials ?? this.hasCredentials,
      isEndedByTeacher: isEndedByTeacher ?? this.isEndedByTeacher,
      hasPermissionDenied: hasPermissionDenied ?? this.hasPermissionDenied,
    );
  }
}

class LiveClassroomNotifier extends Notifier<LiveClassroomState> {
  StreamSubscription? _userListSub;
  VoidCallback? _roomStateListener;

  @override
  LiveClassroomState build() {
    ref.onDispose(() {
      _cleanup();
    });
    return LiveClassroomState(hasCredentials: ZegoService.hasValidCredentials);
  }

  /// Initializes ZEGOCLOUD room and joins session
  Future<void> joinRoom({
    required String roomId,
    required String userId,
    required String userName,
    required bool isTeacher,
  }) async {
    if (!ZegoService.hasValidCredentials) {
      state = state.copyWith(
        status: LiveClassroomStatus.connected,
        hasCredentials: false,
      );
      return;
    }

    state = state.copyWith(status: LiveClassroomStatus.connecting);

    final initSuccess = await ZegoService.initUser(
      userId: userId,
      userName: userName,
    );

    if (!initSuccess) {
      state = state.copyWith(
        status: LiveClassroomStatus.error,
        errorMessage: 'Failed to initialize ZEGOCLOUD RTC engine.',
      );
      return;
    }

    final joinSuccess = await ZegoService.joinClassroom(
      roomId: roomId,
      isTeacher: isTeacher,
    );

    if (!joinSuccess) {
      state = state.copyWith(
        status: LiveClassroomStatus.error,
        errorMessage: 'Unable to connect to live classroom room: $roomId',
      );
      return;
    }

    state = state.copyWith(
      status: LiveClassroomStatus.connected,
      hasCredentials: true,
      isEndedByTeacher: false,
    );

    // Subscribe to Zego RTC user list updates (Source of truth)
    _userListSub?.cancel();
    _userListSub = ZegoUIKit().getUserListStream().listen((users) {
      // ZegoUIKit().getUserListStream() emits [localUser, ...remoteUsersList].
      // When connected, there is at least 1 participant (the local user).
      final total = users.isEmpty ? 1 : users.length;
      state = state.copyWith(participantCount: total);
    });

    // Subscribe to room state changes (Source of truth for network/disconnects)
    _roomStateListener = () {
      final roomState = ZegoUIKit().getRoomStateStream().value;
      if (roomState.errorCode != 0) {
        state = state.copyWith(
          status: LiveClassroomStatus.error,
          errorMessage: 'Room connection error (code: ${roomState.errorCode})',
        );
      } else if (roomState.reason == ZegoRoomStateChangedReason.Reconnecting) {
        state = state.copyWith(status: LiveClassroomStatus.reconnecting);
      } else if (roomState.reason == ZegoRoomStateChangedReason.Logined ||
          roomState.reason == ZegoRoomStateChangedReason.Reconnected) {
        state = state.copyWith(status: LiveClassroomStatus.connected);
      }
    };
    ZegoUIKit().getRoomStateStream().addListener(_roomStateListener!);
  }

  /// Toggles raise hand signaling
  Future<void> toggleHandRaise({
    required String userId,
    required String userName,
  }) async {
    final nextState = !state.isHandRaised;
    state = state.copyWith(isHandRaised: nextState);

    if (ZegoService.hasValidCredentials) {
      await ZegoService.sendHandRaiseCommand(
        userId: userId,
        userName: userName,
        isRaised: nextState,
      );
    }
  }

  /// Broadcasts end of classroom to all participants (Teacher host action)
  Future<void> endClassroomForAll() async {
    if (ZegoService.hasValidCredentials) {
      await ZegoService.broadcastEndClassroom();
    }
    await leaveRoom();
  }

  /// Broadcasts mute all command to all participants (Teacher host action)
  Future<void> muteAllStudents() async {
    if (ZegoService.hasValidCredentials) {
      await ZegoService.broadcastMuteAllMicrophones();
    }
  }

  /// Handles incoming teacher end-session event on student devices
  Future<void> onClassroomEndedByTeacher() async {
    state = state.copyWith(isEndedByTeacher: true);
    await leaveRoom();
  }

  /// Sets permission denied state
  void setPermissionDenied(bool denied) {
    state = state.copyWith(hasPermissionDenied: denied);
  }

  /// Leaves the classroom and performs resource teardown
  Future<void> leaveRoom() async {
    _cleanup();

    if (ZegoService.hasValidCredentials) {
      await ZegoService.leaveClassroom();
    }

    state = state.copyWith(
      status: LiveClassroomStatus.disconnected,
      isHandRaised: false,
    );
  }

  void _cleanup() {
    _userListSub?.cancel();
    _userListSub = null;
    if (_roomStateListener != null) {
      ZegoUIKit().getRoomStateStream().removeListener(_roomStateListener!);
      _roomStateListener = null;
    }
  }
}

final liveClassroomProvider =
    NotifierProvider<LiveClassroomNotifier, LiveClassroomState>(() {
  return LiveClassroomNotifier();
});
