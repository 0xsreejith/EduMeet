import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseService {
  static bool _isInitialized = false;
  static bool get isInitialized => _isInitialized;

  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp();
      _isInitialized = true;
      if (kDebugMode) {
        print('Firebase successfully initialized.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Firebase initialization skipped or failed: $e. Running in offline/mock mode.');
      }
      _isInitialized = false;
    }
  }
}

