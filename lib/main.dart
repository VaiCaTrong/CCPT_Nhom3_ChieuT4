import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'features/auth/presentation/pages/auth_page.dart';

// Key điều hướng toàn cục để Zego có thể điều khiển app từ bên ngoài
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Gán navigatorKey cho Zego Service TRƯỚC KHI RUN APP
  ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(navigatorKey);

  try {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyDDdtP5JE4z6gGCqqR79_KeA-ne9cloGeo",
          authDomain: "chatappfinal-620d3.firebaseapp.com",
          projectId: "chatappfinal-620d3",
          storageBucket: "chatappfinal-620d3.firebasestorage.app",
          messagingSenderId: "713648515500",
          appId: "1:713648515500:web:eb9168b0bb91ed53d2f209",
          measurementId: "G-CWMR96TZVZ",
        ),
      );
    } else {
      await Firebase.initializeApp();
    }
  } catch (e) {
    if (kDebugMode) {
      print('Firebase init error: $e');
    }
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
      primary: const Color(0xFF7E57C2),   // A slightly lighter deep purple
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
      labelLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0), // For button text
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
