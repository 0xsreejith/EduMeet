abstract class RouteConstants {
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';

  // Shell Tabs
  static const String home = '/home';
  static const String classes = '/classes';
  static const String chat = '/chat';
  static const String progress = '/progress';
  static const String profile = '/profile';

  // Sub routes
  static const String liveClassroom = '/live/:roomId';
  static const String createClass = '/create-class';
  static const String joinClass = '/join-class';
  static const String classDetail = '/class/:classId';
}

