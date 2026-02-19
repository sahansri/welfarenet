import 'package:flutter/material.dart';
import 'package:welfarenet_mobile/pages/splash.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WelfareNet',
      // Builder to access MediaQuery for responsive theme
      builder: (context, child) {
        // Get screen width for responsive adjustments
        final screenWidth = MediaQuery.of(context).size.width;
        final scaleFactor = (screenWidth / 375).clamp(0.8, 1.3);

        return MediaQuery(
          // Preserve user's font size settings while ensuring readability
          data: MediaQuery.of(context).copyWith(
            // Constrain text scale factor to prevent extreme sizes
            textScaleFactor: MediaQuery.of(
              context,
            ).textScaleFactor.clamp(0.8, 1.5),
          ),
          child: child!,
        );
      },
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF7A5AF8),
        scaffoldBackgroundColor: const Color(0xFFF9FAFB),
        colorScheme: ColorScheme.light(
          primary: const Color(0xFF7A5AF8),
          secondary: const Color(0xFF7C3AED),
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Color(0xFF7A5AF8)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7A5AF8),
            foregroundColor: Colors.white,
            elevation: 2,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            // Make button text responsive
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
