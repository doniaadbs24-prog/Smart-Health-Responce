import 'package:flutter/foundation.dart';

class AppLogger {
  AppLogger._();

  static void d(Object? message) {
    if (kDebugMode) debugPrint('[DEBUG] $message');
  }

  static void i(Object? message) {
    if (kDebugMode) debugPrint('[INFO]  $message');
  }

  static void w(Object? message) {
    if (kDebugMode) debugPrint('[WARN]  $message');
  }

  static void e(Object? message, [Object? error, StackTrace? trace]) {
    if (kDebugMode) {
      debugPrint('[ERROR] $message');
      if (error != null) debugPrint(error.toString());
      if (trace != null) debugPrint(trace.toString());
    }
  }
}
