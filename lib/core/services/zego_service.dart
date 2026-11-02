import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:zego_uikit/zego_uikit.dart';

/// ZEGOCLOUD Real-Time Communication Service for EduMeet
///
/// Encapsulates room lifecycle, engine initialization, user authentication,
/// and live classroom audio/video streaming controls.
///
/// Credentials are read exclusively from environment variables (--dart-define)
/// to prevent hardcoded credentials in source code.
class ZegoService {
  /// Reads ZEGO_APP_ID from environment (--dart-define=ZEGO_APP_ID=...)
  static int get appId {
    const envAppId = String.fromEnvironment('ZEGO_APP_ID');
    if (envAppId.isNotEmpty) {
      return int.tryParse(envAppId) ?? 0;
    }
    return 0;
  }

  /// Reads ZEGO_APP_SIGN from environment (--dart-define=ZEGO_APP_SIGN=...)
  static String get appSign {
    return const String.fromEnvironment('ZEGO_APP_SIGN', defaultValue: '');
  }

  /// Verifies if legitimate credentials have been provided
  static bool get hasValidCredentials => appId > 0 && appSign.isNotEmpty;

  /// Generates a unique, human-readable room ID for virtual classroom sessions
  static String generateRoomId({String? prefix}) {
    final rand = Random().nextInt(900000) + 100000;
    final p = prefix ?? 'edumeet';
    return '${p}_$rand';
  }

  /// Session instance suffix generated once per app process launch
  /// Ensures unique participant IDs during multi-device RTC testing
  static final String sessionInstanceSuffix =
      (Random().nextInt(9000) + 1000).toString();

  /// Generates a unique participant user ID for RTC rooms
  static String generateUniqueUserId(String baseId) {
    return '${baseId}_$sessionInstanceSuffix';
  }

  /// Initializes ZEGOCLOUD engine and logs in local user
  static Future<bool> initUser({
    required String userId,
    required String userName,
  }) async {
    if (!hasValidCredentials) {
      debugPrint('[ZegoService] Missing valid ZEGO_APP_ID or ZEGO_APP_SIGN.');
      return false;
    }

    try {
      await ZegoUIKit().init(
        appID: appId,
        appSign: appSign,
        scenario: ZegoScenario.Default,
      );
      ZegoUIKit().login(userId, userName);
      return true;
    } catch (e) {
      debugPrint('[ZegoService] Error initializing ZEGOCLOUD: $e');
      return false;
    }
  }

  /// Joins a classroom room and configures initial role hardware states
  static Future<bool> joinClassroom({
    required String roomId,
    required bool isTeacher,
  }) async {
    if (!hasValidCredentials) {
      return false;
    }

    try {
      // Ensure any previous session room is cleaned up before joining
      await ZegoUIKit().leaveRoom();

      final result = await ZegoUIKit().joinRoom(roomId);
      // errorCode 0: success, 1000020: already logged into room
      if (result.errorCode == 0 || result.errorCode == 1000020) {
        // Teacher starts with camera and mic ON; Student starts with camera ON and mic MUTED
        ZegoUIKit().turnCameraOn(true);
        ZegoUIKit().turnMicrophoneOn(isTeacher);
        return true;
      } else {
        debugPrint('[ZegoService] Join room failed with code: ${result.errorCode}');
        return false;
      }
    } catch (e) {
      debugPrint('[ZegoService] Exception while joining room: $e');
      return false;
    }
  }

  /// Toggles microphone for a user using Zego's RTC state as source of truth
  static void toggleMicrophone({required String userId, required bool currentState}) {
    ZegoUIKit().turnMicrophoneOn(!currentState, userID: userId);
  }

  /// Toggles camera for a user using Zego's RTC state as source of truth
  static void toggleCamera({required String userId, required bool currentState}) {
    ZegoUIKit().turnCameraOn(!currentState, userID: userId);
  }

  /// Transmits in-room signaling command (e.g. Raise Hand)
  static Future<bool> sendHandRaiseCommand({
    required String userId,
    required String userName,
    required bool isRaised,
  }) async {
    final cmd = isRaised ? 'HAND_RAISE:$userId:$userName' : 'HAND_LOWER:$userId:$userName';
    return ZegoUIKit().sendInRoomCommand(cmd, []);
  }

  /// Broadcasts a room-wide command to end the classroom for all participants
  static Future<bool> broadcastEndClassroom() async {
    return ZegoUIKit().sendInRoomCommand('CLASSROOM_ENDED_BY_TEACHER', []);
  }

  /// Broadcasts a room-wide command to mute all student microphones at source
  static Future<bool> broadcastMuteAllMicrophones() async {
    return ZegoUIKit().sendInRoomCommand('MUTE_MICROPHONE_ALL', []);
  }

  /// Transmits a direct command to mute a specific user's microphone at source
  static Future<bool> broadcastMuteUser(String userId) async {
    return ZegoUIKit().sendInRoomCommand('MUTE_MICROPHONE_USER:$userId', []);
  }

  /// Leaves the classroom and safely releases camera, mic and network resources
  static Future<void> leaveClassroom() async {
    try {
      await ZegoUIKit().leaveRoom();
      ZegoUIKit().logout();
    } catch (e) {
      debugPrint('[ZegoService] Error leaving classroom: $e');
    }
  }
}
