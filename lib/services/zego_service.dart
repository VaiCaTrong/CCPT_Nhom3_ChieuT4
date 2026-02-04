import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'config_service.dart';

class ZegoService {
  static final ZegoService _instance = ZegoService._internal();
  factory ZegoService() => _instance;
  ZegoService._internal();

  final ConfigService _configService = ConfigService();

  int? _appId;
  String? _appSign;
  bool _initialized = false;

  /// Initialize Zego config from backend
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Try to get config from backend
      final config = await _configService.getZegoConfig();
      _appId = config['appId'];
      _appSign = config['appSign'];
      _initialized = true;
      print('✅ Zego config loaded from backend: AppID=$_appId');
    } catch (e) {
      print('⚠️ Failed to load Zego config from backend: $e');
      print('📱 Using hardcoded Zego config from .env');

      // Fallback to config from .env file
      final appIdStr = dotenv.env['ZEGO_APP_ID'];
      final appSign = dotenv.env['ZEGO_APP_SIGN'];

      if (appIdStr != null && appSign != null) {
        _appId = int.tryParse(appIdStr);
        _appSign = appSign;
        _initialized = true;
        print('✅ Zego initialized with .env config');
      } else {
        throw Exception('Zego config not found in .env file');
      }
    }
  }

  /// Get Zego App ID
  int get appId {
    if (_appId == null) {
      throw Exception('Zego not initialized. Call initialize() first.');
    }
    return _appId!;
  }

  /// Get Zego App Sign
  String get appSign {
    if (_appSign == null) {
      throw Exception('Zego not initialized. Call initialize() first.');
    }
    return _appSign!;
  }

  /// Check if initialized
  bool get isInitialized => _initialized;

  /// Reset (for testing)
  void reset() {
    _appId = null;
    _appSign = null;
    _initialized = false;
  }
}
