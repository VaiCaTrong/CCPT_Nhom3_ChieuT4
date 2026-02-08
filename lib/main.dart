import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'features/auth/presentation/pages/auth_page.dart';
import 'services/config_service.dart';
import 'services/zego_service.dart';

// Key điều hướng toàn cục để Zego có thể điều khiển app từ bên ngoài
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Gán navigatorKey cho Zego Service TRƯỚC KHI RUN APP
  ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(navigatorKey);

  try {
    // Initialize Firebase FIRST (mobile uses google-services.json)
    if (kIsWeb) {
      // For web, get config from backend
      final configService = ConfigService();
      final firebaseConfig = await configService.getFirebaseConfig();

      await Firebase.initializeApp(
        options: FirebaseOptions(
          apiKey: firebaseConfig['apiKey'],
          authDomain: firebaseConfig['authDomain'],
          projectId: firebaseConfig['projectId'],
          storageBucket: firebaseConfig['storageBucket'],
          messagingSenderId: firebaseConfig['messagingSenderId'],
          appId: firebaseConfig['appId'],
          measurementId: firebaseConfig['measurementId'],
        ),
      );
    } else {
      // For mobile, use google-services.json
      await Firebase.initializeApp();
    }

    if (kDebugMode) {
      print('✅ Firebase initialized successfully');
    }
  } catch (e) {
    if (kDebugMode) {
      print('❌ Firebase initialization error: $e');
    }
    // Continue anyway - app can still work with limited functionality
  }

  // Initialize Zego config from backend (non-blocking)
  // This runs in background and won't block app startup
  try {
    final zegoService = ZegoService();
    await zegoService.initialize();
    if (kDebugMode) {
      print('✅ Zego initialized successfully');
    }
  } catch (e) {
    if (kDebugMode) {
      print('❌ Zego initialization error: $e');
      print('⚠️ App will continue with limited call functionality');
    }
    // App continues even if Zego fails
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App Đồ Án',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: _buildVibrantTheme(),
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        physics: const BouncingScrollPhysics(),
      ),
      builder: (BuildContext context, Widget? child) {
        return Stack(
          children: [
            child!,
            // Widget này xử lý màn hình chờ cuộc gọi và mini-overlay khi đang gọi
            ZegoUIKitPrebuiltCallMiniOverlayPage(
              contextQuery: () {
                return navigatorKey.currentState!.context;
              },
            ),
          ],
        );
      },
      home: const AuthPage(),
    );
  }
}

ThemeData _buildVibrantTheme() {
  return ThemeData(
    useMaterial3: true,

    // --- COLOR SCHEME ---
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF673AB7), // Deep Purple
      primary: const Color(0xFF7E57C2), // A slightly lighter deep purple
      secondary: const Color(0xFFFFC107), // Amber for accents
      background: const Color(0xFFF5F5F5), // Light grey for background
      surface: Colors.white, // For cards, dialogs, etc.
      error: Colors.redAccent,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onBackground: Colors.black,
      onSurface: Colors.black,
      onError: Colors.white,
      brightness: Brightness.light,
    ),

    // --- TYPOGRAPHY ---
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 32.0),
      headlineMedium: TextStyle(fontWeight: FontWeight.w600, fontSize: 24.0),
      bodyMedium: TextStyle(fontSize: 14.0, height: 1.5),
      labelLarge: TextStyle(
          fontWeight: FontWeight.bold, fontSize: 16.0), // For button text
    ),

    // --- COMPONENT THEMES ---

    // AppBar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF7E57C2),
      foregroundColor: Colors.white,
      elevation: 2,
      centerTitle: false, // Đã thay đổi thành false
      titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    ),

    // ElevatedButton Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF7E57C2), // primary color
        foregroundColor: Colors.white, // onPrimary color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      elevation: 5,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
    ),

    // InputDecoration Theme (for TextFields)
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF673AB7), width: 2.0),
      ),
      filled: true,
      fillColor: Colors.white,
      prefixIconColor: Colors.grey.shade600,
    ),

    // --- PAGE TRANSITIONS ---
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),

    // --- SCROLLBAR ---
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: MaterialStateProperty.all(Colors.deepPurple.withOpacity(0.6)),
      radius: const Radius.circular(8),
      thickness: MaterialStateProperty.all(8.0),
    ),
  );
}
