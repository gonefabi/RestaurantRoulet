import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/notification_service.dart';
import 'firebase_options.dart';
import 'widgets/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Notifications
  final notificationService = NotificationService();
  await notificationService.init();
  await notificationService.requestPermissions();
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Definition der neuen, modernen & hellen Farbpalette
    const Color primaryColor = Color(0xFF007BFF); // Lebhaftes Blau
    const Color accentColor = Color(0xFFFFA500); // Warmes Orange für Akzente
    const Color backgroundColor = Color(0xFFF5F5F7); // Off-White
    const Color textColor = Color(0xFF212121); // Dunkles Anthrazit
    const Color cardColor = Colors.white;

    return MaterialApp(
      title: 'Restaurant Roulette',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: backgroundColor,
        
        // Farbschema
        colorScheme: const ColorScheme.light(
          primary: primaryColor,
          secondary: accentColor,
          background: backgroundColor,
          surface: cardColor,
          onPrimary: Colors.white,
          onSecondary: Colors.black,
          onBackground: textColor,
          onSurface: textColor,
        ),

        // AppBar Theme
        appBarTheme: const AppBarTheme(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
        ),

        // Button Themes
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        
        // Slider Theme
        sliderTheme: const SliderThemeData(
          activeTrackColor: primaryColor,
          inactiveTrackColor: primaryColor,
          thumbColor: primaryColor,
        ),
        
        // Karten-Theme: Wir setzen es direkt im Card Widget oder lassen den Default
        // Um Typ-Probleme zu vermeiden, lassen wir es hier im ThemeData weg.
      ),
      home: const AuthWrapper(),
    );
  }
}
