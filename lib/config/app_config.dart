import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  /// Get API base URL based on environment
  static String get apiBaseUrl {
    // Priority 1: Use .env file if exists
    final envUrl = dotenv.env['API_BASE_URL'];
    if (envUrl != null && envUrl.isNotEmpty) {
      return envUrl;
    }

    // Priority 2: Auto-detect based on platform
    if (kIsWeb) {
      // For web, use localhost
      return 'http://localhost:3000/api';
    } else if (kDebugMode) {
      // For debug mode (emulator), use localhost
      // Android emulator uses 10.0.2.2 to access host machine
      if (defaultTargetPlatform == TargetPlatform.android) {
        return 'http://10.0.2.2:3000/api';
      }
      // iOS simulator can use localhost
      return 'http://localhost:3000/api';
    } else {
      // For release mode, should use production URL
      return 'https://your-production-api.com/api';
    }
  }

  /// Get Zego App ID
  static int get zegoAppId {
    final appIdStr = dotenv.env['ZEGO_APP_ID'];
    if (appIdStr != null) {
      return int.tryParse(appIdStr) ?? 0;
    }
    return 0;
  }

  /// Get Zego App Sign
  static String get zegoAppSign {
    return dotenv.env['ZEGO_APP_SIGN'] ?? '';
  }

  /// Check if running in production
  static bool get isProduction => kReleaseMode;

  /// Check if running in debug
  static bool get isDebug => kDebugMode;
}
